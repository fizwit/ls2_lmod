#!/bin/bash

# required env vars: OUT_UID, OUT_GID, DEPLOY_PREFIX

set -x
set -e

echo "LMOD_VER is ${LMOD_VER}"
echo "DEPLOY_PREFIX is ${DEPLOY_PREFIX}"

groupadd -g $OUT_GID outside_group
useradd -u $OUT_UID -g outside_group outside_user 

apt-get update -y
apt-get install -y build-essential

LMOD_CONFIGURE="--with-module-root-path=${DEPLOY_PREFIX}/modules/all \
                --with-updateSystemFn=${DEPLOY_PREFIX}/lmod/cache/last_update \
                --with-spiderCacheDir=${DEPLOY_PREFIX}/lmod/cache"

export LMOD_CONFIGURE

su -c "/bin/bash /ls2/install_lmod.sh" outside_user

mkdir ${DEPLOY_PREFIX}/lmod/cache \
&& chown $OUT_UID.$OUT_GID ${DEPLOY_PREFIX}/lmod/cache \
&& chmod g+ws ${DEPLOY_PREFIX}/lmod/cache

su -c "source ${DEPLOY_PREFIX}/lmod/lmod/init/bash \
       && ${DEPLOY_PREFIX}/lmod/lmod/libexec/update_lmod_system_cache_files ${DEPLOY_PREFIX}/modules/all" outside_user

AUTO_ADDED_PKGS=$(apt-mark showauto) apt-get remove -y --purge build-essential ${AUTO_ADDED_PKGS}
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
