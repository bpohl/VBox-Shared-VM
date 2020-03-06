#!/bin/bash
# $Id$
# $Revision$

# Send all output to a log
exec >"/var/log/$(basename "${0%.*}").log" 2>&1

# Define locations
: ${VBOX_VM_USER:="macosuser:vboxusers"}
: ${VBOX_VM_HOME:="/home/macosuser/VM Images"}
: ${VBOX_VM_SHARE_PID:="/var/run/user/$(id -u)/$(basename "${0%.*}").pid"}
: ${VBOX_VM_SHARE_INTERVAL:=2}
: ${VBOX_VM_SHARE_FILELIST:='.*/*\.(vbox|vmdk|vdi|vhd|nvram)'}

# Quit if this is already running
ps -p $(cat "$VBOX_VM_SHARE_PID" 2>&1) && exit 1
echo $$ > "$VBOX_VM_SHARE_PID"

# Loop forever
while true; do
  # Set the group permissions to be the same as the owner
  find "$VBOX_VM_HOME" -type f -regextype egrep                      \
                       -iregex "$VBOX_VM_SHARE_FILELIST" 2>/dev/null \
                       -exec chown -v "$VBOX_VM_USER" "{}" ';'       \
                       -exec chmod -v g=u "{}" ';' 
  #sleep 60
  # Wait until one of the .vbox files flinches
  TERM=xterm watch -n $VBOX_VM_SHARE_INTERVAL -gt \
        "find '$VBOX_VM_HOME' -type f -regextype egrep          \
                              -iregex '$VBOX_VM_SHARE_FILELIST' \
                              -ls 2>/dev/null"
  sleep 1
done
