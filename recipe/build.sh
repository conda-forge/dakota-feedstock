#!/bin/bash

mkdir -p build
cd build

if [ `uname` = "Linux" ]; then
    # -fvisibility-inlines-hidden causes trouble with dakota
    CXXFLAGS="${CXXFLAGS/-fvisibility-inlines-hidden/}"
    # there is a problem with NCSUopt when compiled with -fopenmp
    # so set the fflags manually:
    FFLAGS="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe"
    LDFLAGS="${LDFLAGS} -lrt"
fi

cmake -G "Ninja" \
      -D CMAKE_BUILD_TYPE:STRING=RELEASE \
      -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX \
      -D DAKOTA_EXAMPLES_INSTALL:PATH=$PREFIX/share/dakota \
      -D DAKOTA_TEST_INSTALL:PATH=$PREFIX/share/dakota \
      -D DAKOTA_TOPFILES_INSTALL:PATH=$PREFIX/share/dakota \
      -D DAKOTA_PYTHON:BOOL=ON \
      -D DAKOTA_PYTHON_DIRECT_INTERFACE:BOOL=ON \
      -D DAKOTA_PYTHON_DIRECT_INTERFACE_NUMPY:BOOL=ON \
      -D HAVE_X_GRAPHICS:BOOL=OFF \
      -D DAKOTA_HAVE_MPI:BOOL=ON \
      -D DAKOTA_HAVE_HDF5:BOOL=ON \
      -D HAVE_QUESO:BOOL=ON \
      -D DAKOTA_HAVE_GSL=ON \
      -D ACRO_HAVE_DLOPEN:BOOL=OFF \
      -D DAKOTA_CBLAS_LIBS:BOOL=OFF \
      -D DAKOTA_INSTALL_DYNAMIC_DEPS:BOOL=OFF \
      -D Boost_NO_BOOST_CMAKE:BOOL=ON \
      -D DAKOTA_ENABLE_TESTS:BOOL=ON \
      -D DAKOTA_PYTHON_SURROGATES:BOOL=ON \
      ..
ninja install

chmod u+x $PREFIX/share/dakota/test/dakota_test.perl
