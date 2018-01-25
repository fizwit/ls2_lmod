FROM fredhutch/ls2_ubuntu:16.04_20180116

# These must be specified
ARG LMOD_VER
ENV LMOD_VER=${LMOD_VER}

# This should only be specified if you are deploying outside the container
ARG DEPLOY_PREFIX=/app
ENV DEPLOY_PREFIX=${DEPLOY_PREFIX}

# These have reasonable defaults - only change if you really need to
ARG LS2_USERNAME=neo
ENV LS2_USERNAME=${LS2_USERNAME}
ARG LS2_GROUPNAME=neo
ENV LS2_GROUPNAME=${LS2_GROUPNAME}
ARG LS2_UID=500
ENV LS2_UID=${LS2_UID}
ARG LS2_GID=500
ENV LS2_GID=${LS2_GID}

# OS Packages
#   EasyBuild needs Python, and an Environment Modules implementation
#   Our Environment Modules implementation, Lmod, needs lua
#   Apparently with EasyBuild using https urls for download, it needs ssl
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
    lua5.2 \
    lua-posix \
    lua-filesystem \
    lua-term 

# User
#   EasyBuild does not build as root, so we make a user
RUN groupadd -g ${LS2_GID} ${LS2_GROUPNAME} && useradd -u ${LS2_UID} -g ${LS2_GROUPNAME} -ms /bin/bash ${LS2_USERNAME}

# Install directory
RUN mkdir ${DEPLOY_PREFIX} && chown ${LS2_UID}.${LS2_GID} ${DEPLOY_PREFIX}

# copy in scripts and files
RUN mkdir /home/${LS2_USERNAME}/.ls2/
COPY install_lmod.sh /home/${LS2_USERNAME}/.ls2/
COPY install_easybuild.sh /home/${LS2_USERNAME}/.ls2/
COPY bootstrap_eb.py /home/${LS2_USERNAME}/.ls2/
COPY eb_module_footer /home/${LS2_USERNAME}/.ls2/
RUN chown -R ${LS2_USERNAME}.${LS2_GROUPNAME} /home/${LS2_USERNAME}/.ls2

# install and uninstall build-essential in one step to reduce layer size
# while installing Lmod
RUN apt-get install -y build-essential && \
    su -c "DEPLOY_PREFIX=${DEPLOY_PREFIX} LMOD_VER=${LMOD_VER} LS2_USERNAME=${LS2_USERNAME} /bin/bash /home/${LS2_USERNAME}/.ls2/install_lmod.sh" - ${LS2_USERNAME} && \
    su -c "DEPLOY_PREFIX=${DEPLOY_PREFIX} EB_VER=${EB_VER} LS2_USERNAME=${LS2_USERNAME} /bin/bash /home/${LS2_USERNAME}/.ls2/install_easybuild.sh" - ${LS2_USERNAME} && \
    AUTO_ADDED_PKGS=$(apt-mark showauto) apt-get remove -y --purge build-essential ${AUTO_ADDED_PKGS} && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# switch to LS2 user for future actions
USER ${LS2_USERNAME}
WORKDIR /home/${LS2_USERNAME}
SHELL ["/bin/bash", "-c"]
