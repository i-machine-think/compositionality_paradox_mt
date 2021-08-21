import pickle
import os
import numpy as np


def reorder(lines, check=True, num_lines=500):
    """
    Takes the shuffled Fairseq translations and puts them back in order.
    Args:
        lines: list of strings, Fairseq output
        check: whether to check the file length
        num_lines: the expected number of lines
    Returns:
        lines: list of strings, reordered
    """
    sentences = []
    for line in lines:
        line = line.split("\t")
        if "D-" in line[0]:
            index = int(line[0].split('-')[1])
            sentence = line[2].strip()
            sentences.append((index, sentence))
    _, sentences = zip(*sorted(sentences))
    if check:
        assert len(sentences) == num_lines
    return list(sentences)


def transform(num, synonym_translations, sent, noun_only):

    translations = []
    for w in synonym_translations[num]:
        sent = sent.replace(w, w.replace(" ", "_"))
        translations.append(w.replace(" ", "_"))

    if not noun_only:
        return sent
    nl = None
    for n in translations:
        if n in sent:
            nl = n
            break
    if nl is None:
        nl = translations[0]
    sent = [x if nl not in x else nl for x in sent.split()]
    try:
        return sent[sent.index(nl)]
    except:
        return " ".join(sent)


def consistency(prefix, synonym_num, synonym_data, noun_only, check=True):
    with open(f"{prefix}-1.nl", encoding="utf-8") as f:
        british_lines = reorder(f.readlines(), check)
        british_lines = [transform(synonym_num, synonym_data, l, noun_only) for l in british_lines]
    with open(f"{prefix}-2.nl", encoding="utf-8") as f:
        american_lines = reorder(f.readlines(), check)
        american_lines = [transform(synonym_num, synonym_data, l, noun_only) for l in american_lines]
    scores = []
    for x, y in zip(british_lines, american_lines):
        scores.append(x.strip() == y.strip())
    return np.mean(scores)


if __name__ == "__main__":

    # Collect synonyms and their potential translations from file
    assert os.path.exists("synonyms.tsv"), "Please collect synonym data first."
    synonyms = dict()
    with open("synonyms.tsv", encoding="utf-8") as f:
        f.readline()
        for i, line in enumerate(f):
            synonym1, synonym2, _, _, _, translations1, translations2 = \
                line.strip().split("\t")
            translations = set(translations1.split(';') + translations2.split(';'))
            synonyms[i] = translations

    # Collect numerical results in a dictionary that will be visualised in
    # a separate jupyter notebook
    results = dict()
    for model in ["tiny", "small", "all"]:
        for seed in [1, 2, 3, 4, 5]:
            for data_type in ["synthetic", "semi_natural", "natural"]:
                for template in range(1, 11):
                    for syn_num in range(20):
                        print(model, seed, data_type, template, syn_num)
                        prefix = f"pred_{data_type}/transformer_{model}_{seed}/"
                        if data_type != "natural":
                            prefix += f"substitutivity_{data_type}_{template}_"
                            
                        cons = consistency(f"{prefix}{syn_num}", syn_num, synonyms, noun_only=False, check=data_type != "natural")
                        cons_natural = consistency(f"{prefix}{syn_num}", syn_num, synonyms, noun_only=True, check=data_type != "natural")
                        if data_type == "natural":
                            results[(model, seed, data_type, syn_num)] = (cons, cons_natural)
                        else:
                            results[(model, seed, data_type, template, syn_num)] = (cons, cons_natural)

    pickle.dump(results, open("results.pickle", 'wb'))
