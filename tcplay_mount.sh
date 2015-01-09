#!/bin/bash
# This function should be included in the .bashrc to allow the usage
# of the command <tc_mount>, which mounts a truecrypt container.
# To use this script the tool tcplay (https://github.com/bwalex/tc-play) 
# is required.
# The script takes to arguments, namely
# 	- the truecrypt container to mount (/path/to/truecrypt_container)
# 	- the folder to mount to
#
# Hint: If you shutdown or reboot your computer *without* dismounting
#       your devices before, the helpfile will contain invalid entries.
#		Therefore you should ensure that your devices are unmounted
#		correctly or clear the helpfile.
#
# Written and contributed by
#        Andre Doser <dosera AT gmail.com>

mnt_dir="/specify/mount/dir"
helpfile=".tc_mount_helper"
function tc_mount()
{
	# expect exactly 2 arguments
	if [ "$#" -ne 2 ]; then
    	echo -e "Usage:\n $FUNCNAME <truecrypt device/file> <mountpoint>\n\nThe mountpoint will be created in $mnt_dir/."
	else
		if mountpoint -q "$mnt_dir/$2";
		then
			# extract the loop device with sed
			loop_dev=$(sed -n "s/^$2://p" "$helpfile")
			# remove that line from the helper file
			sed -i "/^$2:/d" "$helpfile"
			# unmount...
			sudo umount "$mnt_dir/$2"
			sudo dmsetup remove "$2"
			sudo losetup -d "$loop_dev"
			echo "Unmounted $1 from $mnt_dir/$2. $loop_dev is now free."
		# mount
		else
			# first free loop device
			loop_dev=$(sudo losetup -f)
			# create the dir if it doesn't exist
			sudo mkdir -p "$mnt_dir/$2"
			# mount...
			echo "Mounting $1 to $mnt_dir/$2 using $loop_dev."
			sudo losetup "$loop_dev" "$1"
	        sudo tcplay -m "$2" -d "$loop_dev"
	        sudo mount -o nodev,nosuid,uid=1000,gid=100 /dev/mapper/"$2" "$mnt_dir/$2"
	        # save the loop device to correctly dismount it later!
			echo "$2"":""$loop_dev" >> "$helpfile"
		fi
	fi
}
