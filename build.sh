#!/bin/bash
set -e

TOOLCHAIN_PATH=$HOME/prelude-clang/bin
echo "TOOLCHAIN_PATH: [$TOOLCHAIN_PATH]"
export PATH="$TOOLCHAIN_PATH:$PATH"
export CCACHE_DIR="$HOME/.cache/ccache_mi9kernel" 
export PATH="/usr/lib/ccache:$PATH"
echo "CCACHE_DIR: [$CCACHE_DIR]"

MAKE_ARGS="AS=as LD=ld.lld ARCH=arm64 SUBARCH=arm64 O=out CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- CROSS_COMPILE_COMPAT=arm-linux-gnueabi- CLANG_TRIPLE=aarch64-linux-gnu-"

echo "[clang --version]:"
clang --version

make CC="ccache clang" CXX="ccache clang++" $MAKE_ARGS cepheus_defconfig

make CC="ccache clang" CXX="ccache clang++" $MAKE_ARGS -j$(nproc)

sleep 2
rm -rf out/repack; 
mkdir out/repack; sleep 2
echo "Repacking..."
unzip release.zip -d out/repack
cp out/arch/arm64/boot/Image out/repack/Image
cd out/repack; zip -r kernel.zip *; cd ../../
md5=$(md5sum out/repack/kernel.zip | cut -c1-8)
mv out/repack/kernel.zip anykernel3_cepheus_$(date +%Y%m%d)_$md5.zip
