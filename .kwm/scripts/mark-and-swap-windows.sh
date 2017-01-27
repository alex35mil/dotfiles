#!/bin/bash

source ~/.kwm/scripts/vars.sh

if [[ $MARKED_WIN_ID = "-1" || $MARKED_WIN_ID = $FOCUSED_WIN_ID ]]
then
  $kwmc window -mk focused
else
  $kwmc window -s mark
fi
