#!/bin/bash

# KLUDGE: this currently needs to be run as ./bin/compile.sh

## SASS #######################################################################

# TODO: compile from a style file into /dst/style.css ?


## ELM ########################################################################

elm make src/Client.elm --warn --debug --output=dst/client.js
