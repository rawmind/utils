#!/bin/sh

#deb http://www.emdebian.org/debian/ squeeze main
# deb http://backports.debian.org/debian-backports squeeze-backports main


apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AED4B06F473041FA
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B5B7720097BB3B58

apt-get update
apt-get install emdebian-archive-keyring
apt-get update
apt-cache search armel
apt-get install linux-libc-dev-armel-cross
apt-get install libc6-armel-cross libc6-dev-armel-cross
apt-get install binutils-arm-linux-gnueabi
apt-get install gcc-4.4-arm-linux-gnueabi
apt-get install g++-4.4-arm-linux-gnueabi

apt-get install gcc-arm-linux-gnueabi

apt-get install xapt
xapt -a armel libfoo-dev
apt-get install gdb-arm-linux-gnu

apt-get install pdebuild-cross dpkg-cross

#To install uuencode, uudecode
apt-get install sharutils 

#ln -s -f /usr/bin/arm-linux-gnueabi-gcc /usr/bin/arm-eabi-gcc 
#ln -s -f /usr/bin/arm-linux-gnueabi-ar /usr/bin/arm-eabi-ar
#ln -s -f /usr/bin/arm-linux-gnueabi-ld /usr/bin/arm-eabi-ld
#ln -s -f /usr/bin/arm-linux-gnueabi-nm /usr/bin/arm-eabi-nm
#ln -s -f /usr/bin/arm-linux-gnueabi-objcopy /usr/bin/arm-eabi-objcopy

#check
arm-linux-gnueabi-gcc -v
