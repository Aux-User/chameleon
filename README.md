# chameleon
This script allows users to anonymously scan a target system through a remote intermediary and save the results locally.

This script was written as part of my Network Research module that I took for class.   
Below a short summary of what the script does while more details are available in the project documentation - [ProjDoc-NWR.pdf](https://github.com/Aux-User/chameleon/blob/main/ProjDoc-NWR.pdf)    

The script executes as follows:
- Check for installation of nipe, sshpass and geoip-bin
- Spoof local IP using nipe and confirms working spoof
- Prompts user to provide remote intermediary login credentials and scan target IP/domain
- Logs in to remote system using sshpass and provides user with remote system IP, country and uptime for confirmation
- whois and nmap scans performed on target system through remote system
- scan results are copied to the user's local machine while originals are deleted from the remote intermediary
