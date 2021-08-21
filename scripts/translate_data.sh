#!/bin/bash

test_type=$1
data_type=$2
training_data=$3
seed=$4
checkpoint=$5
cond=$6

opref=pred_overgen

curdir=$(pwd)

if [[ $test_type == "substitutivity" && $data_type == "natural" ]]; then
    nfiles=12000
elif [[ $test_type == "systematicity" && $data_type == "natural" ]]; then
    nfiles=2000
else
    nfiles=200
fi

echo $nfiles

root=/private/home/dieuwkehupkes/nmt/compositional_mt
model_root=/checkpoint/dieuwkehupkes/mt-data/en-nl/opus-taboeta/checkpoints
model=$model_root/base_${training_data}_${seed}/checkpoint${checkpoint}.pt

if [[ $test_type == systematicity ]]; then
    data_folder=$root/${test_type}/${cond}/${data_type}
    output_folder=$root/${test_type}/${cond}/${opref}_${data_type}
    output_folder_seed=${output_folder}/transformer_${training_data}_${seed}
    output_folder_model=${output_folder_seed}/checkpoint${checkpoint}

    mkdir -p $output_folder
    mkdir -p $output_folder_seed
    mkdir -p $output_folder_model

    cd $data_folder

    echo "Test type: $test_type $cond, data type: $data_type, model: transformer $training_data $seed" 
    echo "Write outputs to $output_folder_model"

    for d in */ ; do
        echo $d
        databin=${d}${training_data}
        output_name=${d::-1}.nl
        if [[ "$d" == "${opref}"* || "$d" == "pred"* ]]; then
            echo "Skip pred folder"

        elif [[ -f ${output_folder_model}/${output_name} ]]; then
            n=$(< ${output_folder_model}/${output_name} wc -l)
            if [[ $n -ge $nfiles ]]; then
                echo "${output_folder_model}/${output_name} already exists and has $n number of lines, continue"
            else
                echo "Translate and write outputs to $output_folder_model/${output_name}"
                fairseq-generate $databin --path $model --beam 5 --remove-bpe --batch-size 256 > ${output_folder_model}/${output_name} --skip-invalid-size-inputs-valid-test 
            fi

        else
            echo "Translate and write outputs to $output_folder_model/${output_name}"
            fairseq-generate $databin --path $model --beam 5 --remove-bpe --batch-size 256 > ${output_folder_model}/${output_name} --skip-invalid-size-inputs-valid-test 
        fi
    done

elif [[ $test_type == substitutivity ]]; then

    # create output folders
    output_folder=$root/${test_type}/${opref}_${data_type}
    output_folder_seed=${output_folder}/transformer_${training_data}_${seed}
    output_folder_model=${output_folder_seed}/checkpoint${checkpoint}

    mkdir -p $output_folder
    mkdir -p $output_folder_seed
    mkdir -p $output_folder_model

    data_folder=$root/${test_type}/${data_type}/
    cd $data_folder

    if [[ $data_type == natural ]]; then
        echo "Test type: $test_type data type: $data_type, model: transformer $training_data $seed" 
        echo "Write outputs to $output_folder_model"

        for d in */ ; do
            echo $d
            databin=${d}${training_data}
            output_name=${d::-1}.nl
            echo ${output_name}
            if [[ -f ${output_folder_model}/${output_name} ]]; then
                n=$(< ${output_folder_model}/${output_name} wc -l)
                if [[ $n -ge $nfiles ]]; then
                    echo "${output_folder_model}/${output_name} exists and has $n number of lines, continue"
                else
                    echo "Translate and write outputs to $output_folder_model/${output_name}"
                    fairseq-generate $databin --path $model --beam 5 --remove-bpe --batch-size 256 > ${output_folder_model}/${output_name} --skip-invalid-size-inputs-valid-test
                fi

            elif [[ "$d" == "${opref}"*  || "$d" == "pref"* ]]; then
                echo "Skip pred folder"

            else
                echo "Translate and write outputs to $output_folder_model/${output_name}"
                fairseq-generate $databin --path $model --beam 5 --remove-bpe --batch-size 256 > ${output_folder_model}/${output_name} --skip-invalid-size-inputs-valid-test
            fi
        done

    elif [[ $data_type == semi_natural || $data_type == synthetic ]]; then

        for template in */ ; do

            cd ${data_folder}/${template}
            pwd

            echo "Test type: $test_type $template, data type: $data_type, model: transformer $training_data $seed" 
            echo "Write outputs to $output_folder_model"

            for d in */ ; do
                databin=${d}${training_data}
                output_name=${template::-1}_${d::-1}.nl
                n=$(< ${output_folder_model}/${output_name} wc -l)
                if [[ -f ${output_folder_model}/${output_name} && $n -ge $nfiles ]]; then
                    echo "${output_folder_model}/${output_name} exists and has $n number of lines, continue"
                else
                    echo "Translate and write outputs to $output_folder_model/${output_name}"
                    fairseq-generate $databin --path $model --beam 5 --remove-bpe --batch-size 256 > ${output_folder_model}/${output_name} --skip-invalid-size-inputs-valid-test
                fi
            done
        done
    fi

elif [[ $test_type == overgeneralisation ]]; then

    # create output folders
    output_folder=$root/${test_type}/${opref}${data_type}
    output_folder_seed=${output_folder}/transformer_${training_data}_${seed}
    output_folder_model=${output_folder_seed}/checkpoint${checkpoint}

    mkdir -p $output_folder
    mkdir -p $output_folder_seed
    mkdir -p $output_folder_model

    data_folder=$root/${test_type}/${data_type}
    cd $data_folder

    if [[ $data_type == natural ]]; then
        echo "Test type: $test_type data type: $data_type, model: transformer $training_data $seed" 
        echo "Write outputs to $output_folder_model"

        for d in */ ; do
            databin=${d}${training_data}
            output_name=${d::-1}.nl
            n=$(< ${output_folder_model}/${output_name} wc -l)
            if [[ -f ${output_folder_model}/${output_name} && $n -ge $nfiles ]]; then
                echo "${output_folder_model}/${output_name} exists and has $n number of lines, continue"
            elif [[ "$d" == "${opref}"* ]]; then
                echo "Skip pred folder"
            else
                echo "Translate and write outputs to $output_folder_model/${output_name}"
                fairseq-generate $databin --path $model --beam 5 --remove-bpe --batch-size 256 > ${output_folder_model}/${output_name} --skip-invalid-size-inputs-valid-test
            fi
        done

    elif [[ $data_type == semi_natural || $data_type == synthetic ]]; then

        for template in */ ; do

            cd ${data_folder}/$template

            echo "Test type: $test_type $template, data type: $data_type, model: transformer $training_data $seed" 
            echo "Write outputs to $output_folder_model"

            for d in */ ; do
                databin=${d}${training_data}
                output_name=${template::-1}_${d::-1}.nl
                n=$(< ${output_folder_model}/${output_name} wc -l)
                if [[ -f ${output_folder_model}/${output_name} && $n == 2000 ]]; then
                    echo "${output_folder_model}/${output_name} exists and has $n number of lines, continue"
                else
                    echo "Translate and write outputs to $output_folder_model/${output_name}"
                    fairseq-generate $databin --path $model --beam 5 --remove-bpe --batch-size 256 > ${output_folder_model}/${output_name} --skip-invalid-size-inputs-valid-test
                fi
            done
        done
    fi

else
    echo "Unknown test"
fi

