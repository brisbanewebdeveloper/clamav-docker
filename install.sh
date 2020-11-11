#!/bin/bash

function log {
  echo $1
  echo
}
function check_dir {
  if [ -d $1 ];
  then
    log "Directory $1 exists - Please remove it and then try again"
    exit
  fi
}
function check_file {
  if [ -L $1 ] || [ -e $1 ];
  then
    log "File $1 exists - Please remove it and then try again"
    exit
  fi
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

src_dir=~/viruscan/src
if [ ! -d "$src_dir" ];
then
  mkdir -p $src_dir && \
  chmod 777 $src_dir && \
  log "Created $src_dir"
fi
check_dir $src_dir/viruscan-master
check_dir $src_dir/master.zip

bin_dir=~/bin
if [ ! -d "$bin_dir" ];
then
  mkdir -p $bin_dir && \
  chmod 777 $bin_dir && \
  log "Created $bin_dir"
fi
check_file $bin_dir/clamav
check_file $bin_dir/yara
check_file $bin_dir/viruscan

cd $src_dir && \
wget https://github.com/brisbanewebdeveloper/viruscan/archive/master.zip && \
unzip master.zip && \
rm -f master.zip && \
cd viruscan-master && \
log "Installing the commands" && \
docker-compose build && \
chmod 700 clamav && \
chmod 700 yara && \
chmod 700 viruscan && \
ln -s $src_dir/viruscan-master/clamav $bin_dir/clamav && \
ln -s $src_dir/viruscan-master/yara $bin_dir/yara && \
ln -s $src_dir/viruscan-master/viruscan $bin_dir/viruscan && \
log "Installed the commands to $bin_dir" && \
cd - >/dev/null

test=$(which viruscan)
if [ -z "test" ];
then
  log "You must include $bin_dir to PATH"
fi
