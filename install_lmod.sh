#!/bin/bash

set -x
set -e

echo "Downloading Lmod..."
curl -L -o /home/${LS2_USERNAME}/.ls2/Lmod-${LMOD_VER}.tar.gz https://github.com/TACC/Lmod/archive/${LMOD_VER}.tar.gz

echo "Extracting Lmod..."
tar -xzf /home/${LS2_USERNAME}/.ls2/Lmod-${LMOD_VER}.tar.gz

echo "Building Lmod..."
cd Lmod-${LMOD_VER}
./configure --prefix=${DEPLOY_PREFIX} --with-tcl=no
make install
cd ..
rm -r Lmod-${LMOD_VER}

