#!/bin/bash

test=$1
model=$2
size=$3
echo $test
if [ "${test}" = "systematicity" ]; then

    # Systematicity
    echo "YEs"
    # S -> S CONJ S
    sbatch -o traces/systematicity_s_conj_${model}_synthetic.out systematicity.sh s_conj $model $size synthetic
    sbatch -o traces/systematicity_s_conj_${model}_semi_natural.out systematicity.sh s_conj $model $size semi_natural
    sbatch -o traces/systematicity_s_conj_${model}_natural.out systematicity.sh s_conj $model $size natural

    # S -> NP VP
    sbatch -o traces/systematicity_s_np_vp_${model}_synthetic.out systematicity.sh s_np_vp $model $size synthetic
    sbatch -o traces/systematicity_s_np_vp_${model}_semi_natural.out systematicity.sh s_np_vp $model $size semi_natural

elif [ "${test}" = "substitutivity" ]; then

    # Substitutivity
    sbatch -o traces/substitutivity_${model}_synthetic.out substitutivity.sh synthetic $model $size
    sbatch -o traces/substitutivity_${model}_semi_natural.out substitutivity.sh semi_natural $model $size
    sbatch -o traces/substitutivity_${model}_natural.out substitutivity.sh natural $model $size

elif [ "${test}" = "overgeneralisation" ]; then

    # Overgeneralisation
    sbatch -o traces/overgeneralisation_${model}_synthetic.out overgeneralisation.sh synthetic $model $size
    sbatch -o traces/overgeneralisation_${model}_semi_natural.out overgeneralisation.sh semi_natural $model $size
    sbatch -o traces/overgeneralisation_${model}_natural.out overgeneralisation.sh natural $model $size


fi