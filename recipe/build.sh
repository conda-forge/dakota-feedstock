#!/usr/bin/env bash
set -euxo pipefail

if [[ "${target_platform}" == linux-* ]]; then
    # -fvisibility-inlines-hidden causes trouble with dakota
    export CXXFLAGS="${CXXFLAGS/-fvisibility-inlines-hidden/}"
    # NCSUopt fails when compiled with -fopenmp
    export FFLAGS="${FFLAGS/-fopenmp/}"
    export FFLAGS="${FFLAGS/-fopenmp=libgomp/}"
    export LDFLAGS="${LDFLAGS} -lrt"
fi

cmake -S . -B build -G Ninja \
      ${CMAKE_ARGS} \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_LIBDIR=lib \
      -D BUILD_SHARED_LIBS=ON \
      -D Python3_EXECUTABLE="${PYTHON}" \
      -D PYTHON_EXECUTABLE="${PYTHON}" \
      -D DAKOTA_EXAMPLES_INSTALL=share/dakota \
      -D DAKOTA_TEST_INSTALL=share/dakota \
      -D DAKOTA_TOPFILES_INSTALL=share/dakota \
      -D DAKOTA_PYTHON=ON \
      -D DAKOTA_PYTHON_DIRECT_INTERFACE=ON \
      -D DAKOTA_PYTHON_DIRECT_INTERFACE_NUMPY=ON \
      -D DAKOTA_PYTHON_SURROGATES=ON \
      -D DAKOTA_PYTHON_WRAPPER=ON \
      -D HAVE_X_GRAPHICS=OFF \
      -D DAKOTA_HAVE_MPI=ON \
      -D DAKOTA_HAVE_HDF5=ON \
      -D HDF5_ROOT="${PREFIX}" \
      -D HAVE_QUESO=ON \
      -D DAKOTA_HAVE_GSL=ON \
      -D DAKOTA_CBLAS_LIBS="${PREFIX}/lib/libcblas${SHLIB_EXT}" \
      -D ACRO_HAVE_DLOPEN=OFF \
      -D DAKOTA_INSTALL_DYNAMIC_DEPS=OFF \
      -D CMAKE_POLICY_DEFAULT_CMP0167=NEW \
      -D Boost_NO_SYSTEM_PATHS=ON \
      -D BOOST_ROOT="${PREFIX}" \
      -D Eigen3_DIR="${PREFIX}/share/eigen3/cmake" \
      -D DAKOTA_ENABLE_TESTS=ON \
      -D BLAS_LIBS="${PREFIX}/lib/libblas${SHLIB_EXT}" \
      -D LAPACK_LIBS="${PREFIX}/lib/liblapack${SHLIB_EXT}"

cmake --build build --config Release
cmake --install build --prefix "${PREFIX}"

# dakota_test.perl is invoked directly during tests
if [[ -f "${PREFIX}/share/dakota/test/dakota_test.perl" ]]; then
    sed -i '1s|^#! */usr/bin/perl|#!/usr/bin/env perl|' "${PREFIX}/share/dakota/test/dakota_test.perl"
    chmod u+x "${PREFIX}/share/dakota/test/dakota_test.perl"
fi

# Upstream installs the Python package under share/dakota/Python.
# Copy it onto the default module path so `import dakota` works without PYTHONPATH.
if [[ -d "${PREFIX}/share/dakota/Python/dakota" ]]; then
    mkdir -p "${SP_DIR}"
    rm -rf "${SP_DIR}/dakota"
    cp -a "${PREFIX}/share/dakota/Python/dakota" "${SP_DIR}/dakota"
fi
