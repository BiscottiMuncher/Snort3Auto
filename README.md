# Snort3Auto
### Snort3 Auto Install script for Debain based systems 

Build script for Debian systems running SystemD 

--- 
Features
- Auto download of all needed libraries
- Automated Make and Install
- Automated folder creation for needed Snort3 directories
- Adds persistant promiscious mode on defined NIC

--- 
Current Versions Tested
- v3.7.4.0


--- 
### Usage

Normal Install

` ./snortauto.sh -n eth0 `

Install Using gperf heap checker (Increased performance at memory cost)

` ./snortauto.sh -t eth0  `
