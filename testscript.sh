#!/bin/bash

hideinput()
{
  if [ -t 0 ]; then
     stty -echo -icanon time 0 min 0
  fi
}

cleanup()
{
  if [ -t 0 ]; then
    stty sane
  fi
}

trap cleanup EXIT
trap hideinput CONT
hideinput
n=0
while test $n -lt 10
do
  read line
  sleep 1
  echo -n "."
  n=$[n+1]
done
echo

