#!/bin/bash

docker run --pull always --rm -v ./original/:/in -v ./patched:/out nerdfonts/patcher --complete
