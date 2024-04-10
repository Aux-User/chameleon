#!/bin/bash

#This is the start of the script, a standard greeting followed by an 
#output telling the user what the script is doing.
echo 'Greetings, User.
Now checking for installed programs before proceeding.'
echo ' '

#These colour codes are for some quality of life enhancements to 
#highlight some outputs from the script.
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[0;33m'
BGRN='\033[1;32m'
BCYN='\033[1;36m'
CLR='\033[0m'

#This portion will contain the part of the script that handles the
#checking and preparation of the local host prior to attacking
#the remote system.
#This will check for and if need be, advise how to the following programs
#for the attack: nipe, sshpass, geoip-bin. 
#The script will also be stopped from executing further steps, until the
#required programs have been installed.

#This checks for nipe.
echo ' '
CHKNPL=$(find ~ -name nipe.pl)
if [ -z $CHKNPL ]
then 
	echo -e "Nipe NOT found!
Please refer to the instructions at ${RED}https://github.com/htrgouvea/nipe${CLR} and run this script again"
	exit
else
	echo -e "Nipe ${GRN}detected${CLR}."
fi 

#This checks for sshpass.
CHKSSHP=$(ls /usr/bin | grep sshpass)
if [ -z $CHKSSHP ]
then
	echo -e "sshpass NOT found!
Please install using ${RED}sudo apt-get install sshpass${CLR} and run this script again"
	exit
else
	echo -e "sshpass ${GRN}detected${CLR}."
fi 

#This checks for geoip-bin.
CHKGEOIP=$(ls /usr/share | grep GeoIP)
if [ -z $CHKGEOIP ]
then 
	echo -e "geoip-bin NOT found!
Please install using ${RED}sudo apt-get install geoip-bin${CLR} and run this script again."
	exit
else
	echo -e "geoip-bin ${GRN}detected${CLR}."
fi 
echo ' '

#Once the required programs are confirmed/installed on the host system,
#the script will then begin the next phase which is to spoof the IP and
#confirm that the spoof is active.
echo ' '
echo 'Proceeding to spoof IP...'
cd ~/nipe
#nipe can only be executed from the nipe directory so the script must go
#there first before the following can be executed
sudo perl nipe.pl restart
#restart is used since it stops and restarts the service regardless of current status.

PNPSTAT=$(sudo perl nipe.pl status | grep -i true)
SPFIP=$(sudo perl nipe.pl status | grep -i ip | awk '{print$3}')
#This portion checks if the spoof is active or not.
if [ -z "$PNPSTAT" ]
#Double quotation marks were used to prevent the "[:too many arguments"
#error arising from spaces in the output
then
	echo -e "Spoof ${RED}NOT${CLR} active!
Please check nipe installation and/or network connections and run this script again."
	exit

else
	echo -e "Spoof ${GRN}ACTIVE${CLR}. The world is blind (mostly) to your origin."
	echo "Spoofed IP Address: $SPFIP"
	geoiplookup "$SPFIP"
	
fi
echo ' '

#This portion will contain the part of the script that handles communication with the remote server.
#For the purposes of this script we shall assume that the remote server already has whois and nmap.

#The below will prompt the user to input remote login details and the target details for scanning.
echo -e "Please enter ${YLW}remote${CLR} User login"
read REMLOG
echo -e "Please enter ${YLW}remote${CLR} IP"
read REMIP
echo -e "Please enter ${YLW}remote${CLR} User password"
read REMPW
echo -e "Please provide ${RED}TARGET${CLR} IP/Domain to scan"
read VICIP
echo ' '
#After this, there should no longer be a need for manual input from the
#user. The remote scanning and local saving of results will be automated.

#This portion provides the user with the remote server IP address, country and uptime.
echo 'Connecting to Remote Server...'
REMIPTRUE=$(sshpass -p "$REMPW" ssh "$REMLOG@$REMIP" 'curl -s ifconfig.co')
echo "IP Address: $REMIPTRUE"
whois "$REMIPTRUE" | grep -i country | sort | uniq
REMUPT=$(sshpass -p "$REMPW" ssh "$REMLOG@$REMIP" 'uptime')
echo "Uptime: $REMUPT"
echo ' '

#This portion is where the remote server will scan the target for the user.
#whois is scanned first, followed by nmap.
#The respective scan outputs will be saved into a file for further analysis.
echo ' '
echo 'Scanning Target...'
echo "Saving whois data into $VICIP-whois"
sshpass -p "$REMPW" ssh "$REMLOG@$REMIP" "whois $VICIP >> $VICIP-whois"

echo "Saving nmap data into $VICIP-nmap"
sshpass -p "$REMPW" ssh "$REMLOG@$REMIP" "nmap $VICIP -Pn -sV -oN $VICIP-nmap"
echo ' '

#The next few lines will copy the scan results from the remote system to
#the local sytem and delete the files from the former.
echo 'Transferring scan results from remote system...'
sshpass -p "$REMPW" scp "$REMLOG@$REMIP":~/"$VICIP-whois" .
sshpass -p "$REMPW" scp "$REMLOG@$REMIP":~/"$VICIP-nmap" .
sshpass -p "$REMPW" ssh "$REMLOG@$REMIP" "rm $VICIP*"
echo 'Done. The world is blind (mostly) to your passing.'
echo ' '

#This is the last part of the script. It notifies the user that the
#scan is complete and where to find the files for further work.
#A new directory will be made and the files moved there.
echo -e "${BGRN}Scan complete.${CLR}"
echo 'Target whois and nmap scans have been saved here:'
DTSMP=$(date +%F-%H%M)
mkdir ~/"$VICIP-$DTSMP"
mv "$VICIP"* ~/"$VICIP-$DTSMP"
REPWHO=$(find ~ -name "$VICIP"-whois)
REPNMP=$(find ~ -name "$VICIP"-nmap)
echo -e "${BCYN}$REPWHO${CLR}"
echo -e "${BCYN}$REPNMP${CLR}"
echo ' '
echo 'Farewell, User. Have a nice day.'

#Finish




