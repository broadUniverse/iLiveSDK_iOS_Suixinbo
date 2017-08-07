#!/bin/sh
#

# 加载各个模块SDK
# 版本号如下
echo "|-------------------------------sdk version--------------------------------|"
ILiveSDKVersion="ILiveSDK_1.6.0.11371"
IMSDKSDKVersion="IMSDK_2.5.6.11082.11081"
AVSDKVersion="AVSDK_1.9.2.17_28736"
QAVEffectVersion="QAVEffect"

#清除现有文件
echo "|-------------------------------clear sdk dir...--------------------------------|"
ls |grep -v LoadSDK.sh |xargs rm -rf
#rm -rf !(down.sh|test.sh)

#下载sdk zip文件
echo "|-------------------------------download AVSDK----------------------------------|"
curl -o AVSDK.zip "http://dldir1.qq.com/hudongzhibo/ILiveSDK/$AVSDKVersion.zip" --retry 5
echo "|-------------------------------download QAVEffect------------------------------|"
curl -o QAVEffect.zip "http://dldir1.qq.com/hudongzhibo/ILiveSDK/$QAVEffectVersion.zip" --retry 5
echo "|-------------------------------download IMSDK----------------------------------|"
curl -o IMSDK.zip "http://dldir1.qq.com/hudongzhibo/ILiveSDK/$IMSDKSDKVersion.zip" --retry 5
echo "|-------------------------------download ILiveSDK-------------------------------|"
curl -o ILiveSDK.zip "http://dldir1.qq.com/hudongzhibo/ILiveSDK/$ILiveSDKVersion.zip" --retry 5

echo "|-------------------------------download Successful-----------------------------|"

#解压zip文件
echo "|-------------------------------unzip ILiveSDK----------------------------------|"
unzip ILiveSDK.zip -x __MACOSX/*
echo "|-------------------------------unzip IMSDK-------------------------------------|"
unzip IMSDK.zip -x __MACOSX/*
echo "|-------------------------------unzip AVSDK-------------------------------------|"
unzip AVSDK.zip -x __MACOSX/*
echo "|-------------------------------unzip QAVEffect---------------------------------|"
unzip QAVEffect.zip -x __MACOSX/*

#移除zip文件
echo "|-------------------------------remove zip--------------------------------------|"
find . -name "*.zip"  | xargs rm -f

