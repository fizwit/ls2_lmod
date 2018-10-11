# ls2_lmod

Please look at [ls2](https://github.com/FredHutch/ls2) for details on how to build these Dockerfiles and how to use them to deploy the same software to a local archive.

* This container adds Lmod
* This container depends on ls2_ubuntu with lua installed
* The next container in the ls2 hierarchy is ls2_easybuild

ls2_lmod is a building block in the Life Science Software container hierarchy. 
ls2 build process: ```ls2_ubuntu -> ls2_lmod -> ls2_easybuild -> ls2_easybuild_toolchain -> ls2_YourPackage```

## Building this container

Build this container with:

`docker build . --tag fredhutch/ls2_lmod:7.8 --build-arg LMOD_VER=7.8`

Note that `LMOD_VER` has no default value and not setting it will cause the build to fail.
The default DEPLOY_PREFIX is /app use --build-arg DEPLOY_PREFIX=/yourPrefix if you want to change the deploy prefix.

