#!/bin/bash

binfolder=$1

curdir=$(pwd)

cd $binfolder

rm *.bpe.*
rm *.tok.*

echo "Tokenise all files in $binfolder"
# tokenise all files

for f in *.en; do
    filepref=${f::-3}
    /private/home/dieuwkehupkes/mosesdecoder/scripts/tokenizer/tokenizer.perl \
    -q -l en - threads 8 < $f > ${filepref}.tok.en
done

for file in *tok.en
do
    filepref=${file::-3}
    write_folder=${file::-7}

    if [[ "$filepref" != *bpe* ]]; then
        if ! [ -f "${filepref}.tok.bpe.60000.en" ]; then
            # apply bpe
            echo "Compute bpe codes"
            /private/home/dieuwkehupkes/subword-nmt/subword_nmt/apply_bpe.py -c /checkpoint/dieuwkehupkes/mt-data/en-nl/opus-taboeta/bpe.60000  < $file > ${filepref}.bpe.60000.en
        fi

        rm -r ${write_folder}/
        mkdir -p ${write_folder}/

        echo "Preprocess data for $binfolder, $filepref with fairseq-preprocess for tiny small all "
        for data_size in tiny small all
        do
            if ! [[ -f ${write_folder}/${data_size} ]]; then
                dict=/checkpoint/dieuwkehupkes/mt-data/en-nl/opus-taboeta/data-bin-${data_size}/dict.en.txt

                # preprocess
                fairseq-preprocess \
                --only-source \
                --source-lang en \
                --target-lang nl \
                --testpref ${filepref}.bpe.60000 \
                --srcdict $dict \
                --destdir ${write_folder}/${data_size}/ \
                --joined-dictionary \
                --workers 20

                cp $dict ${write_folder}/${data_size}/dict.nl.txt
            fi
        done
    fi
done

cd $curdir
