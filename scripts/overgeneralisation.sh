#!/bin/bash
#SBATCH --gres=gpu:1

source ~/.bashrc
conda activate pt

data_type=$1
model=$2
size=$3
mkdir "../overgeneralisation/pred_${data_type}"
mkdir "../overgeneralisation/pred_${data_type}/${model}"

# iterate over templates
for template in {1..10}
do
    # iterate over idioms
    for i in {0..19}
    do
        if [ "${data_type}" != "natural" ]; then
            echo $data_type
            pred_dir="../overgeneralisation/pred_${data_type}/${model}/overgeneralisation_${data_type}_${template}"
            mkdir $pred_dir
            bash generate.sh "../overgeneralisation/${data_type}/overgeneralisation_${data_type}_${template}/${i}.en" "checkpoints/${model}.pt" $size > \
                             "${pred_dir}/${i}.nl"
            wait
        elif [ "${data_type}" = "natural" ]; then
            bash generate.sh "../overgeneralisation/natural/${i}.en" "checkpoints/${model}.pt" $size > \
                             "../overgeneralisation/pred_natural/${model}/${i}.nl"
        else
            echo "Don't know data type ${data_type}"
        fi
    done
done