#!/bin/bash
set -o errexit -o pipefail

# this script is meant to be used with 'datalad run'

_SNAME=$(basename "$0")

source scripts/utils.sh echo -n

mkdir -p logs/

python3 -m pip install -r scripts/requirements_torchvision.txt

# Move data files to caltech256/ as it is where torchvision looks for caltech256 raw files
mkdir -p caltech256/
git mv 256_ObjectCategories.tar caltech256/
git-annex fsck --fast caltech256/

python3 scripts/preprocess_torchvision.py \
	1>>logs/${_SNAME}.out_$$ 2>>logs/${_SNAME}.err_$$

./scripts/stats.sh caltech256/*_ObjectCategories/*/
# Protect metadata files not caught by stats.sh
chmod -R a-w caltech256/*_ObjectCategories/

# Delete raw files
git rm -rf caltech256/256_*.tar* md5sums
