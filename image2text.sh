#!/bin/bash
# Script name: image2text.sh
# Author: Curtis K (www.centosblog.com)
# URL: http://www.centosblog.com/how-to-convert-an-image-to-text-on-centos-linux
# Description: this script will use tesseract and ImageMagick to convert an image to text.
# Script usage: ./image2text.sh <URL> <output_file>

# Variables
tmp_dir="/tmp" # change this if your temporary directory is *not* /tmp

# Error function
function error {

	_error_message=$1

	echo "Error: $_error_message"
	exit 1

}

# Check number of arguments
[ $# -eq 2 ] || error "Script usage: ./image2text.sh <URL> <output_file>"

# Check that tesseract is installed
[ `which tesseract 2> /dev/null` ] || error "Please install tesseract."

# Check that ImageMagick convert is installed
[ `which convert 2> /dev/null` ] || error "Please install ImageMagick."

# Check that wget is installed
[ `which wget 2> /dev/null` ] || error "Please install wget."

# 
URL="$1"
OUTPUT="$2"
TMP_NAME=`mktemp`

echo ""

if [ -f "$OUTPUT.txt" ]; then

echo -n "Warning: File $OUTPUT.txt already exists. Please press enter to continue, or press CTRL+C to quit now."
read pause < /dev/tty
echo ""
fi

echo "Downloading file: $URL"

wget "$URL" -O "$TMP_NAME-download" > /dev/null 2>&1

# Check wget exit status
if [ $? -ne 0 ]; then error "Unable to retrieve file $URL" ; fi

	IMG_CHECK=`identify "$TMP_NAME-download" > /dev/null 2>&1`

if [ $? -ne 0 ]; then
	error "Unable to identify image type for $URL."
fi

EXT=`identify "$TMP_NAME-download" | awk '{ print $2 }' | tr '[:upper:]' '[:lower:]' 2> /dev/null`

if [ "$EXT" != "tif" ] && [ "$EXT" != "bmp" ] ; then # Image conversion required

	echo "Detected image format: $EXT"
	echo "Converting image"
	convert "$TMP_NAME-download" "$TMP_NAME.tif" > /dev/null 2>&1
	tesseract "$TMP_NAME.tif" "$OUTPUT" > /dev/null 2>&1
	echo "Cleaning up..."
	rm -f "$TMP_NAME" "$TMP_NAME.tif" "$TMP_NAME-download"

else

	echo "Detected image format: $EXT"
	tesseract "$TMP_NAME.tif" "$OUTPUT" > /dev/null 2>&1
	echo "Cleaning up..."
	rm -f "$TMP_NAME" "$TMP_NAME-download"

fi

if [ $? -eq 0 ]; then

	echo "Conversion of $URL completed successfully!"
	echo "Text has been saved to: $OUTPUT.txt"

else

	echo "Conversion of $URL failed. "

fi
