#!/bin/bash
# clear mod files and folders
rm /home/rustserver/serverfiles/oxide/data/NTeleportationHome.json
rm /home/rustserver/serverfiles/oxide/data/NTeleportationTPR.json
rm /home/rustserver/serverfiles/oxide/data/HammerRemove.json
rm /home/rustserver/serverfiles/oxide/data/DynamicCupShare.json
rm /home/rustserver/serverfiles/oxide/data/AutoCodeLock.json
rm /home/rustserver/serverfiles/oxide/data/killstreak_player_data.json
rm -rf /home/rustserver/serverfiles/oxide/data/KDRGui
rm -rf /home/rustserver/serverfiles/oxide/data/Arkan

# Delete backpack files that haven't been touched in 90+ days
/usr/bin/find /home/rustserver/serverfiles/oxide/data/Backpacks/* -mtime +90 -exec rm {} \;

