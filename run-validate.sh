#!/bin/bash

if [[ -z "$1" ]]; then
    echo help follows
    exit
fi

#IFIL=../docs/README.rakudoc
IFIL=./docs/README.rakudoc
#export RAKUDO_RAKUAST=1; raku --rakudoc $IFIL

raku -I. xt/rakuast-validate.rakutest
