#!/bin/bash
# https://linuxhint.com/tmux-send-keys/


# step 1: gets your ip
	export ATTACKER_IP_ADDY=$(hostname -I | awk '{print $2}')


# step 2: makes folders that you need for the next batch of tasks
# ask user for folders to build out

read -p 'Target Name: ' target
read -p 'Target IP: ' target_ip
export TARGET_IP=$target_ip
export HTB_NAME=$target

# step 3a: define local main directory name for brevity
export HOME_DIR=/home/kali/Practice/htb/$HTB_NAME/


# step 4a: Make sure Target name exists, then build directories around it.

if [ -n "$TARGET_IP" ]
then
	echo -e "\nCreating directories nmap, server_files, recon, files. Find them within Practice/htb/$HTB_NAME/\n"
	mkdir -p /home/kali/Practice/htb/$HTB_NAME/{nmap,server_files,recon,files}

else
	echo "get into a tmux session with a name then run this script again."
	exit 0
fi

# step 4b: create environmental variables for session, write to file,
# then have user run the command to import it. This is the unfortunate part
# where we have to tell the user to import a sh file which we've written the new environment variables.
# there's no other way around it since this bash file is operating as as child node
# and has no persistence because we'll be referencing things in the parent session.

echo "export ATTACKER_IP_ADDY=$ATTACKER_IP_ADDY" >> $HOME_DIR/.$HTB_NAME-env_vars
echo "export TARGET_IP=$TARGET_IP" >> $HOME_DIR/.$HTB_NAME-env_vars


tmux send-keys "source $HOME_DIR/.$HTB_NAME-env_vars" C-m
clear

# display basic info so user knows whats up, also run the command to bring in env variables.
echo -e "\nInstantiating session environmental vars:"
echo  -e "\n\$ATTACKER_IP_ADDY: $ATTACKER_IP_ADDY"
echo "\$TARGET_IP: $TARGET_IP"




################################################ TMUX BABY #######################################
#************* HEADS UP ****************#
# functions aliases nq, ne must be defined as an alias in bashrc or .zshrc.
# these functions are found in the nmap-scripts folder.



# Step 5: begin making window panes with specific tasks.
# cd first into the right home dir
# pane 1: nmap quicky
# run the nmap quick scan + default scan in one window

tmux send-keys "cd $HOME_DIR" C-m
tmux send-keys "source nmap-scripts/nmap-quick.sh" C-m



# pane 2: gobuster directories

$(tmux -v split-window -h)
 tmux send-keys "cd $HOME_DIR" C-m
 tmux send-keys "source $HOME_DIR/.$TARGET_IP-env_vars" C-m
 tmux send-keys "source nmap-scripts/nmap-everything-allports.sh" C-m

#tmux send-keys "gobuster dir -u $TARGET_IP -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt -o $HOME_DIR/recon/$TARGET_IP-gb-directories"

# pane 1: gobuster large files
$(tmux -v split-window)
tmux send-keys "cd $HOME_DIR" C-m
tmux send-keys "source $HOME_DIR/.$HTB_NAME-env_vars" C-m

tmux send-keys "gobuster dir -u $TARGET_IP -w /usr/share/seclists/Discovery/Web-Content/raft-large-files.txt -o $HOME_DIR/recon/$HTB_NAME-files"
