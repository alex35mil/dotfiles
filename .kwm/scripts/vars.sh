#!/bin/bash

kwmc=/usr/local/bin/kwmc

SPLIT_RATIO_STEP="0.05"
FOCUSED_BORDER_ENABLED=$($kwmc query border focused)
MARKED_WIN_ID=$($kwmc query window marked id)
FOCUSED_WIN_ID=$($kwmc query window focused id)
CHILD_POSITION=$($kwmc query window child $FOCUSED_WIN_ID)
