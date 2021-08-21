#!/bin/bash

setup=$1
model="checkpoints/${2}.pt"
size=$3
data_type=$4

for num in {1..10}
do
    mkdir "../systematicity/${setup}/pred_${data_type}"
    pred_dir="../systematicity/${setup}/pred_${data_type}/${2}"
    mkdir ${pred_dir}
    pred_file="${pred_dir}/systematicity_${data_type}_${num}"

    if [ "${setup}" = "s_conj" ]; then
        data_dir="../systematicity/${setup}/${data_type}/systematicity_${data_type}_${num}"

        bash generate.sh "${data_dir}_s1_s2.en" $model $size > "${pred_file}_s1_s2.nl"
        wait

        bash generate.sh "${data_dir}_s1p_s2.en" $model $size > "${pred_file}_s1p_s2.nl"
        wait

        bash generate.sh "${data_dir}_s3_s2.en" $model $size > "${pred_file}_s3_s2.nl"
        wait

    elif [ "${setup}" = "s_np_vp" ]; then
        data_dir="../systematicity/${setup}/${data_type}/systematicity_${data_type}_${num}"

        bash generate.sh "${data_dir}_np.en" $model $size > "${pred_file}_np.nl"
        wait

        bash generate.sh "${data_dir}_np_prime.en" $model $size > "${pred_file}_np_prime.nl"
        wait
        if [ "${data_type}" = "synthetic" ]; then
            bash generate.sh "${data_dir}_vp_prime.en" $model $size > "${pred_file}_vp_prime.nl"
            wait
        fi
    else
        echo "Setup ${setup} is unkown."
    fi
done