#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Use: $0 <col>"
	echo "where <col> is the index of the column that contains the hex value to be"
	echo "converted to a string"
	exit 1
fi

awk -v col=$1 -F ';' '
BEGIN    { 

	OFS = ";";
	hex2dec["0"] = 0;
	hex2dec["1"] = 1;
	hex2dec["2"] = 2;
	hex2dec["3"] = 3;
	hex2dec["4"] = 4;
	hex2dec["5"] = 5;
	hex2dec["6"] = 6;
	hex2dec["7"] = 7;
	hex2dec["8"] = 8;
	hex2dec["9"] = 9;
	hex2dec["a"] = 10;
	hex2dec["b"] = 11;
	hex2dec["c"] = 12;
	hex2dec["d"] = 13;
	hex2dec["e"] = 14;
	hex2dec["f"] = 15;
}

function chr(c) {

    # force c to be numeric by adding 0
    return sprintf("%c", c + 0)
}

function hex2str(hexValue,     i, hex, hexLen, asciiValue, output) {

	hexLen = split(hexValue, hex, "");
	output = ""
	for (i = 1; i <= hexLen; i += 2) {

		asciiValue = 16 * hex2dec[hex[i]] + hex2dec[hex[i+1]]
		if (asciiValue != 0) output = output chr(asciiValue);
	}

	return output
}

(/^#/) {
	print $0
	next ;
}

{
	if ($(col) ~ /^".*"$/) {
		split($(col), a, "\"");
		hexValue = a[2]
	}
	else
		hexValue = $(col)

	if (! (hexValue ~ /<MISSING>/)) convertedValue = hex2str(hexValue)
	else convertedValue = ""

	$(col) = convertedValue
	print $0
}'

