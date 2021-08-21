# Overgeneralisation

This folder contains the data for the overgeneralisation test described in section 4.3 of the paper.

This folder also contains a [script for evaluation](evaluate.py), a [visualisation notebook](visualise.ipynb), a [pickled file](results.pickle) with our substitutivity results for the paper and a [list of the idioms](idioms.tsv) that we considered, and their [frequency in opus](idiom_frequencies.tsv).

## Idioms

An overview can be found in the file [`idioms.tsv`](idioms.tsv), which contains four columns:
- `idiom`: the idiom itself, in multiple variations we looked for
- `english_keywords`: english words that could be used to find partial matches in OPUS. We didn't use them.
- `dutch_keywords`: potential translations of the English keyword that a model would output in a literal Dutch translation.
- `sub_clause`: the subordinate clause taken from OPUS and inserted into the synthetic and semi-natural corpora.

## Data

The three data sources are in the respective subfolders:
- `synthetic`: contains subfolders per template (1 - 10) and per subfolder 500 samples per idiom (0 - 19). There are no target translations.
- `semi_natural`: contains subfolders per template (1 - 10) and per subfolder 500 samples per idiom (0 - 19). There are no target translations.
- `natural`: contains a file per idiom (0 - 19), containing as many identical matches as we could find in OPUS, given the syntactic variation of the idioms in the idioms.tsv file. OPUS target translations are available with the extension `.nl`.

## Usage

To run the test for a specific setup and condition (`synthetic`, `semi_natural` or `natural`), use your model to translate all files in the respective folder.
After that, you can use the evaluation script to systematically compare the translations and compute consistency scores, and the visualisation notebook to visualise your results (run as is, the visualisation notebook will visualise the systematicity results from the paper).
