#!/bin/bash
echo "nmap -Pn -p- -T4 -oN $HOME_DIR/nmap/$HTB_NAME-allports $TARGET_IP"
 # the grep will find any strings that start with aany abount of numbers but eventually end with open signifying the port is open, 
PORTS=$(nmap -Pn -p- -T4 -oN $HOME_DIR/nmap/$HTB_NAME-allports $TARGET_IP | grep "[0-9]*\ open" | awk -F "/tcp" '{print $1}' | sed -e ':a' -e 'N;$!ba' -e 'y/\n/,/')


cat $HOME_DIR/nmap/$HTB_NAME-allports

echo "nmap -sC -sV -Pn $TARGET_IP -oN $HOME_DIR/nmap/$HTB_NAME-final -p$PORTS"
nmap -sC -sV -Pn $TARGET_IP -oN $HOME_DIR/nmap/$HTB_NAME-final -p$PORTS
