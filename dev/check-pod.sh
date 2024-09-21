#!/bin/bash

if [[ -z "$1" ]]; then
    echo help follows
    exit
fi

export RAKULIB=./lib
./check-pod-nodes.raku
