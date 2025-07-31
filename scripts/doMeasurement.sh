#!/bin/bash

if [ $# -ne 4 ]
then
	echo "Use: $0 <seconds_per_channel> <Freqs_File> <output> <capture_ifce>"
	exit 1
fi

SECONDS_PER_CHANNEL=$1
FREQS_FILE=$2
OUTPUT=$3
IFCE=$4
PCAP=$OUTPUT.pcap

echo "Output will be placed in $PCAP"

if [ -f "$PCAP" ]
then
	echo "File $PCAP already exists. Continue? (y/N)"
	read ans
	if [ "$ans" != "y" ]
	then
		echo "Aborting!"
		exit 2
	fi
fi

# Parse AP file to get the BSSIDs and channels
FREQS=$(cat $FREQS_FILE)

echo $FREQS

tcpdump -i $IFCE -w "$PCAP" &
PID=$!

echo "Just started tcpdump. PID is $PID"

for F in $FREQS
do
	iw dev $IFCE set freq $F
	echo "Scanning frequency $F..."
	sleep $SECONDS_PER_CHANNEL
done

kill $PID

echo "Waiting for tcpdump do die..."
sleep 2

