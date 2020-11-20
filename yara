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

# image=blacktop/yara
image=viruscan_yara_command
yara=/usr/local/bin/yara

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
  target=${!#}

  isFile=0
  if [[ "$target" =~ ^file:// ]];
  then
    isFile=1
  fi

  if [ "$isFile" -eq 0 ];
  then

    if [ "$target" == "." ];
    then
      target=$(pwd)
    fi

    if [ ! -d "$target" ];
    then
      echo "Invalid directory $target"
      exit
    fi

  else

    target=$(echo "$target" | sed -E 's|file://||')

    if [ ! -f "$target" ];
    then
      echo "File $target not found"
      exit
    fi

  fi

  # Take out the first and last argument
  set -- "${@:2:$(($#-2))}"

  if [ "$isFile" -eq 0 ];
  then

    if [ "$1" == "--daemon-start" ];
    then
      # - Run in detached mode
      # - Return Container ID
      echo $(docker \
        container \
        run \
        -d \
        -v $base_dir:/rules:ro \
        -v $target:/malware:ro \
        $image \
        /usr/bin/tail -f /dev/null)
      exit
    fi

    echo
    echo "[Yara]"
    echo "Scanning directory $target"
    echo "Args: $@"
    echo

    docker \
      run \
      --rm \
      -v $base_dir:/rules:ro \
      -v $target:/malware:ro \
      $image \
      $yara \
      $@ \
      /rules/Yara-Rules/index.yar \
      /malware 2>&1 | \
    sed -E 's/ \/malware/ ./g'

    echo
    echo "Done"
    echo

  else

    #
    # Scan with existing container
    #
    # - To be started with "--daemon-start" at first
    #
    if [[ "$1" =~ ^--container ]];
    then

      image=$(echo $1 | sed -E 's/^--container=//')

      # Take out the first argument
      set -- "${@:2:$#}"

      docker \
        exec \
        $image \
        $yara \
        $@ \
        /rules/Yara-Rules/index.yar \
        /malware/$target 2>&1 | \
      sed -E 's/ \/malware/ ./g'

    #
    # This is slow if you were trying to check the files individually in a directory
    #
    # - Shifting to the new way, creating my own Docker Image to enable to keep running
    #   by running this in detached mode at first, and I feel that is slightly faster
    #
    else

      docker \
        run \
        --rm \
        -v $base_dir:/rules:ro \
        -v $target:/malware/file:ro \
        $image \
        $yara \
        $@ \
        /rules/Yara-Rules/index.yar \
        /malware/$target 2>&1 | \
      sed -E 's/ \/malware/ ./g'

    fi

  fi

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
