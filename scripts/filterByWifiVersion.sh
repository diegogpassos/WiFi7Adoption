#!/bin/bash

cat $1 | awk -F ';' -v v=$2 '(!/^#/ && $9 == v){print $0}'

