#!/bin/bash

mkdir -p build
cd build

if [ `uname` = "Linux" ]; then
    # there is a problem with NCSUopt when compiled with -fopenmp
    # so set the fflags manually:
    FFLAGS="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe"
    EXTRA_ARGS=()
else
    EXTRA_ARGS=(
        "-D HAVE_ACRO:BOOL=FALSE"
        )
fi

cmake -D CMAKE_BUILD_TYPE:STRING=RELEASE \
      -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX \
      -D DAKOTA_EXAMPLES_INSTALL:PATH=$PREFIX/share/dakota \
      -D DAKOTA_TEST_INSTALL:PATH=$PREFIX/share/dakota \
      -D DAKOTA_TOPFILES_INSTALL:PATH=$PREFIX/share/dakota \
      -D DAKOTA_PYTHON:BOOL=ON \
      -D DAKOTA_PYTHON_NUMPY:BOOL=ON \
      -D HAVE_X_GRAPHICS:BOOL=OFF \
      -D DAKOTA_HAVE_MP:BOOL=ON \
      -D HAVE_QUESO:BOOL=ON \
      -D DAKOTA_HAVE_GSL=ON \
      -D ACRO_HAVE_DLOPEN:BOOL=OFF \
      -D DAKOTA_CBLAS_LIBS:BOOL=OFF \
      -D DAKOTA_INSTALL_DYNAMIC_DEPS:BOOL=OFF \
      -D Boost_NO_BOOST_CMAKE:BOOL=ON \
      -D DAKOTA_ENABLE_TESTS:BOOL=OFF \
      -D Trilinos_SKIP_FORTRANCINTERFACE_VERIFY_TEST:BOOL=ON \
      ${EXTRA_ARGS[@]} ..


make -j${CPU_COUNT} install
