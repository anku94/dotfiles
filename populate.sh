#!/bin/bash

set -eux

# echo "Copying VIMRC"
# pwd
# cp ~/.vimrc $1/vimrc
#
is_repo_clean() {
  return $(git diff-index --quiet HEAD --)
}

confirm_assume_yes() {
  # echo "[Y/n]" and return 0 if n, 1 otherwise
  read -p "Are you sure? [Y/n] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    return 0
  fi

  return 1
}

confirm_assume_no() {
  # echo "[y/N]" and return 0 if y, 1 otherwise
  read -p "Are you sure? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 0
  fi

  return 1
}

check_if_repo_clean() {
  # is_repo_clean || echo "Repo is dirty"
  confirm_assume_yes || echo "Confirmed"
}

copy_nvim_torepo() {
  local nvim_root=~/.config/nvim
  local dest="nvim"

  rm -rf $dest
  mkdir -p $dest

  cp $nvim_root/init.lua $dest
  cp -r $nvim_root/lua $dest
}

copy_nvim_fromrepo() {
  local src="nvim"
  local nvim_root=~/.config/nvim

  mv $nvim_root ${nvim_root}.bak

  mkdir -p $nvim_root
  cp $src/init.lua $nvim_root
  cp -r $src/lua $nvim_root
}

# copy_nvim_torepo
# copy_nvim_fromrepo
# check_if_repo_clean

run() {
  # if condition, if is_repo_clean is true, print clean else false
  if is_repo_clean; then
    echo "Repo is clean. Copy nvim to repo?"
    confirm_assume_yes || exit 0
  else
    echo "Repo is dirty"
  fi
}

run
