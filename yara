#!/bin/bash

#
# Maintainer: Brisbane Web Developer <brisbanewebdeveloper@outlook.com>
#

hasDocker=$(which docker)
if [ -z "$hasDocker" ];
then
  echo "You must install Docker"
  exit
fi

image=blacktop/yara

#
# Download Docker Image if not downloaded
#
hasImage=$(docker images | egrep "^$image")
if [ -z "$hasImage" ];
then
  echo
  echo "Building the image"
  docker pull $image
fi

#
# This script creates the database directory under your home directory
#
base_dir=~/viruscan/yara
if [ ! -d "$base_dir" ];
then
  mkdir -p $base_dir && \
  chmod 777 $base_dir && \
  echo "Created $base_dir"
fi

#
# Enabled to scan with https://github.com/Yara-Rules/rules
#
yara_rules="$base_dir/Yara-Rules"
if [ ! -d "$yara_rules" ];
then
  echo "Downloading Yara Ruleset to $yara_rules"
  git clone https://github.com/Yara-Rules/rules.git $yara_rules
fi

cmd=$1

#
# Update the database
#
if [ "$cmd" == "update" ];
then

  echo
  echo "Updating the directory $base_dir"
  echo

  cd $yara_rules && \
  git fetch && \
  git reset --hard origin/master && \
  cd - > /dev/null

  exit

fi

#
# Scan
#
if [ "$cmd" == "scan" ];
then

  #
  # The last argument is to be the path to scan and it needs to be absolute path
  # In case you want to avoid figuring the exact path, you can do like this:
  #
  # cd directory_to_scan; yara .
  # yara $(pwd)/directory_to_scan
  #
  scan_dir=${!#}

  if [ "$scan_dir" == "." ];
  then
    scan_dir=$(pwd)
  fi

  if [ ! -d "$scan_dir" ];
  then
    echo "Invalid directory $scan_dir"
    exit
  fi

  # Take out the first and last argument
  set -- "${@:2:$(($#-2))}"

  echo
  echo "[Yara]"
  echo "Scanning directory $scan_dir"
  echo "Args: $@"
  echo

  docker \
    run \
    --rm \
    -v $base_dir:/rules:ro \
    -v $scan_dir:/malware:ro \
    $image \
    $@ \
    /rules/Yara-Rules/index.yar \
    /malware 2>&1 | \
  sed -E 's/ \/malware/ ./g'

  echo
  echo "Done"
  echo

  exit

fi

#
# Unknown Command
#

#
# The default behaviour which is to run "yara" command
#
echo "Usage 1: $(basename $0) update"
echo "Usage 2: $(basename $0) scan ."
