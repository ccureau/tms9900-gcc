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

# A more detailed example, including libti99

There is a little setup necessary to prepare to use this container as your compiler. You should only need to do this setup once. As long as you follow the recipe afterwards, your compilation will work just as it would if the compiler was natively installed.

First, set up a directory tree to use for this image.  I used $HOME/ti

    export TI99_DIR=$HOME/ti99
   
Unpack and build libti99. The important bits to note here are:

*-e* sets the variables that libti99 needs to build properly

*-v* maps your TI99_DIR to /src inside of the container

*-w* sets the working directory to /src in the container when the container starts


    git clone https://github.com/tursilion/libti99.git $TI99_DIR
    docker run --rm -v $TI99_DIR:/src \
        -e TMS9900_DIR=/opt/tms9900/gcc-4.4.0/bin \
        -e ELF2EA5_DIR=/opt/tms9900/gcc-4.4.0/bin \
        -e EA5_SPLIT_DIR=/opt/tms9900/gcc-4.4.0/bin \
        -w /src \
        cmcureau/tms9900-gcc make
        
You now have libti99.a available for use. You will see an error that you can safely ignore -- these are tests that are supposed to happen after the library is built.

To create a new project, just start a new directory and add your source files

    mkdir $TI99_DIR/mycoolproject
    docker run --rm -v $TI99_DIR:/src/ \
        -w $TI99_DIR/mycoolproject \
        cmcureau/tms9900-gcc make
        
 # An example Makefile for projects

    CC=tms9900-gcc
    AS=tms9900-gas
    LD=tms9900-ld
    CFLAGS=-I/src/libti99
    LDFLAGS=-L/src/libti99

    %.o: %.c
	    $(CC) -c -o $@ $< $(CFLAGS)

    sounds: main.o
	    $(LD) -o sounds main.o $(LDFLAGS) -lti99
        
 

        
        
