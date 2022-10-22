#!/bin/bash

#### README
# This script is not intended to be run directly from cron.
# Instead it is called by checker.sh which runs from cron on 5 minute
# intervals to make sure the server is online and oxide is up to date

# MARKER FOR LOG FILE
LASTWIPED=$(date -d "$D" '+%m-%d') # get current date
echo "#### WIPE LOG: $LASTWIPED "

# DETECT PROTOCOL CHANGE
CURRENT_PROTOCOL=`/home/rustserver/automation/get_protocol.sh`
LAST_KNOWN_PROTOCOL=`cat /home/rustserver/automation/last_known_protocol.txt`

#######################################################
#### SANITY CHECKS - BAIL IF ANYTHING LOOKS FISHY  ####
#######################################################

if ! [[ "$CURRENT_PROTOCOL" =~ ^[0-9]+$ ]]
then
    echo "Non-integer detected in current protocol check.  Aborting"
    exit 0
fi

if ! [[ "$LAST_KNOWN_PROTOCOL" =~ ^[0-9]+$ ]]
then
    echo "Non-integer detected in last known protocol.  Aborting"
    exit 0
fi

if ! [ $CURRENT_PROTOCOL -gt $LAST_KNOWN_PROTOCOL ]
then
    echo "PROTOCOL UNCHANGED - ABORTING FORCE WIPE"
    exit 0
fi

###############################################
#### BEGIN NORMAL WIPE STUFF FOR ALL WIPES ####
###############################################

# create lock file so /automation/checker.sh does not try to restart while wiping
touch /home/rustserver/restart.lock
/home/rustserver/rustserver stop
#/home/rustserver/rustserver update-lgsm
echo "Y" | /home/rustserver/rustserver full-wipe

# backup data directory
DATE=`date +"%Y-%m-%d"`
cp -r /home/rustserver/serverfiles/oxide/data/ /home/rustserver/backup/forcedwipe-$DATE

# FORCED WIPE SPECIFIC ACTIONS
/home/rustserver/automation/plugin-data-wipe-forced.sh

# clear mod files and folders
/home/rustserver/automation/plugin-data-wipe.sh


#########################
#### UPDATE MAP SEED ####
#########################

/home/rustserver/automation/maprotate.sh

# remove restart lock file
# WE DON'T START BACK UP HERE.  THAT WILL BE HANDLED BY checker.sh
rm /home/rustserver/restart.lock

# Update last_known_protocol.txt
echo $CURRENT_PROTOCOL > /home/rustserver/automation/last_known_protocol.txt
