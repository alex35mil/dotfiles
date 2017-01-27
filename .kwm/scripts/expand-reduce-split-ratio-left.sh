#!/bin/bash

source ~/.kwm/scripts/vars.sh

if [[ $CHILD_POSITION == "right" ]]
then
  $kwmc window -c expand $SPLIT_RATIO_STEP west
elif [[ $CHILD_POSITION == "left" ]]
then
  $kwmc window -c reduce $SPLIT_RATIO_STEP east
fi
