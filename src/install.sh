#!/bin/bash
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi

SDK_DIRECTORY=/opt/artist-sdk
if [ ! -d "$SDK_DIRECTORY" ]; then
  mkdir -p "$SDK_DIRECTORY"
else
  rm -r $SDK_DIRECTORY/*
fi

cp -r include toolchain makefiles $SDK_DIRECTORY/
