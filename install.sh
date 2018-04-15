#!/bin/bash

if [[ $UID != 0 ]] ; then
  echo must run as root
  exit 1
fi

if [[ !(-e bin/libdmath.so) ]] ; then
  echo found no file \"bin/libdmath.so\"
  exit 2
fi

cp bin/libdmath.so /usr/lib/libdmath.so
if [[ $? != 0 ]] ; then
  echo failed to copy shared object file '(library)' to folder '/usr/lib/'
  exit 4
fi

cp -r src/dmath /usr/include/dmath
if [[ $? != 0 ]] ; then
  echo failed to copy source directory into folder '/usr/include'
  exit 8
fi



