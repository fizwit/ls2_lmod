FROM fredhutch/ls2_ubuntu:16.04_20180126
# Remember, default user is LS2_USERNAME, not root

# These must be specified
ARG LMOD_VER
ENV LMOD_VER=${LMOD_VER}

# This should only be specified if you are deploying outside the container
ARG DEPLOY_PREFIX=/app
ENV DEPLOY_PREFIX=${DEPLOY_PREFIX}

# copy in scripts and files
COPY install_lmod.sh /ls2/
COPY deploy_lmod.sh /ls2/

# OS Packages
#   Our Environment Modules implementation, Lmod, needs lua
USER root
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
    lua5.2 \
    lua-posix \
    lua-filesystem \
    lua-term 

# Install directory
# run as root as LS2_USER likely has not permission to parent dir
RUN mkdir ${DEPLOY_PREFIX} && chown ${LS2_UID}.${LS2_GID} ${DEPLOY_PREFIX}

# install and uninstall build-essential in one step to reduce layer size
# while installing Lmod, again must be root
RUN apt-get install -y build-essential \
    && apt-get install -y libnet-ssleay-perl \
    && su -c "/bin/bash /ls2/install_lmod.sh" ${LS2_USERNAME} \
    && AUTO_ADDED_PKGS=$(apt-mark showauto) apt-get remove -y --purge build-essential ${AUTO_ADDED_PKGS} \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# gather installed pkgs list
RUN dpkg -l > /ls2/installed_pkgs.lmod

# switch to LS2 user for future actions
USER ${LS2_USERNAME}
WORKDIR /home/${LS2_USERNAME}
SHELL ["/bin/bash", "-c"]

