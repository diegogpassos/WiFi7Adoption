#!/bin/bash

if [ $# -gt 1 ]
then
	echo "Use: $0 [input]"
	echo
	echo "The input must be a bss list, as output by the pcap2bss.sh script."
	echo "If omited, the input is expected from the standard input."
	exit 1
fi

echo "# AP MAC, Freq (MHz), BSSID, SSID, 802.11n, 802.11ac, 802.11ax, 802.11be, WiFi Version, Manufacturers"

awk -F ";" '

/^#/ {

	next ;
}

func inList(val, list, sep,
		i, arr, listLen) {

	listLen = split(list, arr, sep)
	if (listLen == 0) {
		
		if (val == list) return 1
		else return 0
	}

	for (i = 0; i < listLen; i++) if (arr[i] == val) return 1;
	return 0;
}

func mergeLists(L1, L2, sep,
		i, arr, listLen) {

	listLen = split(L1, arr, sep)
	if (listLen == 0) return L2
		
	for (i = 0; i < listLen; i++) {

		if (!inList(arr[i], L2, sep)) {

			if (L2 == "") L2 = arr[i]
			else L2 = arr[i] sep L2
		}
	}

	return L2;
}

func lookupMAC(MAC, MACs,
		i, prefix1, prefix2) {

	# Test if there is a perfect match
	if (MAC in MACs) return MAC;

	# Test if there is a match considering everything but the last nibble.
	prefix1 = substr(MAC, 0, 16);
	for (i in MACs) {

		prefix2 = substr(i, 0, 16);
		if (prefix1 == prefix2) return i
	}

	# Test if there is a match considering everything but the first byte
	for (i in MACs) {

		if (substr(MAC, 3) == substr(i, 3)) return i
	}

	return ""
}

func higherVersion(v1, v2,
			version2Index) {

	if (version2Index[v1] > version2Index[v2]) return v1
	else return v2
}

BEGIN{

	index2Version[0] = "<4";
	index2Version[1] = "4";
	index2Version[2] = "5";
	index2Version[3] = "6";
	index2Version[4] = "6E";
	index2Version[5] = "7";

	for (i in index2Version) version2Index[index2Version[i]] = i

	OFS=";"
}

# bc:4d:fb:4f:87:78;2432;bc:4d:fb:4f:87:78;"NOS-8770";1;0;0;0;4;20722,20722,20722,3139
{
	MAC = $1
	freq = $2
	BSSID = $3
	SSID = $4
	amendN = $5
	amendAC = $6
	amendAX = $7
	amendBE = $8
	wifiVersion = $9
	Manuf = $10

	matchMAC = lookupMAC(MAC, MACs)
	
	if (matchMAC != "") {

		# This is a duplicate. Merge.
		if (!inList(freq, freqs[matchMAC], "|")) freqs[matchMAC] = freqs[matchMAC] "|" freq
		if (!inList(BSSID, BSSIDs[matchMAC], "|")) BSSIDs[matchMAC] = BSSIDs[matchMAC] "|" BSSID
		if (!inList(SSID, SSIDs[matchMAC], "|")) SSIDs[matchMAC] = SSIDs[matchMAC] "|" SSID
		if (amendN) amendNs[matchMAC] = 1
		if (amendAC) amendACs[matchMAC] = 1
		if (amendAX) amendAXs[matchMAC] = 1
		if (amendBE) amendBEs[matchMAC] = 1
		wifiVersions[MAC] = higherVersion(wifiVersions[MAC], wifiVersion)
		Manufs[matchMAC] = mergeLists(Manuf, Manufs[matchMAC], ",");
	}
	else {

		MACs[MAC] = 1
		freqs[MAC] = freq;
		BSSIDs[MAC] = BSSID
		SSIDs[MAC] = SSID
		amendNs[MAC] = amendN
		amendACs[MAC] = amendAC
		amendAXs[MAC] = amendAX
		amendBEs[MAC] = amendBE
		wifiVersions[MAC] = wifiVersion
		Manufs[MAC] = matchMAC
	}
}

END{

	for (MAC in MACs) {

		print MAC, freqs[MAC], BSSIDs[MAC], SSIDs[MAC], amendNs[MAC], amendACs[MAC], amendAXs[MAC], amendBEs[MAC], wifiVersions[MAC], Manufs[MAC]
	}
}

' $1 | sort

