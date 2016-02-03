#!/bin/bash -vex

: WORKSPACE ${WORKSPACE:=$PWD}

CORES=$(nproc || grep -c ^processor /proc/cpuinfo || sysctl -n hw.ncpu)
echo Building on $CORES cpus...

OPTIONS="--enable-rpath --disable-elf-tls --disable-docs"
TARGETS="x86_64-apple-darwin,i686-apple-darwin"

PREFIX=${WORKSPACE}/rustc

mkdir -p ${WORKSPACE}/gecko-rust-mac
pushd ${WORKSPACE}/gecko-rust-mac

export MACOSX_DEPLOYMENT_TARGET=10.7
${WORKSPACE}/rust/configure --prefix=${PREFIX} --target=${TARGETS} ${OPTIONS}
make -j ${CORES}

rm -rf ${PREFIX}
mkdir ${PREFIX}
make install
popd

# Package the toolchain for upload.
# We build separate packages for the compiler itself and the standard
# libraries for cross-compiles.
pushd ${WORKSPACE}
tar cvjf rustc.tar.bz2 rustc/bin/* rustc/share/*
tar cvjf rust-stdlib.tar.bz2 rustc/lib/rustlib/*
python tooltool.py add --visibility=public --unpack rustc.tar.bz2 rust-stdlib.tar.bz2
popd
