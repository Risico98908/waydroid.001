#!/bin/bash

# Variables
TARGET_DISK="/dev/sda"
ROOT_PARTITION="/dev/sda1"
BOOT_PARTITION="/dev/sda"  # The disk where GRUB will be installed

# Step 1: Partition the Disk
echo "Creating partition table on $TARGET_DISK..."
sudo parted $TARGET_DISK mklabel msdos

echo "Creating root partition..."
sudo parted $TARGET_DISK mkpart primary ext4 1MiB 100%

# Step 2: Inform the Kernel of Partition Table Changes
echo "Informing the kernel of partition changes..."
sudo partprobe $TARGET_DISK  # You can also use udevadm trigger

# Step 3: Format the Root Partition
echo "Formatting the root partition..."
sudo mkfs.ext4 $ROOT_PARTITION

# Step 4: Mount the Root Partition
echo "Mounting the root partition..."
sudo mount $ROOT_PARTITION /mnt

# Step 5: Copy Live System Files to the Root Partition
echo "Copying live system files to the root partition..."
sudo rsync -aAXv / /mnt --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"}

# Step 6: Mount necessary filesystems
echo "Mounting necessary filesystems..."
sudo mount --bind /dev /mnt/dev
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys

# Step 7: Chroot into the Target System
echo "Entering chroot environment..."
sudo chroot /mnt /bin/bash <<EOF

# Step 8: Install GRUB Bootloader
echo "Installing GRUB bootloader..."
grub-install $BOOT_PARTITION

# Step 9: Update GRUB Configuration
echo "Updating GRUB configuration..."
update-grub

# Step 10: Exit chroot
EOF

# Step 11: Unmount filesystems
echo "Unmounting filesystems..."
sudo umount /mnt/dev
sudo umount /mnt/proc
sudo umount /mnt/sys

# Step 12: Unmount the root partition
sudo umount /mnt

echo "Installation complete. You can now reboot into the installed system."
