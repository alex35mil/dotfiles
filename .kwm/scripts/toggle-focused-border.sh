#!/bin/bash

kwmc=/usr/local/bin/kwmc

ENABLED=$($kwmc query border focused)

if [[ $ENABLED = "true" ]]
then
  $kwmc config border focused off
else
  $kwmc config border focused on
fi
