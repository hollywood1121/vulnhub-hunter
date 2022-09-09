# vulnhub-hunter
This script eliminates the redundancies of commencing the hunt for vulnhub boxes. This script MUST be run in conjunction with Tmux. The script does the following:
- Arp-scan network and find the IP in question (will ask for sudo)
- cool animations that help the program load *faster*
- creates the structural directories within /home/kali/Practice/ for proper organization of files and outputs
- adds environmental variables to your current session
- sets up nmap and 2 gobuster scans (files and directories) simultaneously to allow the user to manually enumerate and not waste time getting into the weeds.

This was a fun project and please feel free to fork and do what you will. As a part of learning bash for OSCP, scripts like this are crucial to understanding what you can manual processes you can eliminate to help you get into boxes quicker with less actual typing. Enjoy.

## Future versions:
- run script with no tmux enabled, create session which will then be used for everything else. I'm looking for a plain bash session to be converted into tmux session which will then solve the problem of the user having to enter in a tmux and THEN quantify the target name, should be one step.
- name sessions better when creating tmux sessions for gobuster - I want it clear that one is the files search and one is the directory search.
- update the program usage for arp-scan, want to get away from running sudo; feels sketch to ask the user for sudo.
- enable a parse of the gobuster file output to detect wordpress, (pick up a 301 wp-config.php type thing) if that is the case, then enable wpscan 
