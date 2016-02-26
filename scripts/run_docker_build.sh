#!/usr/bin/env bash

# NOTE: This script has been adapted from content generated by github.com/conda-forge/conda-smithy

REPO_ROOT=$(cd "$(dirname "$0")/.."; pwd;)
IMAGE_NAME="ericdill/nsls2debian79"

config=$(cat <<CONDARC

channels:
 - lightsource2-dev
 - lightsource2
 - conda-forge
 - defaults

always_yes: true
show_channel_urls: True

CONDARC
)

cat << EOF | docker run -i \
                        -v ${REPO_ROOT}/py2:/py2-recipes \
                        -v ${REPO_ROOT}/py2:/py3-recipes \
                        -v ${REPO_ROOT}/py2:/pyall-recipes \
                        -a stdin -a stdout -a stderr \
                        $IMAGE_NAME \
                        bash || exit $?

if [ "${BINSTAR_TOKEN}" ];then
    export BINSTAR_TOKEN=${BINSTAR_TOKEN}
fi

# Unused, but needed by conda-build currently... :(
export CONDA_NPY='19'

export PYTHONUNBUFFERED=1
echo "$config" > ~/.condarc

# A lock sometimes occurs with incomplete builds. The lock file is stored in build_artefacts.
conda clean --lock

conda remove conda-build
pip uninstall --yes conda-build conda-build-all
# pip install https://github.com/conda/conda-build/zipball/master#egg=conda-build
# git clone https://github.com/ericdill/conda-build
# cd conda-build-all
# git checkout silence-git-errors
# python setup.py develop
pip install https://github.com/ericdill/conda-build/zipball/silence-git-errors#egg=conda-build
pip install https://github.com/SciTools/conda-build-all/zipball/master#egg=conda-build-all
conda info
unset LANG

# These are some standard tools. But they aren't available to a recipe at this point (we need to figure out how a recipe should define OS level deps)
#yum install -y expat-devel git autoconf libtool texinfo check-devel

# These were specific to installing matplotlib. I really want to avoid doing this if possible, but in some cases it
# is inevitable (without re-implementing a full OS), so I also really want to ensure we can annotate our recipes to
# state the build dependencies at OS level, too.

echo "

===== BUILDING PY2 =====

"
conda-build-all /py2-recipes --upload-channels lightsource2-dev --matrix-conditions "numpy >=1.10" "python >=2.7,<3" --inspect-channels lightsource2-dev
echo "

===== BUILDING PY3 =====

"
conda-build-all /py3-recipes --upload-channels lightsource2-dev --matrix-conditions "numpy >=1.10" "python >=3.4" --inspect-channels lightsource2-dev

echo "

===== BUILDING PY2&PY3 =====

"
conda-build-all /pyall-recipes --upload-channels lightsource2-dev --matrix-conditions "numpy >=1.10" "python >=2.7,<3|>=3.4" --inspect-channels lightsource2-dev

EOF

