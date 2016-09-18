#!/bin/bash

kwmc=/usr/local/bin/kwmc

MARKED=$($kwmc query window marked id)
CURRENT=$($kwmc query window focused id)

if [[ $MARKED = "-1" || $MARKED = $CURRENT ]]
then
  $kwmc window -mk focused
else
  $kwmc window -s mark
fi
