#!/bin/bash

# Variables
PERSISTENCE_PART="/dev/sdc1"
MOUNT_POINT="/mnt/persistence"

# Step 1: Create and format the persistence partition
echo "Creating and formatting persistence partition..."
sudo mkfs.ext4 -L persistence $PERSISTENCE_PART

# Step 2: Create mount point and mount the partition
echo "Mounting the persistence partition..."
sudo mkdir -p $MOUNT_POINT
sudo mount $PERSISTENCE_PART $MOUNT_POINT

# Step 3: Create the persistence.conf file
echo "Creating persistence.conf file..."
sudo bash -c "echo '/ union' > $MOUNT_POINT/persistence.conf"

# Step 4: Unmount the persistence partition
echo "Unmounting the persistence partition..."
sudo umount $MOUNT_POINT

# Step 5: Inform the user to modify GRUB at boot for persistence
echo "Script completed. Now, during boot, edit the GRUB boot parameters and add 'persistence' at the end of the 'linux' line to enable persistence."
