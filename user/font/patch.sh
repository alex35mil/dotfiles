#!/bin/bash

docker run --rm -v ./original/:/in -v ./patched:/out nerdfonts/patcher --complete
