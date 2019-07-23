#!/bin/sh

#  upadateFramework.sh
#  Notepad
#
#  Created by han on 2019/7/12.
#  Copyright © 2019 han. All rights reserved.

lib=$1

basePath=${SRCROOT}

libOutputDir=${basePath}/${lib}

if [ ! -d "${libOutputDir}" ]; then
mkdir "${libOutputDir}"
fi

libOutputFilePath=${libOutputDir}/${TARGET_NAME}.framework/${TARGET_NAME}

echo "对外输出目录文件路径 : ${libOutputFilePath}"

#arm64 架构路径
framework_arm64=${BUILD_DIR}/${CONFIGURATION}-${PLATFORM_NAME}/${TARGET_NAME}.framework
lib_arm64=${framework_arm64}/${TARGET_NAME}

echo "arm64 架构路径 : ${framework_arm64}"

#x86_64 架构路径
framework_x86_64=${BUILD_DIR}/Debug-iphonesimulator/${TARGET_NAME}.framework
lib_x86_64=${framework_x86_64}/${TARGET_NAME}

echo "x86_64 架构路径 : ${framework_x86_64}"

#清除缓存
rm -rf "${libOutputFilePath}"

#拷贝
cp -R "${framework_arm64}" "${libOutputDir}/"

if [ ${CONFIGURATION} == "Debug" ]; then

#合并架构并输出
lipo -create ${lib_arm64} ${lib_x86_64} -output ${libOutputFilePath}

fi






