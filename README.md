# ls2_easybuild

Ubuntu container with easybuild and Lmod

Please look at [ls2](https://github.com/FredHutch/ls2) for details on how to build these Dockerfiles and how to use them to deploy the same software to a local archive.

These details differ for the EasyBuild container itself:

* Docker build command should include: `--build-arg my_prefix=/app --build-arg LMOD_VER=7.7.14 --build-arg EB_VER=3.5.0`
  * my_prefix is where EasyBuild will be installed. In our case, this is /app in a standard LS2 container and in our NFS software package archive, but you can leverage this build time argument to make a test location as well
  * LMOD_VER is the specific version of LMOD to install - use this to match LMOD version inside and outside a container
  * EB_VER is the specific version of EasyBuild to install - note that bootstrap_eb.py does not support this yet, thus we use our own patched bootstrap_eb.py
