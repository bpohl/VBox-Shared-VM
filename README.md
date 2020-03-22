# Share [VirtualBox](http://www.virtualbox.org/) VM Among Several Users

**Scripts run as [systemd](http://systemd.io/) units that adjust [VirtualBox](http://www.virtualbox.org/) VM permissions to share between multiple users.**

When [VirtualBox](http://www.virtualbox.org/) writes the files making up a Virtual Machine (VM) it sets the file permissions to be read and written only by the user running the GUI.  This is good for security but keeps the VM from being used by more than one user, even if only one user at a time.

This package installs a simple [systemd](http://systemd.io/) service which runs with root privileges and watches a specified directory for change in any VM files, and then when a change happens will set the user and group of the files to a single owner and set the group permissions to the same as owner.

The result is that any user that is made part of the group to which the VM files belong will be able to start the VM.  But remember, it is still a very bad idea for two instances of a VM to be run at the same time.

This package was developed and tested on [Ubuntu 19.10](http://releases.ubuntu.com/19.10/).  There's no magic in it so it should work on most distros that use [systemd](http://systemd.io/).  Your mileage may vary.  Let me know.

## Configuration

Firstly, there needs to be a group that all the VMs will be in and the permitted VM users will be part of.  One user to own the VMs must be decided upon.  It can be an existing user or make a neutral user to hold it.  When the installer script is run, the current user and its primary group is set as the default.  If a user is created for the VMs, make sure its primary group is the sharing group.  Otherwise, the user can be passed into the installer on the command line or by setting`VBOX_VM_USER`. 

Configuration is done primarily by the `Install.sh` script that will save the parameters to the `.service` file.  Custom values can be set in environment variables before the installer is run that override the default values.  After that, environment variables can be added or changed in the `.service` file in `/etc/systemd/system`.

The following variables can be set to control the installation locations:

* NEW\_NAME - Name other than `share-VBox-VM` to use for the `.service` and `.sh`.

* PREFIX - Directory in `$PATH` to install the script file.  Defaults to `/usr/local/sbin`.

* SYSTEMD\_SYSTEM - The [systemd](http://systemd.io/) directory to place the `.service` file into.  Defaults to `/etc/systemd/system`. 

The following values are always saved in the `.service` file and need to be set at installation either on the command line or by setting these variables:

* VBOX\_VM\_USER - User and group, separated by a colon a la `chown`, to be the primary owner of the VM files.  Defaults to the user and primary group running the `Install.sh` script.

* VBOX\_VM\_HOME - Path of the directory containing the VMs to manage.  Defaults to `/home/$USER/VM Images`.

The following variables can have values set in the `.service` file but have default values in the scrip:

* VBOX\_VM\_SHARE\_PID - PID file for the running instance of the service.  Defaults to `/var/run/user/$(id -u)/$(basename "${0%.*}").pid`.

* VBOX\_VM\_SHARE\_INTERVAL - Interval in seconds that the service will check for changes.  Defaults to 2 seconds.

* VBOX\_VM\_SHARE\_FILELIST - Shell globbing expression to select the files to manage.  Defaults to `.*/*\.(vbox|vmdk|vdi|vhd|nvram)` which includes the VM definition, the nvram of the VM, and the recognized harddrive image formats.

And one extra:

* DEBUG - Set to 1 to have `Install.sh` print the contents of the new `.service` file to STDOUT in addition to the file.

## Installation

Execute `Install.sh` as the VM primary owner:

    $ sudo -u <vmowner> [<envar>=<value> ...] ./Install.sh [<VBOX_VM_HOME>]

Or execute `Install.sh` and set as the VM primary owner and group:

    $ [VBOX_VM_USER="vmowner:vmgroup][<envar>=<value> ...] ./Install.sh  [<VBOX_VM_HOME>]

The service will be started automatically and set to start at boot-up.

## Version

<!-- $Id$ -->

$Revision$<br>$Tags$

## Copyright

&copy; 2020 Bion Pohl/Omega Pudding Software Some Rights Reserved

$Author$<br>$Email$
