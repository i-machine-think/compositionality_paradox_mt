#!/bin/bash

data_type=$1
model=$2
size=$3

mkdir "../substitutivity/pred_${data_type}/${model}"

# iterate over templates
for template in {1..10}
do
    # iterate over synonyms
    for i in {0..19}
    do
        if [ "${data_type}" != "natural" ]; then
            echo $data_type
            pred_dir="../substitutivity/pred_${data_type}/${model}/substitutivity_${data_type}_${template}"
            mkdir $pred_dir
            bash generate.sh "../substitutivity/${data_type}/substitutivity_${data_type}_${template}/${data_type}-1.en" "checkpoints/${model}.pt" $size > \
                             "${pred_dir}/pred_${i}-1.nl"
            wait
            bash generate.sh "../substitutivity/${data_type}/substitutivity_${data_type}_${template}/${i}-2.en" "checkpoints/${model}.pt" $size > \
                             "${pred_dir}/pred_${i}-2.nl"
            wait
        elif [ "${data_type}" = "natural" ]; then
            bash generate.sh "../substitutivity/natural/${i}-1.en" "checkpoints/${model}.pt" $size > \
                             "../substitutivity/pred_natural/${model}/pred_${i}-1.nl"
            bash generate.sh "../substitutivity/natural/${i}-2.en" "checkpoints/${model}.pt" $size > \
                             "../substitutivity/pred_natural/${model}/pred_${i}-2.nl"
            wait
        else
            echo "Don't know data type ${data_type}"
        fi
    done
done