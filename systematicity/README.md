# Systematicity

This folder contains the data for the systematicity tests, which is described in section 4.1 of the paper.

This folder also contains a script for evaluation ([evaluate.py](evaluate.py)), a notebook to visualise results ([visualise.ipynb](visualise.ipynb)), and a pickled file of our systematicity results for the paper.

## Systematicity setups

The systematicity test has two different setups:

### S --> S conj S
The [S --> S conj S](s_conj/) setup considers the systematic recombination of two sentences into a new sentence.
This setup has two conditions:
* Systematic recombinations of sentences that are minimally different. In this setup, the consistency of the translation of `S2` across translations of `S1 and S2` and `S1' and S2` is considered, where `S1` and `S1'` are synthetic sentences that differ in only one noun.
* Systematic recombinations of sentences that are ery different different. In this setup, the consistency of the translation of `S2` across translations of `S1 and S2` and `S3 and S2` is considered, where `S1` and `S3` are different synthetic sentences.

For this condition, three data sources are available, that can be found in the respective subfolders.
Each file contains a concatenation of a synthetic sentence template and a sentence from the indicated data source:
- [`synthetic`](synthetic/) contains three files per template (1 - 10), one with the original sentence (`S1`), one with the minimally different first sentence (`S1'`) and one with a different first sentence (`S3`). There are no target translations.
- [`semi_natural`](semi_natural/) follows the same pattern, but for semi-natural data.
- [`natural`](natural/) follows the same pattern, but for natural data.

### S --> NP VP
The [S --> NP VP](s_np_vp/) considers the systematic recombination of noun- and verb phrases.
Because this test requires control over the sentence structure and properties to ensure that the recombination is correct, this test cannot be conducted with natural data.
There are two data sources available, that can be found in the respective subfolders:
- [`synthetic`](synthetic/) contains three files per template (1 - 10), one with the original sentence, one in which a noun in the NP is adapted and one in which a noun in the VP is adapted.
- [`semi_natural`](semi_natural/) follows the same pattern, but for semi_natural data and for the NP only.


## Usage
To run the test for a specific setup and condition (`synthetic`, `semi_natural` or `natural`), use your model to translate all files in the respective folder.
After that, you can use the evaluation script to systematically compare the translations and compute consistency scores, and the visualisation notebook to visualise your results (run as is, the visualisation notebook will visualise the systematicity results from the paper).

