#!/bin/bash

### requires monodis package to be installed on host (or inside container)
SNIP=`monodis /home/rustserver/serverfiles/RustDedicated_Data/Managed/Rust.Global.dll | grep "int32 save"`
RAW=`echo $SNIP | sed 's/.*(\(.*\))/\1/'`
HEX=${RAW#"0x"}
echo $(( 16#$HEX ))
