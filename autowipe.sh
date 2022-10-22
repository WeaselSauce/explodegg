#!/bin/bash
# MARKER FOR LOG FILE
LASTWIPED=$(date -d "$D" '+%m-%d') # get current date
echo "#### WIPE LOG: $LASTWIPED "

# referencing https://gist.github.com/ashrithr/5614283
# using 68 hours as our guide since we wipe every 3 days or 72 hours and this script
# should execute every day at 4pm CT

MAPFILE=$(/bin/ls /home/rustserver/serverfiles/server/rustserver/proceduralmap.*.map)
#MAPFILE=$(/bin/ls /home/rustserver/serverfiles/server/rustserver/barren.*.map)

MAXAGE=$(bc <<< '68*60*60') # seconds in 68 hours
# file age in seconds = current_time - file_modification_time.
FILEAGE=$(($(date +%s) - $(stat -c '%Y' $MAPFILE)))

if [ $FILEAGE -lt $MAXAGE ]
then
    echo "Skipping wipe - not enough time has elapsed."
    exit 0
else
   # create lock file so /automation/checker.sh does not try to restart while wiping
   touch /home/rustserver/restart.lock
   /home/rustserver/rustserver stop
   echo "Y" | /home/rustserver/rustserver wipe
fi

#########################
#### UPDATE MAP SEED ####
#########################

/home/rustserver/automation/maprotate.sh

#############################
#### WIPE ALL THE STUFFS ####
#############################

# clear mod files and folders
/home/rustserver/automation/plugin-data-wipe.sh

# update and start back up
#/home/rustserver/rustserver update
#/home/rustserver/rustserver mods-update
/home/rustserver/rustserver start

# remove lock file
rm /home/rustserver/restart.lock
