#!/bin/bash

set -eux

# echo "Copying VIMRC"
# pwd
# cp ~/.vimrc $1/vimrc

copy_nvim() {
  local nvim_root=~/.config/nvim
  local dest="nvim"

  rm -rf $dest
  mkdir -p $dest

  cp $nvim_root/init.lua $dest
  cp -r $nvim_root/lua $dest
}

copy_nvim
