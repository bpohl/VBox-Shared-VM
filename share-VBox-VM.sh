#!/bin/bash
# Change the owner and group of a VM to a common user and shared group
# and then set the group permissions to the same as owner
#
# $Id$
# $Revision$
# $Tags$

# Send all output to a log
exec >"/var/log/$(basename "${0%.*}").log" 2>&1

# Define locations
: ${VBOX_VM_USER:="$1"}
: ${VBOX_VM_HOME:="$2"}
: ${VBOX_VM_SHARE_PID:="/var/run/$(basename "${0%.*}")/pid"}
: ${VBOX_VM_SHARE_INTERVAL:=2}
: ${VBOX_VM_SHARE_FILELIST:='.*/*\.(vbox|vmdk|vdi|vhd|nvram)'}

# Make sure there are values for params that don't default to something
if [ -z "$VBOX_VM_USER" ] || [ -z "$VBOX_VM_HOME" ]; then
  cat <<EOS >&2
VBOX_VM_USER and/or VBOX_VM_HOME are not set.  Specify them 
Usage: [<envar>=<value> ...] $(basename "$0") [<VBOX_VM_USER> [<VBOX_VM_HOME>]]
EOS
  exit 1
fi

# Quit if this is already running
ps -p $(cat "$VBOX_VM_SHARE_PID" 2>&1) && exit 2
mkdir -p "$(dirname "$VBOX_VM_SHARE_PID")" || exit 3
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
