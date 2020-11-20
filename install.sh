#!/bin/bash

function log {
  echo $1
  echo
}

echo

hasDocker=$(which docker)
if [ -z "$hasDocker" ];
then
  log "You must install Docker"
  exit
fi

isDockerRunning=$(docker ps 2>&1 | egrep "CONTAINER ID")
if [ -z "$isDockerRunning" ];
then
  log "You must start Docker"
  exit
fi

hasFile=$(/bin/ls -1 | wc -l)
if [ "$hasFile" -gt 0 ];
then
  log "File or Directory exists - Aborting"
  exit
fi

src_dir=$(pwd)
dist_dir=$src_dir/viruscan-master

cd $src_dir && \
wget https://github.com/brisbanewebdeveloper/viruscan/archive/master.zip && \
unzip master.zip && \
rm -f master.zip && \
cd viruscan-master && \
log "Installing the commands" && \
docker-compose build && \
mkdir database && \
sed -iE "s|~/viruscan/clamav|$dist_dir/clamav|" $dist_dir/database/clamav && \
sed -iE "s|~/viruscan/yara|$dist_dir/yara|" $dist_dir/database/yara && \
chmod 700 clamav && \
chmod 700 yara && \
chmod 700 viruscan && \
cd - >/dev/null

echo ""
echo "1. Set PATH to the following commands:"
echo ""
echo $dist_dir/clamav
echo $dist_dir/yara
echo $dist_dir/viruscan
echo ""
echo "Example:"
echo "mkdir \$HOME/bin"
echo "cd \$HOME/bin"
echo "ln -s $dist_dir/clamav"
echo "ln -s $dist_dir/yara"
echo "ln -s $dist_dir/viruscan"
echo "echo \"export PATH=\$PATH:\$HOME/bin\" >> \$HOME/.bashrc"
echo ""
echo "2. Initialize the database directory:"
echo ""
echo "viruscan update"
echo ""
