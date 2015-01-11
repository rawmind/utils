#!/bin/bash

JDK_BIN_PATH=/usr/lib/jvm/jdk1.8.0_25/bin

for binary in $(ls $JDK_BIN_PATH/*); do
  name=$(basename $binary)
  update-alternatives --remove $name $JDK_BIN_PATH/$name
done

