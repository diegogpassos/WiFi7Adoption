#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Use: $0 <input pcap>"
	exit 1
fi

echo "# AP MAC, Freq (MHz), BSSID, SSID, 802.11n, 802.11ac, 802.11ax, 802.11be, WiFi Version, Manufacturers"

tshark -r $1 -2 \
	-R "wlan.fc.type_subtype == 0x0008" \
	-T fields -E separator=";" \
	-e wlan.ta -e radiotap.channel.freq -e wlan.bssid -e wlan.ssid -e wlan.tag.number -e wlan.ext_tag.number -e wlan.tag.oui |
sort |
uniq |
awk -F ";" '

func inArray(val, a, aLen,
		i) {

	for (i = 0; i < aLen; i++) if (a[i] == val) return 1;
	return 0;
}

BEGIN{

	OFS=";"
}

{
	tags = $5
	extTags = $6
	freq = $2
	ssid = "\""$4"\""

	# Parse tags to find out if 802.11n or 802.11ac are supported
	l = split(tags, splitTags, ",");
	if (inArray(45, splitTags, l)) amendN = 1; else amendN = 0;
	if (inArray(191, splitTags, l)) amendAC = 1; else amendAC = 0;

	# Parse extTags to find out if 802.11ax or 802.11be are supported
	l = split(extTags, splitExtTags, ",");
	if (inArray(35, splitExtTags, l)) amendAX = 1; else amendAX = 0;
	if (inArray(108, splitExtTags, l)) amendBE = 1; else amendBE = 0;

	# Determine WiFi version based on the info collected so far
	if (amendBE) wifiVersion = "7"
	else if (amendAX) {

		# If amendAX is supported, check if the channel is on the 6 GHz range. If so,
		# then WiFi 6E is supported
		if (freq >= 5955) wifiVersion = "6E"
		else wifiVersion = "6"
	}
	else if (amendAC) wifiVersion = "5"
	else if (amendN) wifiVersion = "4"
	else wifiVersion = "<4"
	
	# Print everything
	print $1, $2, $3, ssid, amendN, amendAC, amendAX, amendBE, wifiVersion, $7
}'

