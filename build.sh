#!/bin/bash


if [[ !(-d bin) ]] ; then
  mkdir bin
fi


if [[ $1 == test ]] ; then

  gdc src/test.d src/dmath/*.d -o bin/test.bin -g

elif [[ $1 == lib ]] ; then

  gdc src/dmath/*.d -o bin/temp.o -fPIC -c
  if [[ $? != 0 ]] ; then
    exit $?
  fi

  gcc bin/temp.o -g -fPIC -shared -o bin/libdmath.so
  if [[ $? != 0 ]] ; then
    exit $?
  fi

  rm bin/temp.o

else

  echo $'No mode selected. Select \"test\" or \"lib\"'

fi

