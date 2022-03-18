import os
from collections import defaultdict, Counter
import sacrebleu
import nltk
import pickle
import tqdm
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt


class Classifier():
    """Simple classifier to label translations according to whether they
    contain the translation of a keywor (or not)."""

    def __init__(self, idiom_file: str):
        self.idioms = []
        self.nl_keywords = dict()

        # Open the idioms that contain nouns from file
        with open(idiom_file, encoding="utf-8") as f_annot:
            f_annot.readline()
            for line in f_annot:
                idiom, en_keywords, nl_keywords, _ = line.strip().split("\t")
                self.idioms.append(idiom)
                self.nl_keywords[idiom] = eval(nl_keywords)

    def __call__(self, idiom: str, prd: str):
        """Return the classification of the translation for this idiom."""
        return self.classify(idiom, prd)

    def contains(self, idiom: str):
        """Check whether the classifier contains keywords for this idiom."""
        return idiom in self.nl_keywords

    def classify(self, idiom: str, prd: str):
        """For a given idiom, predict the class of the predicted translation."""
        prd = prd.lower().strip()
        idiom = idiom.lower().strip()

        # check if the Dutch translation of the keyword is present
        keywords = self.nl_keywords[idiom]
        keywords_present = []
        for keyword in keywords:
            keywords_present.append(keyword.lower() in prd)
        if any(keywords_present):
            return "word-by-word"

        # Otherwise, it is considered a paraphrase
        return "paraphrase"


def reorder(lines, check=False):
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
    if not sentences:
        return []
    _, sentences = zip(*sorted(sentences))
    if check:
        assert len(sentences) == 500
    return sentences


def main(model, seed, data_type):
    idioms = open("idioms.tsv", encoding="utf-8").readlines()
    idioms = [x.split("\t")[0].strip() for x in idioms][1:]

    classifier = Classifier("idioms.tsv")

    if "_all" in model:
        checkpoints = [1, 2, 3, 4, 6, 8, 12, 16, 20, 30]
    elif "_small" in model:
        checkpoints = [1, 2, 3, 6, 10, 15, 20, 30, 40, 50]
    else:
        checkpoints = [1, 5, 10, 20, 30, 40, 60, 80, 120, 160]

    all_x, all_y = [], []
    for i in range(20):
        x, y = [], []
        for checkpoint in checkpoints:
            scores = []
            if data_type == "natural":
                with open(f"natural/{i}.en", encoding="utf-8") as f_src, \
                     open(f"natural/{i}.nl", encoding="utf-8") as f_tgt, \
                     open(f"pred_natural/{model}_{seed}/checkpoint{checkpoint}/{i}.nl", encoding="utf-8") as f_prd:
                    f_src = f_src.readlines()
                    f_tgt = f_tgt.readlines()
                    f_prd = reorder(f_prd.readlines(), check=False)

                    for src, tgt, prd in zip(f_src, f_tgt, f_prd):
                        idiom = idioms[i]
                        assert idiom in src.lower(), (idiom, src)
                        label = classifier(idiom, tgt)
                        prd_label = classifier(idiom, prd)

                        if label == "paraphrase":
                            scores.append(prd_label in ["word-by-word", "copied"])
            else:    
                for t in range(1, 11):
                    with open(f"{data_type}/overgeneralisation_{data_type}_{t}/{i}.en", encoding="utf-8") as f_src, \
                         open(f"pred_{data_type}/{model}_{seed}/checkpoint{checkpoint}/overgeneralisation_{data_type}_{t}_{i}.nl", encoding="utf-8") as f_prd:
                        f_src = f_src.readlines()
                        f_prd = reorder(f_prd.readlines())

                        for src, prd in zip(f_src, f_prd):
                            idiom = idioms[i]
                            prd_label = classifier(idiom, prd)
                            scores.append(prd_label in ["word-by-word", "copied"])

            x.append(checkpoint)
            y.append(np.mean(scores))
        all_x.append(x)
        all_y.append(y)
    return all_x, all_y


if __name__ == "__main__":
    results = dict()
    for data_type in ["synthetic", "semi_natural", "natural"]:
        for size in ["tiny", "small", "all"]:
            for seed in [1, 2, 3, 4, 5]:
                print(data_type, size, seed)
                results[(size, seed, data_type)] = main(f"transformer_{size}", seed, data_type)
    pickle.dump(results, open("results.pickle", 'wb'))
