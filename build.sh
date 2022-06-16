#!/bin/bash

pathtoclang=/root/clang
pathtogcc64=/root/aarch64-linux-android-4.9
pathtogcc32=/root/arm-linux-androideabi-4.9
pathpack=/root/kernel/hanoip
path=/root
SF=
CUSTOM_DATE_YEAR="$(date -u +%Y)"
CUSTOM_DATE_MONTH="$(date -u +%m)"
CUSTOM_DATE_DAY="$(date -u +%d)"
CUSTOM_DATE_HOUR="$(date -u +%H)"
CUSTOM_DATE_MINUTE="$(date -u +%M)"
CUSTOM_BUILD_DATE="$CUSTOM_DATE_YEAR""$CUSTOM_DATE_MONTH""$CUSTOM_DATE_DAY"-"$CUSTOM_DATE_HOUR""$CUSTOM_DATE_MINUTE"

cd $path
git clone https://github.com/RaghuVarma331/aarch64-linux-android-4.9.git -b master --depth=1 aarch64-linux-android-4.9
git clone https://github.com/RaghuVarma331/clang.git -b android-12.0 --depth=1 clang
git clone https://github.com/RaghuVarma331/arm-linux-androideabi-4.9.git -b master arm-linux-androideabi-4.9 --depth=1
cd $path/kernel
clear
make O=out ARCH=arm64 hanoip_defconfig
PATH=$pathtoclang/bin:$pathtogcc64/bin:$pathtogcc32/bin:${PATH} \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE=aarch64-linux-android- \
                      CROSS_COMPILE_ARM32=arm-linux-androideabi-
cp -r out/arch/arm64/boot/Image.gz $pathpack
cp -r out/arch/arm64/boot/dts/qcom/sdmmagpie-hanoi-base.dtb $pathpack
cp -r out/arch/arm64/boot/dtbo.img  $pathpack
cd $pathpack
mv sdmmagpie-hanoi-base.dtb dtb
7z a BLACK_CAPS-12L-hanoip-kernel-$CUSTOM_BUILD_DATE.zip *
sshpass -p $SF rsync -avP -e ssh ***.zip  raghuvarma331@frs.sourceforge.net:/home/frs/project/motorola-sm6150/G60/BLACK-CAPS
rm -r ***.zip Image.gz dtb dtbo.img
cd $path/kernel
rm -r out
