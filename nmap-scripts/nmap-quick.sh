#!/bin/bash
echo "nmap -Pn -T4 -oN nmap/$HTB_NAME-quicky $TARGET_IP \n"
 # the grep will find any strings that start with aany abount of numbers but eventually end with open signifying the port is open, 
PORTS=$(nmap -Pn -T4 -oN $HOME_DIR/nmap/$HTB_NAME-quicky $TARGET_IP  | grep "[0-9]*\ open" | awk -F "/tcp" '{print $1}' | sed -e ':a' -e 'N;$!ba' -e 'y/\n/,/')

cat $HOME_DIR/nmap/$HTB_NAME-quicky | grep "[0-9]*\ open" 
echo "\n---------------------------------\n\n"
echo "Nmap -sC -sV $TARGET_IP -oN nmap/$HTB_NAME-default\n"
nmap -sC -sV -Pn $TARGET_IP -oN $HOME_DIR/nmap/$HTB_NAME-default -p$PORTS
