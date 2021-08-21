#!/bin/sh
#Read input file from commandline
INPUT=$1

# locations of dict, bpe codes and model
BINDATA="data-bin-${3}"
BPE_CODES="data-bin-${3}/bpe"
MODEL=$2
#checkpoint_best.pt

#src and tgt languages
SRC='en'
TGT='nl'

# Some arguments that you may want to set
BEAM_SIZE=5
NBEST=1

# post-processing
TRANS_ONLY=true
REMOVE_PROBS=true

if $TRANS_ONLY; then
    if $REMOVE_PROBS; then
        fairseq-interactive $BINDATA --path $MODEL --beam $BEAM_SIZE --source-lang $SRC --target-lang $TGT --skip-invalid-size-inputs-valid-test --tokenizer moses --bpe subword_nmt --bpe-codes $BPE_CODES --nbest $NBEST --input $INPUT | grep "^D" | awk '{$1=$2=""; print}' | awk '{$1=$1};1'
    else
        fairseq-interactive $BINDATA --path $MODEL --beam $BEAM_SIZE --source-lang $SRC --target-lang $TGT --tokenizer moses --bpe subword_nmt --bpe-codes $BPE_CODES --nbest $NBEST --input $INPUT | grep "^D"
    fi
else
    fairseq-interactive $BINDATA --path $MODEL --beam $BEAM_SIZE --source-lang $SRC --target-lang $TGT --tokenizer moses --bpe subword_nmt --bpe-codes $BPE_CODES --nbest $NBEST --input $INPUT --distributed-world-size 1
fi

