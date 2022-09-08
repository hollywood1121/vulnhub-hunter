#!/bin/bash
# https://linuxhint.com/tmux-send-keys/

# Attempt to send a SIGUSR1 to the process in order for the tmux server to recreate the socket
# this is specifically for stopping any sort of "no server running on /tmp/tmux-0/default" errors
# pkill -USR1 tmux

# function load info needs to run in paralell with load screen, therefore run them at the same time.
function loadInfo(){
	# step 1: gets your ip
	export ATTACKER_IP_ADDY=$(hostname -I | awk '{print $1}')

	# step 2: arp scans for you, finds your target IP and saves it to a variable
	export TARGET_IP=$(sudo arp-scan --interface eth0 $ATTACKER_IP_ADDY/24 | grep 'PCS System' | awk '{print $1}')

}

function loadingAnimation(){

	# to let the arp-scan show first
	sleep 0.25
	# show some sort of load animation
	sleep 2 &
	pid=$!
	frames="/ | \\ -"
	while kill -0 $pid 2&>1 > /dev/null;
	do
    		for frame in $frames;
    		do
        		printf "\r$frame Arp-scanning..."
       			sleep 0.20
    		done
	done
}
# run them together to have cool vibes:
loadInfo &
loadingAnimation &
wait

# when done, confirmation message, then clear the screen.
printf "\rTarget Aquired..."
sleep 0.75
clear

# step 2a: verify Target_Ip actually has an IP, if not, terminate as cannot find box. Alert user.
if [ -z "$TARGET_IP" ]
then
	echo "Cannot locate the target box on network. Check if target is pulling IP and is on the correct network, then retry."
	echo "terminating..."
	exit 0
fi

# step 3: makes folders that you need for the next batch of tasks
# ask user for folders to build out

read -p 'Target Name: ' target
export TARGET_NAME=$target

# step 3a: define local main directory name for brevity
export HOME_DIR=/home/kali/Practice/$TARGET_NAME

# step 4: session name and make directories.

# step 4a: Make sure Target name exists, then build directories around it.

if [ -n "$TARGET_NAME" ]
then
	echo -e "\nCreating directories nmap, server_files, recon, files. Find them within Practice/$TARGET_NAME/\n"
	mkdir -p /home/kali/Practice/$TARGET_NAME/{nmap,server_files,recon,files}

else
	echo "get into a tmux session with a name then run this script again."
	exit 0
fi

# step 4b: create environmental variables for session, write to file,
# then have user run the command to import it. This is the unfortunate part
# where we have to tell the user to import a sh file which we've written the new environment variables.
# there's no other way around it since this bash file is operating as as child node
# and has no persistence because we'll be referencing things in the parent session.

echo "export ATTACKER_IP_ADDY=$ATTACKER_IP_ADDY" >> $HOME_DIR/.$TARGET_NAME-env_vars
echo "export TARGET_IP=$TARGET_IP" >> $HOME_DIR/.$TARGET_NAME-env_vars
echo "export TARGET_NAME=$TARGET_NAME" >> $HOME_DIR/.$TARGET_NAME-env_vars
echo "export HOME_DIR=$HOME_DIR" >> $HOME_DIR/.$TARGET_NAME-env_vars


tmux send-keys "source $HOME_DIR/.$TARGET_NAME-env_vars" C-m
clear

# display basic info so user knows whats up, also run the command to bring in env variables.
echo -e "\nInstantiating session environmental vars:"
echo  -e "\n\$ATTACKER_IP_ADDY: $ATTACKER_IP_ADDY"
echo "\$TARGET_IP: $TARGET_IP"
echo "\$TARGET_NAME: $TARGET_NAME"
echo -e "\$HOME_DIR: $HOME_DIR\n"



################################################ TMUX BABY #######################################

# Step 5: begin making window panes with specific tasks.
# cd first into the right home dir
# pane 1: nmap

tmux send-keys "cd $HOME_DIR" C-m
tmux send-keys "nmap -sC -sV -oA $HOME_DIR/nmap/$TARGET_NAME-default $TARGET_IP" C-m

# pane 2: gobuster directories

$(tmux -v split-window -h)
tmux send-keys "cd $HOME_DIR" C-m
tmux send-keys "gobuster dir -u $TARGET_IP -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt -o $HOME_DIR/recon/$TARGET_NAME-gb-directories" C-m

# pane 1: gobuster large files

$(tmux -v split-window)
tmux send-keys "cd $HOME_DIR" C-m
tmux send-keys "gobuster dir -u $TARGET_IP -w /usr/share/seclists/Discovery/Web-Content/raft-large-files.txt -o $HOME_DIR/recon/$TARGET_NAME-gb-files" C-m
