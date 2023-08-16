#!/bin/bash

# Required dependencies for Geany and its plugins (some may be already present in your system)
DEPENDENCIES="gcc gcc-c++ make pkgconfig gtk3-devel libxml2-devel python3-docutils doxygen-latex doxygen pango ghc-pango-devel ghc-pango pango-devel pangomm pangomm-devel kernel-cross-headers kernel-headers ghc-glib-devel glibc-headers PackageKit-glib-devel glib2-devel glib2-static glibc-devel atk-devel"

# URLs to download Geany and its plugins
GEANY_URL="https://download.geany.org/geany-1.38.tar.gz"
GEANY_PLUGINS_URL="https://plugins.geany.org/geany-plugins/geany-plugins-1.38.tar.gz"

GEANY_TAR="geany-1.38.tar.gz"
GEANY_PLUGINS_TAR="geany-plugins-1.38.tar.gz"

GEANY_DIR="geany-1.38"
GEANY_PLUGINS_DIR="geany-plugins-1.38"

# Check if the user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or use sudo"
  exit
fi

# Install required dependencies
echo "Installing required dependencies..."
sudo dnf install -y $DEPENDENCIES

# Download Geany
echo "Downloading Geany..."
curl -O $GEANY_URL

# Extract Geany
echo "Extracting Geany..."
tar xzf $GEANY_TAR

# Navigate to the Geany directory
cd $GEANY_DIR

# Configure, compile, and install Geany
echo "Running autogen.sh from geany"
./autogen.sh
echo "Configuring Geany..."
./configure
echo "Compiling Geany..."
make
echo "Running make check for Geany..."
make check
echo "Installing Geany..."
sudo make install

# After installing Geany and before configuring the plugins, update PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

# Go back to the original directory
cd ..

# Check if Geany was installed correctly
#if ! command -v geany &> /dev/null
#then
#    echo "Geany installation failed. Exiting."
#    exit 1
#fi

# Now continue with the plugin installation

# Download Geany plugins
echo "Downloading Geany plugins..."
curl -O $GEANY_PLUGINS_URL

# Extract the plugins tarball
echo "Extracting Geany plugins..."
tar xzf $GEANY_PLUGINS_TAR

# Navigate to the Geany plugins directory
cd $GEANY_PLUGINS_DIR

# Configure, compile, and install Geany plugins
echo "Running autogen.sh from Geany plugins"
./autogen.sh
echo "Configuring Geany plugins..."
./configure
echo "Compiling Geany plugins..."
make
echo "Running make check for Geany plugins..."
make check
echo "Installing Geany plugins..."
sudo make install

# Clean up
cd ..
rm -r $GEANY_DIR $GEANY_PLUGINS_DIR
rm $GEANY_TAR $GEANY_PLUGINS_TAR

# Provide a completion message
echo "Geany and its plugins have been installed successfully!"

if [ "$SUDO_USER" ]; then
    HOME=$(eval echo ~$SUDO_USER)
fi

echo "Changing Geany configs so the underlines words show up"
# Define the path to search in, starting with the user's home directory.
SEARCH_PATH="$HOME/.config/geany/filedefs"

# Check if the directory exists
if [ ! -d "$SEARCH_PATH" ]; then
    echo "Directory $SEARCH_PATH not found."
    exit 1
fi

# Search for the file and perform the replacements using sed.
find "$SEARCH_PATH" -type f -name 'filetypes.common' | while read -r file; do
    echo "Processing $file..."
    
    # Backup the original file
    cp "$file" "$file.bak"
    
    # Use sed to perform the replacements
    sed -i 's/#~ \[styling\]/[styling]/' "$file"
    sed -i 's/#~ line_height=0;0;/line_height=-1;1;/' "$file"
done

echo "Done."

