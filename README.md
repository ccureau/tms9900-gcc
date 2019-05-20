# tms9900-gcc

Dockerized GCC cross compiler built for the TI TMS9900 (TI99/4A family and others)

[`cmcureau/tms9900-gcc` on Docker Hub](https://hub.docker.com/r/cmcureau/tms9900-gcc/)

Adapted from [insomnia's fine work on adding the TMS9900 target to the GNU toolchain](http://atariage.com/forums/topic/164295-gcc-for-the-ti/).

## Introduction
All of the standard utilities (gcc, gas, etc) are prefixed with **tms9900-** to differentiate them from their native counterparts. This means that your build scripts need to call tms9900-gcc, tms9900-gas, etc.

The compiler builds a ELF 32-bit executable which can be run directly on TMS9900 hardware.

## Usage
To build your source, simply run the appropriate commands inside the container: 

    docker run --rm \
      -v ${PWD}:/source \
      -w /source \
      make

Alternatively, create a shell script to do all the things:

    #!/bin/bash
    
    PREFIX=tms9900-
    
    # pull the latest docker image
    docker pull cmcureau/tms9900-gcc
    
    # start the build
    docker run --rm -v ${PWD}:/source -w /source gcc -o mycoolapp mycoolapp.c
