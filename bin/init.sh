#!/bin/bash

# KLUDGE: this currently needs to be run as ./bin/compile.sh

## HTTP SERVER ################################################################

npm install -g http-server && \


## ELM ########################################################################

npm install -g elm && \
elm package install
