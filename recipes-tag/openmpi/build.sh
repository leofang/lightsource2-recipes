#!/bin/bash
# copied and pasted by Leo Fang from the following commit:
# https://github.com/conda-forge/openmpi-feedstock/blob/1d6390794529ad80f5b3416fa2cb98882d1c95fa/recipe/build.sh

# unset unused old fortran flags
unset F90 F77

# this might not be needed?
export FCFLAGS="$FFLAGS"

# avoid absolute-paths in compilers
export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

if [ $(uname) == Darwin ]; then
    if [[ ! -z "$CONDA_BUILD_SYSROOT" ]]; then
        export CFLAGS="$CFLAGS -isysroot $CONDA_BUILD_SYSROOT"
        export CXXFLAGS="$CXXFLAGS -isysroot $CONDA_BUILD_SYSROOT"
    fi
    export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
fi

export LIBRARY_PATH="$PREFIX/lib"

./configure --prefix=$PREFIX \
            --disable-dependency-tracking \
            --enable-mpi-cxx \
            --enable-mpi-fortran \
            --with-sge

make -j"${CPU_COUNT:-1}"
make install
