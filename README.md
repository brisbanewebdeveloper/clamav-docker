# Viruscan

Viruscan is a tool to find infected files on demand. If you would like this type of tool to be kept running, you should use the Docker Images directly instead ([This one](https://github.com/mko-x/docker-clamav) and [This one](https://github.com/blacktop/docker-yara)).

At the moment it uses following programs:

- [Clam AntiVirus (ClamAV)](https://www.clamav.net/)

- [YARA](https://virustotal.github.io/yara/)

## Requirements

- [Docker](https://www.docker.com/)

- You being enable to apply what this repository provides to suit to your situation

## Installation

### Automatic

```
curl 'https://raw.githubusercontent.com/brisbanewebdeveloper/viruscan/master/install.sh' | bash
```

Above command loads [this file](https://github.com/brisbanewebdeveloper/viruscan/blob/master/install.sh) to do the following:

- Create the directory `~/viruscan/src` and download the Zipped Version of this repository.

- Extract the files from the Zip File.

- Create Docker Image from the files extracted.

- Create the directory `~/bin`.

- Create sym-links for the commands `clamav`, `yara` and `viruscan` for the files extracted at above directory.

### Manual

```
# Create an empty directory
mkdir -p /somewhere

# Change the current directory to above directory
cd /somewhere

# Download files in the repository
# ("git clone" is not recommended because I may change things drastically)
wget https://github.com/brisbanewebdeveloper/viruscan/archive/master.zip

# Extract the Zip File
unzip master.zip
rm -f master.zip

# Create Docker Image
docker-compose build

# Enable to execute the shell scripts
chmod 110 clamav
chmod 110 yara
chmod 110 viruscan

# Change the current directory to create the sym-link
# The directory should be mentioned in PATH ENVIRONMENT VARIABLE
cd /somewhere-PATH-is-set/bin

# Create the sym-link to the shell script
ln -s /somewhere/viruscan-master/clamav .
ln -s /somewhere/viruscan-master/yara .
ln -s /somewhere/viruscan-master/viruscan .
```

## Usage

### Initialize/Update

This takes time like you could go to the toilet:

```
# Update the database directory
# This creates files at ~/viruscan
viruscan update
```

### Scan

#### Step 1

Change the current directory to run the scan

```
cd /suspicious/directory
```

#### Step 2

```
#
# Run the scan with ClamAV
# (Things between "-r" and "." are passed to "clamscan" command)
#
# "clamav" script uses "clamscan" command in Docker Container
# and it mounts "/suspicious/directory" as "read-only",
# meaning you must take out ":ro" in the script
# if you want to use the options like "--remove=yes"
#
clamav scan -r .

#
# Run the scan with Yara
# (Things between "-r" and "." are passed to "yara" command)
#
yara scan -wr .
```

OR

```
# This runs above in the way the output is stored in the a file "output_viruscan.txt"
viruscan go
```

### Example Usages

```
# Show help
# (You must pass the dummy directory at the moment)
clamav scan -h .
yara scan -h .
```

## Uninstall

### Simple Way

```
#
# DO NOT RUN THIS IF YOU INSTALLED MANUALLY
# Because I do not want you to delete something you need
#
# Amend accordingly if you need to
#
cd && \
sudo rm -fr ~/viruscan; \
rm -f ~/bin/clamav ~/bin/yara ~/bin/viruscan; \
docker rmi \
  $(docker images | egrep "^viruscan.*_command" | awk '{ print $1 }') \
  mkodockx/docker-clamav:alpine \
  blacktop/yara
```

### Manual

```
#
# 1. Remove the directory "~/viruscan" having the database files
#
#    You must delete this directory as "root"
#    because the database files are created by Docker Container
#    which the actual owner of the files are not your user account's
#
sudo rm -fr ~/viruscan

#
# 2. Remove the commands in "~/bin", the sym-links
#
rm -f ~/bin/clamav ~/bin/yara ~/bin/viruscan
# If you do not need ~/bin
rmdir ~/bin

#
# 3. Remove Docker Images
#
docker rmi \
  $(docker images | egrep "^viruscan.*_command" | awk '{ print $1 }') \
  mkodockx/docker-clamav:alpine \
  blacktop/yara

# Uninstall Docker if not using
```

## I don't like how it works

You can copy an existing script and then create your own.

## Related Post

[Scan a directory to find infected files with Docker and Clam AntiVirus (ClamAV)](https://dev.to/brisbanewebdeveloper/scan-infected-files-with-docker-and-clam-antivirus-clamav-1939)

## Things used and/or referred for this tool

- [Docker](https://www.docker.com/)

- [docker-clamav](https://github.com/mko-x/docker-clamav)

  + [Dockerfile](https://github.com/mko-x/docker-clamav/blob/master/alpine/main/Dockerfile)

- [Clam AntiVirus (ClamAV)](https://clamav.net/)

- [RFXN (R-FX NETWORKS) Database signature at R-FX NETWORKS](https://www.rfxn.com/)

  + [Extending ClamAV Signatures with RFXN Database for PHP Malware’s](https://malware.expert/howto/extending-clamav-signatures-with-rfxn-database-for-php-malwares/)

- [ClamAV Unofficial Signatures Updater](https://github.com/extremeshok/clamav-unofficial-sigs.git)

- [lw-yara](https://github.com/Hestat/lw-yara.git)

- [Yara Dockerfile](https://github.com/blacktop/docker-yara)

- [Yara Rules](https://github.com/Yara-Rules/rules)

- [Awesome YARA](https://github.com/InQuest/awesome-yara)

- [Finding PHP and WordPress Backdoors using antivirus and Indicator of Compromise](https://blog.wpsec.com/finding-php-and-wordpress-backdoors-using-antivirus-and-indicator-of-compromise/)

  + [Loki - Simple IOC Scanner](https://github.com/Neo23x0/Loki)
