#!/bin/bash
# $Id$
# $Revision$
# $Tags$

# DEBUG flag. 0=On 
DEBUG () { return 1; }

# Set some defaults.
: ${NEW_NAME:='share-VBox-VM'}
: ${PREFIX:='/usr/local/sbin'}
: ${SYSTEMD_SYSTEM:='/etc/systemd/system'}
: ${VBOX_VM_USER:="${USER}:"}
: ${VBOX_VM_HOME:="/home/$USER/VM Images"}
: ${VBOX_VM_SHARE_PID:=""}
: ${VBOX_VM_SHARE_INTERVAL:=""}

# Return the full path
function fullpath () { ( cd "${1:-.}" && pwd ) }

# Prime sudo 
sudo -v || exit 2
set -e

# Work in the directory with the installer
cd "$(dirname "$0")"

# Assemble the settings to include in the Unit file
ExecStart=""
[ -n "$VBOX_VM_USER" ] && ExecStart+="VBOX_VM_USER=\"$VBOX_VM_USER\" "
[ -n "$VBOX_VM_HOME" ] && \
  ExecStart+="VBOX_VM_HOME=\"$(fullpath "${VBOX_VM_HOME}")\" "
[ -n "$VBOX_VM_SHARE_PID" ] && \
  ExecStart+="VBOX_VM_SHARE_PID=\"$(fullpath "${VBOX_VM_SHARE_PID}")\" "
[ -n "$VBOX_VM_SHARE_INTERVAL" ] && \
  ExecStart+="VBOX_VM_SHARE_INTERVAL=${VBOX_VM_SHARE_INTERVAL} "
ExecStart+="exec \"$(fullpath "${PREFIX}")/${NEW_NAME}.sh\""

# Swap the current settings into the execution
X=$'\x80';
pattern="s$X\([\'\"]\).*share-VBox-VM.sh.*\1$X\1${ExecStart}\1$X"

# Do the substitution into the destination dir.  If DEBUG send to the
# terminal also.
DEBUG && exec 5>&1 || exec 5>/dev/null
sed "$pattern" "./share-VBox-VM.service"  \
  | sudo tee "$SYSTEMD_SYSTEM/${NEW_NAME}.service" >&5

# Copy the script into place.
sudo cp ./share-VBox-VM.sh "$PREFIX/${NEW_NAME}.sh"
sudo chmod +x "$PREFIX/${NEW_NAME}.sh"

# Start the process and make it start at boot
sudo systemctl daemon-reload
for op in stop enable start status; do
  echo "sudo systemctl $op \"${NEW_NAME}\""
  sudo systemctl $op "${NEW_NAME}"
done

exit

