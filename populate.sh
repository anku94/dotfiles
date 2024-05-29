#!/bin/bash

set -eux

# echo "Copying VIMRC"
# pwd
# cp ~/.vimrc $1/vimrc

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

copy_nvim_torepo
# copy_nvim_fromrepo
