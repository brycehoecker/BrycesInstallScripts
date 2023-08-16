#!/bin/bash

# Variables
URL="https://github.com/luigirizzo/netmap/archive/refs/tags/v11.3.tar.gz"
TARBALL_NAME="v11.3.tar.gz"
DIRECTORY_NAME="netmap-11.3"

# Check for kernel headers and devel packages
echo "Checking for kernel headers and devel packages"
if ! rpm -q kernel-headers-$(uname -r) > /dev/null 2>&1; then
    echo "Kernel headers for version $(uname -r) are not installed. Installing now..."
    sudo dnf install -y kernel-headers-$(uname -r)
fi

if ! rpm -q kernel-devel-$(uname -r) > /dev/null 2>&1; then
    echo "Kernel devel for version $(uname -r) are not installed. Installing now..."
    sudo dnf install -y kernel-devel-$(uname -r)
fi

# Download the tarball
echo "Downloading the tarball"
wget "$URL" -O "$TARBALL_NAME"

# Extract the tarball
echo "Extracting the tarball"
tar -xzvf "$TARBALL_NAME"

# Navigate to the extracted directory
echo "Navigating to the extracted directory"
cd "$DIRECTORY_NAME"

# Compile (this is done as a regular user)
echo "Running ./configure"
./configure 
echo "Running make"
make

# Install (this is where sudo is needed as per README)
echo "running sudo make install"
sudo make install

# Cleanup (Optional) - Assuming you have permissions to remove files in your current directory
#echo "moving up one directory"
#cd ..
#echo "removing directory and tarball"
#rm -rf "$DIRECTORY_NAME" "$TARBALL_NAME"

echo "Installation finished!"

