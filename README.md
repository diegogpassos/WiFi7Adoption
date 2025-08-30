# Research artifacts for the project WiFi7Adoption

This project aims to study the adoption of different versions or generations of Wi-Fi. The repository contains partial (anonymized) data, scripts, and auxiliary files used to generate the results reported on the following paper:

- R. Castanheira, D. Passos. "Empirical study on the adoption of different Wi-Fi versions: a case study in Lisbon", the 13th Wireless Days (WD 2025), (submitted), 2025.

More details on the methodology can be found on the paper.

## Contents of the repository

The artifacts are divided into three directories:

- `scripts`: scripts developed for capturing, processing and analyzing data from beacons collected from our measurements.
- `aux`: auxiliary files used by some of the scripts.
- `data`: partial data resultant from processing the raw measurements. Some fields (BSSIDs, ESSIDs) have been omitted, while others (MAC address) have been anonymized due to privacy concerns.

## Brief description of the scripts

The following scripts are available:

- `doMeasurement.sh`: script used for data collection. It uses `tcpdump` for collecting frames in several Wi-Fi channels. Both the list of channels and the time spent on each channel can be parametrized. It depends on the existence of a Wi-Fi interface previously configured in Monitor mode. The final result is a pcap file of the capture.
- `pcap2bss.sh`: processes a pcap file, isolates the beacons and generates a list of BSSs. For each BSS, the script identifies characteristics such as the support for some IEEE 802.11 amendments, the Wi-Fi version, and the OID of the manufacturers.
- `physicalAPs.sh`: processes the output of the `pcap2bss.sh` in order to identify BSSs belonging to a same physical AP. The output is a list of physical APs, along with their characteristics.
- `hex2ascii.sh`: transforms a string denoting an hex value of a sequence of ASCII characters into the corresponding string. Useful for parsing the ESSID of a BSS, as certain versions of `tshark` output it in hex format by default.
- `oid2ManufacturerName.sh`: converts an OID into the name of a manufacturer. It depends on a file containing a list of known OIDs (available in the `aux` directory).
- `statsWifiVersionDistribution.sh`: processes the output of either `pcap2bss.sh` or `physicalAPs.sh` and computes the number of APs/BSSs for each possible Wi-Fi version.
- `filterByWifiVersion.sh`: filters the output of either `pcap2bss.sh` or `physicalAPs.sh` and shows only APs/BSSs for a certain Wi-Fi version.

