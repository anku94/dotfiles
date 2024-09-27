#!/usr/bin/env zsh

set -eu

# Declare an associative array (source -> destination)
typeset -A DOTFILES_MAP

# Define your dotfiles mapping here
DOTFILES_MAP=(
  "nvim/init.lua" "$HOME/.config/nvim/init.lua"
  "nvim/lua" "$HOME/.config/nvim/lua"
  "nvim/patches" "$HOME/.config/nvim/patches"
  "style/efm-langserver.yaml" "$HOME/.config/efm-langserver/config.yaml"
)

REPO_ROOT=$(git rev-parse --show-toplevel)
SCRIPT_DIR=$(realpath $(dirname "$0"))

echo "-INFO- dotfiles root: $REPO_ROOT"
echo "-INFO- script root: $SCRIPT_DIR"

if [ "$REPO_ROOT" != "$SCRIPT_DIR" ]; then
  echo " -ERROR- Script was supposed to be at the root of the repo"
  exit 1
fi

create_softlink() {
  local ln_src=$1
  local ln_dest=$2

  ln_src_realpath=$(realpath "$ln_src")

  if [ -e "$ln_dest" ]; then
    echo "File exists at $ln_dest. Skipping..."
  else
    ln -s "$ln_src_realpath" "$ln_dest"
    echo "Created softlink for $ln_src_realpath at $ln_dest"
  fi
}

# Function to setup_dotfiles if a softlink exists at each destination
setup_dotfiles() {
  echo "\nChecking for existing softlinks..."

  for file in "${(k)DOTFILES_MAP[@]}"; do
    echo "\n-INFO- Checking $file"
    # if file does not exist at source
    if [ ! -e "$file" ]; then
      echo "   !!!! File does not exist at $file"
      continue
    fi

    destination="${DOTFILES_MAP[$file]}"
    if [ -L "$destination" ]; then
      echo "   - Softlink exists at $destination"
    else
      echo "   !!!! Softlink does not exist at $destination"
      create_softlink "$file" "$destination"
    fi
  done
}

# Function for macOS
run_osx() {
  echo "\n-INFO- MacOS-specific setup"
}

# Function for Ubuntu
run_ub() {
  echo "\n-INFO- Ubuntu-specific setup"
}

# Function to check the platform and run the appropriate function
run_platformwise() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    run_osx
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v lsb_release &> /dev/null && lsb_release -i | grep -qi ubuntu; then
      run_ub
    else
      echo "Unknown Linux distribution."
    fi
  else
    echo "Unsupported platform."
  fi
}

# first, cd to the directory containing this script
echo "-INFO- Changing directory to $REPO_ROOT"
cd $REPO_ROOT

usage() {
  local script=$1
  echo "Usage: $script {setup}"
  exit 1
}

# if nargs != 1, print usage
[ $# -eq 1 ] || usage $0

# Main logic to parse arguments
case "$1" in
  setup)
    setup_dotfiles
    run_platformwise
    ;;
  *)
    usage $0
    ;;
esac
