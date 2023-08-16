#!/bin/bash

# Define the URL of the tarball
TARBALL_URL="https://github.com/appneta/tcpreplay/releases/download/v4.4.4/tcpreplay-4.4.4.tar.gz"

# Define the destination directory
DEST_DIR="/usr/local/lib"

# Create the destination directory if it doesn't exist
mkdir -p $DEST_DIR

# Navigate to the directory
cd $DEST_DIR

# Download the tarball
wget $TARBALL_URL

# Extract the tarball
tar xzf tcpreplay-4.4.4.tar.gz

# Navigate to the extracted directory
cd tcpreplay-4.4.4

# Install dependencies
sudo dnf install -y gcc libpcap-devel

# Run the autoreconf command to generate a viable ./configure file if necessary. You may need to install the 'autoconf' and 'automake' packages for this.
# autoreconf --install

# Configure the package
./configure

# Compile the package
make

# Install the package
sudo make install

# Note: These commands are a general guide and may vary based on your specific system configuration and the specific version of the package you're installing.

