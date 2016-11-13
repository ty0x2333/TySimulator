#!/bin/sh
SRC_FILE=$1
DST_PATH=$2

if [ -z "$DST_PATH" ]; then
    DST_PATH=$(dirname $0)
fi

error() {
     local red="\033[1;31m"
     local normal="\033[0m"
     echo "[${red}ERROR${normal}] $1"
}

# Check ImageMagick
command -v convert >/dev/null 2>&1 || { error >&2 "The ImageMagick is not installed. Please install it first.see http://www.imagemagick.org/"; exit -1; }

if [ -z $SRC_FILE ]
  then
    echo "No argument given"
else
  convert "$SRC_FILE" -resize 16x16     "$DST_PATH/Icon-16.png"
  convert "$SRC_FILE" -resize 32x32     "$DST_PATH/Icon-16@2x.png"
  convert "$SRC_FILE" -resize 32x32     "$DST_PATH/Icon-32.png"
  convert "$SRC_FILE" -resize 64x64     "$DST_PATH/Icon-32@2x.png"
  convert "$SRC_FILE" -resize 128x128   "$DST_PATH/Icon-128.png"
  convert "$SRC_FILE" -resize 256x256   "$DST_PATH/Icon-128@2x.png"
  convert "$SRC_FILE" -resize 256x256   "$DST_PATH/Icon-256.png"
  convert "$SRC_FILE" -resize 512x512   "$DST_PATH/Icon-256@2x.png"
  convert "$SRC_FILE" -resize 512x512   "$DST_PATH/Icon-512.png"
  convert "$SRC_FILE" -resize 1024x1024 "$DST_PATH/Icon-512@2x.png"
fi
