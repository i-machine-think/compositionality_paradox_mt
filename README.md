# The paradox of the compositionality of natural language: a neural machine translation case study

This repository contains the data and evaluation scripts for the following paper:
```
@inproceedings{dankers2022paradox,
  title={The Paradox of the Compositionality of Natural Language: A Neural Machine Translation Case Study},
  author={Dankers, Verna and Bruni, Elia and Hupkes, Dieuwke},
  booktitle={Proceedings of the 60th Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers)},
  pages={4154--4175},
  year={2022}
}
```

In this paper, we present tests to evaluate compositionality "in the wild". As a case study, we consider the compositional behaviour of English-Dutch NMT models.
This repository contains five folders, with their own READMEs:

- [`data`](data/): this folder contains the generated src files for the data types of synthetic and semi-natural that form the backbone of our tests, along with the vocabulary used to generate the synthetic data templates.
- [`overgeneralisation`](overgeneralisation/): this folder contains synthethic, semi-natural and natural data with idioms, used to assess if a model overgeneralises or provides an idiomatic translation.
- [`substitutivity`](substitutivity/): this folder contains English data with synonym replacements for the synthetic, semi-natural and natural data templates.
- [`systematicity`](systematicity/): this folder contains synthetic and semi-natural data used to assess systematicity of recombinations of noun and verb phrases ([`s_np_vp`](systematicity/s_np_vp/)) and sentences with a conjunction ([`s_conj`](systematicity/s_conj/)). For the latter setup, there is natural data too.
- [`scripts`](scripts/): This folder contains various scripts that facilitate using the data.

### Usage

* If you are curious about our synthetic, semi-natural and natural data sources (see Section 3 of the paper), go to  the [`data`](data/) folder.
* If you are looking to run a specific test, go to the folder of the experiment of interest:
    1. For Section 4.1 / systematicity, go to [`systematicity`](systematicity/).
    2. For Section 4.2 / substitutivity, go to [`substitutivity`](substitutivity/).
    3. For Section 4.2 / global compositionality, go to [`overgeneralisation`](overgeneralisation/).
* If you would like to use our evaluation or visualisation scripts, go to [`scripts`](scripts).

Note that the models referred to as small, medium and full in the paper are referred to as tiny, small, all in the repository.
