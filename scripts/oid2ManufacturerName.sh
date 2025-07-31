#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Use: $0 <oid_file> <data file>"
	exit 1
fi

awk '
(FNR==NR) {

	# OID file
	if ($0 ~ /base 16/) {
		o=$4; 
		for (i = 5; i <= NF; i++) o = o " " $(i); 
		oid[$1] = o
	}

	next ;
}

ENDFILE {

	FS=OFS=";"
}

(/^#/) {
	print $0
	next ;
}

{
	# Data file. OID list should be the last column
	output = ""
	len = split($(NF), list, ",")
	if (len) {

		for (i = 1; i <= len; i++) {

			nextOid = sprintf("%06X", list[i])
			if (output == "") output = oid[nextOid]
			else output = output "|" oid[nextOid]
		}
	}
	else if ($(NF) != "") {

		nextOid = sprintf("%06X", list[i])
		output = oid[nextOid]
	}
	else output = $(NF)

	$(NF) = output
	print $0
}' $1 $2

