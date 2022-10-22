#!/bin/bash


we=$(LC_TIME=C date +%A)
dm=$(date +%d)

# FIRST CHECK FOR LOCK FILE AND ABORT IF EXISTS
if [ -f /home/rustserver/restart.lock ]
then
    echo "RESTART LOCK FILE EXISTS.  ABORTING."
    exit 0
fi


STATUS=`/home/rustserver/rustserver monitor | grep gsquery`
if [[ $STATUS == *"OK"* ]];
then
    echo "Server OK.  Aborting"
    # run check to see if umod out of sync and issue restart if so
    /home/rustserver/automation/updatebot/server-restart.php  > /dev/null 2>&1
    exit 0
else
    # server is down, so go ahead and update server and oxide and then start back up
    # create a lock file so that we can test to see if restart
    # sequence has been initiated from other scripts

    # redundant in a forced wipe situation but whatever
    # touch the restart lock file again.  redundant and will fail most cases
    # but the autowipe script blows it away if it triggers in a forced wipe situation
    # add it back so we don't get interrupted while updating
    touch /home/rustserver/restart.lock
    /home/rustserver/rustserver stop # for good measure
    /home/rustserver/rustserver update
    /home/rustserver/rustserver mods-update

    if [ -f /home/rustserver/countdown.lock ]
    then
        # if a countdown file, we're here because of an update
        # determine if possible force wipe event
        # force wipe script has additional sanity checks and will bail if not forced wipe
        if [ "$we" = "Thursday" ] && [ "$dm" -lt 8 ]
        then
            # only bother running this at all on first thursday of month
            # just to minimize risk of snafus
            /home/rustserver/automation/forcewipe.sh >> /home/rustserver/automation/forcewipe.log
        fi
    fi

    # Start everything back up
    /home/rustserver/rustserver start

    rm -f /home/rustserver/restart.lock
    rm -f /home/rustserver/countdown.lock
fi
