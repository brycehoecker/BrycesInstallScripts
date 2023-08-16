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
# Define the path to search in, starting with the user's home directory.
SEARCH_PATH="$HOME/.config/geany/filedefs"

# Check if the directory exists
if [ ! -d "$SEARCH_PATH" ]; then
    echo "Directory $SEARCH_PATH not found. Creating..."
    mkdir -p "$SEARCH_PATH"
fi

# Path to the filetypes.common file
FILE_PATH="$SEARCH_PATH/filetypes.common"

# Check if the file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "$FILE_PATH not found. Creating..."
    # Create the file and add the necessary lines
    echo "[styling]" >> "$FILE_PATH"
    echo "line_height=-1;1;" >> "$FILE_PATH"
    echo "File created and lines added."
    exit 0 # Exit after creating the file and adding lines
fi

# If the file exists, proceed with the replacements
# Flag to track if a replacement was made
REPLACEMENT_MADE=0

# Search for the file and perform the replacements using sed.
if grep -q '#~ \[styling\]' "$FILE_PATH" || grep -q '#~ line_height=0;0;' "$FILE_PATH"; then
    REPLACEMENT_MADE=1
    
    # Backup the original file
    cp "$FILE_PATH" "$FILE_PATH.bak"
    
    # Use sed to perform the replacements
    sed -i 's/#~ \[styling\]/[styling]/' "$FILE_PATH"
    sed -i 's/#~ line_height=0;0;/line_height=-1;1;/' "$FILE_PATH"
    echo "Replacements made in $FILE_PATH."
else
    echo "Patterns not found in $FILE_PATH. No changes made."
fi

# Provide a summary of what happened
if [ "$REPLACEMENT_MADE" -eq 0 ]; then
    echo "No replacements were made in the file."
else
    echo "Done with replacements."
fi
