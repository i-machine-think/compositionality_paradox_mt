# Substitutivity

This folder contains the data for the substitutivity test described in section 4.2 of the paper.

This folder also contains a [script for evaluation](evaluate.py), a [visualisation notebook](visualise.ipynb), a [pickled file](results.pickle) with our substitutivity results for the paper and a [list of the synonyms](synonyms.tsv) that we considered and their [frequency in OPUS](synonym_frequencies.tsv).

## Synonyms

To find synonyms, we exploit the fact that OPUS is a collection of corpora that contains both American and British English texts.
We consider two different type of synonyms:

* The same terms that are spelled (slightly) differently, fetched from <http://www.tysto.com/uk-us-spelling-list.html> and <https://en.wikipedia.org/wiki/American_and_British_English_spelling_differences#-re,_-er>
* Different terms that are used to describe the same concept, according to the Oxford dictionary: <https://www.lexico.com/grammar/british-and-american-terms>

The synonyms that we used in our test can be found in the file [synonyms.tsv](synonyms.tsv), which contains these columns:
- `en1`: the British English term.
- `en2`: the American English term.
- `nl`: Dutch translation.
- `singular`: subordinate clause inserted for a singular noun.
- `plural`: subordinate clause inserted for a plural noun.
- `model_translations1`: possible synonym translations that the models can have for en1.
- `model_translations2`: possible synonym translations that the models can have for en2.

## Data 

The three data sources are in the respective subfolders, with file pairs that contain the same sentences with one synonym replaced:
- [`synthetic`](synthetic/) contains subfolders per template (1 - 10) and per subfolder per synonym pair (0 - 19) two files with 500 samples. There are no target translations.
- [`semi_natural`](semi_natural/) contains subfolders per template (1 - 10) and per subfolder per synonym pair (0 - 19) two files with 500 samples. There are no target translations.
- [`natural`](natural/) contains two English and one Dutch file per synonym pair (0 - 19).

## Usage

To run the test for a specific setup and condition (`synthetic`, `semi_natural` or `natural`), use your model to translate all files in the respective folder.
After that, you can use the evaluation script to compute consistency scores, and the visualisation notebook to visualise your results (run as is, the visualisation notebook will visualise the substitutivity results from the paper).
