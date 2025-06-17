#!/bin/bash

# This script can now perform two actions:
# 'push' (default): Commits and pushes the current config to GitHub.
# 'fetch': Fetches and resets the local config to match the remote repo.

#####################################################################
### Please set the paths accordingly. In case you don't have all  ###
### the listed folders, just keep that line commented out.        ###
#####################################################################
### Path to your config folder
config_folder=~/printer_data/config

### Path to your Klipper folder, by default that is '~/klipper'
klipper_folder=~/klipper

### Path to your Moonraker folder, by default that is '~/moonraker'
moonraker_folder=~/moonraker

### Path to your Mainsail folder, by default that is '~/mainsail'
mainsail_folder=~/mainsail

### The branch of the repository that you want to use
branch=main

db_file=~/printer_data/database/moonraker-sql.db

#####################################################################
################ !!! DO NOT EDIT BELOW THIS LINE !!! ################
#####################################################################
grab_version(){
  if [ ! -z "$klipper_folder" ]; then
    klipper_commit=$(git -C $klipper_folder describe --always --tags --long | awk '{gsub(/^ +| +$/,"")} {print $0}')
    m1="Klipper version: $klipper_commit"
  fi
  if [ ! -z "$moonraker_folder" ]; then
    moonraker_commit=$(git -C $moonraker_folder describe --always --tags --long | awk '{gsub(/^ +| +$/,"")} {print $0}')
    m2="Moonraker version: $moonraker_commit"
  fi
  if [ ! -z "$mainsail_folder" ]; then
    mainsail_ver=$(head -n 1 $mainsail_folder/.version)
    m3="Mainsail version: $mainsail_ver"
  fi
}

push_config(){
  # Copy database backup
  if [ -f $db_file ]; then
     echo "sqlite based history database found! Copying..."
     cp ~/printer_data/database/moonraker-sql.db ~/printer_data/config/
  else
     echo "sqlite based history database not found"
  fi
  
  # Add, commit, and push changes
  cd $config_folder
  git pull origin $branch --no-rebase
  git add .
  current_date=$(date +"%Y-%m-%d %T")
  git commit -m "Autocommit from $current_date" -m "$m1" -m "$m2" -m "$m3"
  git push origin $branch
}

fetch_config(){
  cd $config_folder
  git fetch
  git reset --hard origin/$branch
}

# Check for argument passed to the script
if [ "$1" = "fetch" ]; then
  echo "Fetching latest config from GitHub..."
  fetch_config
else
  echo "Backing up config to GitHub..."
  grab_version
  push_config
fi
