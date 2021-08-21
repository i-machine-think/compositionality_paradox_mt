import logging
import pickle
import numpy as np
import editdistance


def get_conjunct(sentence):
    """
    Separate sentence into two parts based on conjunction.

    Args:
        - sentence (str)
    Returns:
        - whether the conjunct was found
        - the conjunct
    """
    conjunction = " en "

    # If conjunct in sentence
    if conjunction in sentence:
        conjunct = sentence.split(conjunction)[1:]
        # If the conjunct is shorter than 3 words you've got the wrong one
        if len(sentence.split(conjunction)[0].split()) < 3:
            conjunct = sentence.split(conjunction)[2:]
        conjunct = conjunction.join(conjunct)
        return True, f"MASK {conjunct}"
    return False, f"MASK {sentence}"


def reorder(lines):
    """
    Reorder lines, since Fairseq shuffles them while translating.

    Order based on the index indicated after "D-...", "S-..." or "H-...".
    
    Args:
        - lines: list of str
    Returns:
        - list of str
    """
    sentences = []
    for line in lines:
        line = line.split("\t")
        if "D-" in line[0]:
            index = int(line[0].split('-')[1])
            sentence = line[2].strip()
            sentences.append((index, sentence))
    _, sentences = zip(*sorted(sentences))
    assert len(sentences) == 500
    return sentences


def compute_systematicity_s_conj(template, data_type, model):
    """
    Compute systematicity consistency scores for the S -> S CONJ S setup.

    Args:
        - template (int): 1 ... 10
        - data_type (str): natural | semi_natural | synthetic
        - model (str): format of "transformer_DATA_SEED"
    Returns:
        - s1p (float): consistency score for the S1 -> S1' condition
        - s3 (float): consistency score for the S1 -> S3 condition
        - trace (dict): mistakes made by the model
    """
    trace = dict()
    condition_s1p = []
    condition_s3 = []
    prefix = f"s_conj/{data_type}/systematicity_{data_type}_{template}"

    # English source sentences
    with open(f"{prefix}_s1_s2.en", encoding="utf-8") as f:
        srcs = f.readlines()

    # Gather the translation of the regular setup and the two subconditions
    prefix = f"s_conj/pred_{data_type}/{model}/systematicity_{data_type}_{template}"
    with open(f"{prefix}_s1_s2.nl", encoding="utf-8") as f:
        pred_s1_s2 = reorder(f.readlines())
    with open(f"{prefix}_s1p_s2.nl", encoding="utf-8") as f:
        pred_s1p_s2 = reorder(f.readlines())
    with open(f"{prefix}_s3_s2.nl", encoding="utf-8") as f:
        pred_s3_s2 = reorder(f.readlines())

    for src, first, second, third in zip(srcs, pred_s1_s2, pred_s1p_s2, pred_s3_s2):
        # Ensure that the same type of tokenisation is used 
        found1, first_conjunct = get_conjunct(first)
        found2, second_conjunct = get_conjunct(second)
        found3, third_conjunct = get_conjunct(third)

        # Don't consider sentences where the second conjunct was not found
        if not all([found1, found2, found3]):
            continue

        condition_s1p.append(first_conjunct == second_conjunct)
        condition_s3.append(first_conjunct == third_conjunct)

        # Collect cases where s2 different for s1' and s3 substitutions
        if first_conjunct not in {second_conjunct, third_conjunct}:
            trace[src.strip()] = (first_conjunct, second_conjunct, third_conjunct)

    s1p = np.mean(condition_s1p)
    s3 = np.mean(condition_s3)
    return (s1p, s3), trace


def compute_systematicity_s_np_vp(template, data_type, model):
    """
    Compute systematicity consistency scores for the S -> NP VP setup.

    Args:
        - template (int): 1 ... 10
        - data_type (str): natural | semi_natural | synthetic
        - model (str): format of "transformer_DATA_SEED"
    Returns:
        - score_np (float): consistency score for the NP -> NP' condition
        - score_vp (float): consistency score for the VP -> VP' condition
        - trace (dict): mistakes made by the model
    """
    trace = dict()

    condition_np = []
    condition_vp = []
    prefix = f"s_np_vp/{data_type}/systematicity_{data_type}_{template}"
    with open(f"{prefix}_np.en", encoding="utf-8") as f:
        np_srcs = f.readlines()
    with open(f"{prefix}_np_prime.en", encoding="utf-8") as f:
        np_srcs_prime = f.readlines()
    if data_type == "synthetic":
        with open(f"{prefix}_vp_prime.en", encoding="utf-8") as f:
            vp_srcs_prime = f.readlines()
    prefix = f"s_np_vp/pred_{data_type}/{model}/systematicity_{data_type}_{template}"
    with open(f"{prefix}_np.nl", encoding="utf-8") as f:
        pred_np = reorder(f.readlines())
    with open(f"{prefix}_np_prime.nl", encoding="utf-8") as f:
        pred_np_prime = reorder(f.readlines())
    if data_type == "synthetic":
        with open(f"{prefix}_vp_prime.nl", encoding="utf-8") as f:
            pred_vp_prime = reorder(f.readlines())

    for k, (src, src_prime, sent, np_prime) in enumerate(zip(np_srcs, np_srcs_prime, pred_np, pred_np_prime)):
        sent = sent.replace(" het ", " de ").replace("Het ", "De ").replace(" dat ", " die ")
        np_prime = np_prime.replace(" het ", " de ").replace("Het ", "De ").replace(" dat ", " die ")
        
        condition_np.append(editdistance.eval(sent.split(), np_prime.split()) == 1)
        if editdistance.eval(sent.split(), np_prime.split()) != 1:
            trace[(src.strip(), src_prime, "np")] = (sent, np_prime)

        if data_type == "synthetic":
            vp_prime = pred_vp_prime[k].replace(" het ", " de ").replace("Het ", "De ").replace(" dat ", " die ")
            vp_prime = vp_prime.replace(" het ", " de ").replace("Het ", "De ").replace(" dat ", " die ")
            condition_vp.append(editdistance.eval(sent.split(), vp_prime.split()) == 1)
            if editdistance.eval(sent.split(), vp_prime.split()) != 1:
                trace[(np_srcs[k].strip(), vp_srcs_prime[k], "vp")] = (sent, vp_prime)

    # Report results to user in a format that can easily be copied to tables
    score_np = np.mean(condition_np)
    score_vp = None if data_type != "synthetic" else np.mean(condition_vp)
    return (score_np, score_vp), trace


if __name__ == "__main__":
    results = dict()

    sizes = ["tiny", "small", "all"]
    for size in sizes:
        for seed in [1, 2, 3, 4, 5]:
            model = f"transformer_{size}_{seed}"
            for t in range(1, 11):
                print(model, t)
                for data_type in ["synthetic", "semi_natural", "natural"]:
                    score, trace_conj = compute_systematicity_s_conj(t, data_type, model)
                    results[(model, seed, "s_conj", data_type, t)] = score
                
                for data_type in ["synthetic", "semi_natural"]:
                    score, trace_np_vp = compute_systematicity_s_np_vp(t, data_type, model)
                    results[(model, seed, "s_np_vp", data_type, t)] = score
    pickle.dump(results, open("results.pickle", 'wb'))
