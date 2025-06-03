#!/bin/bash

EXTERNAL_LIST_DEFAULT=("one" "two" "three")

EXTERNAL_LIST=("${EXTERNAL_LIST[@]:=${EXTERNAL_LIST_DEFAULT[@]}}")

for ELEMENT in ${EXTERNAL_LIST[@]}; do
  echo $ELEMENT
done