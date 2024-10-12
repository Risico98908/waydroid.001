 
#!/bin/bash

# Set variables for partitions and mount points
ROOT_PART="/dev/sda1"   # Root partition
SWAP_PART="/dev/sda2"   # Swap partition

# Step 1: Update package lists and install required tools
sudo apt update
sudo apt install -y rsync grub2 fdisk

# Step 2: Create partitions (assuming /dev/sda is your virtual disk)
echo "Creating partitions on /dev/sda..."
(
echo o      # Create a new DOS partition table
echo n      # New partition
echo p      # Primary partition
echo 1      # Partition number 1
echo        # Default - start at beginning of disk
echo +20G   # 20GB root partition
echo n      # New partition
echo p      # Primary partition
echo 2      # Partition number 2
echo        # Default - start immediately after previous partition
echo        # Default - use the rest of the disk for swap
echo t      # Change partition type
echo 2      # Select partition 2 (swap)
echo 82     # Linux swap partition type
echo w      # Write changes
) | sudo fdisk /dev/sda

# Step 3: Format the partitions
echo "Formatting the partitions..."
sudo mkfs.ext4 $ROOT_PART
sudo mkswap $SWAP_PART

# Step 4: Mount the new root partition
echo "Mounting the root partition..."
sudo mount $ROOT_PART /mnt

# Step 5: Copy the live system files to the new root partition
echo "Copying live system files..."
sudo rsync -aAXv / /mnt --exclude={/dev,/proc,/sys,/tmp,/run,/mnt,/media,/lost+found}

# Step 6: Set up swap
echo "Setting up swap..."
sudo swapon $SWAP_PART

# Step 7: Mount the necessary filesystems in the new root
echo "Mounting essential filesystems..."
sudo mount --bind /dev /mnt/dev
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys

# Step 8: Chroot into the new system
echo "Entering chroot environment..."
sudo chroot /mnt /bin/bash <<'EOF'

# Inside chroot: Install GRUB and update the system
echo "Installing GRUB bootloader..."
apt update
apt install -y grub2
grub-install /dev/sda
update-grub

# Exit chroot environment
EOF

# Step 9: Cleanup and unmount partitions
echo "Cleaning up and unmounting partitions..."
sudo umount /mnt/dev
sudo umount /mnt/proc
sudo umount /mnt/sys
sudo umount /mnt

# Step 10: Reboot into the installed system
echo "Installation complete. Rebooting..."
sudo reboot
