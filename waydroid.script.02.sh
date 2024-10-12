#!/bin/bash

# Variables
ROOT_PART="/dev/sda1"
BOOT_PART="/dev/sda"  # The disk where GRUB will be installed

# Step 1: Mount the root partition
echo "Mounting the root partition..."
sudo mount $ROOT_PART /mnt

# Step 2: Mount essential system directories
echo "Mounting /dev, /proc, /sys..."
sudo mount --bind /dev /mnt/dev
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys

# Step 3: Chroot into the installed system
echo "Entering chroot environment..."
sudo chroot /mnt /bin/bash <<EOF

# Step 4: Reinstall GRUB to the bootloader
echo "Reinstalling GRUB..."
grub-install $BOOT_PART

# Step 5: Update GRUB configuration
echo "Updating GRUB configuration..."
update-grub

# Exit chroot
EOF

# Step 6: Unmount all mounted partitions
echo "Unmounting /dev, /proc, /sys..."
sudo umount /mnt/dev
sudo umount /mnt/proc
sudo umount /mnt/sys

# Step 7: Unmount the root partition
echo "Unmounting root partition..."
sudo umount /mnt

echo "GRUB reinstallation complete. You can now reboot your system."
