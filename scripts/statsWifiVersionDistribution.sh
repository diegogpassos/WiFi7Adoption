#!/bin/bash

cat $1 | awk -F ';' '(!/^#/){wifiVersions[$9]++} END{for (i in wifiVersions) print i, wifiVersions[i]}' | sort

