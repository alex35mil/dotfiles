#!/bin/bash

source ~/.kwm/scripts/vars.sh

if [[ $FOCUSED_BORDER_ENABLED = "true" ]]
then
  $kwmc config border focused off
else
  $kwmc config border focused on
fi
