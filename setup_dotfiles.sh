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

# Initialize DRYRUN flag
DRYRUN=0

REPO_ROOT=$(git rev-parse --show-toplevel)
SCRIPT_DIR=$(realpath $(dirname "$0"))
DOWNLOAD_DIR="$REPO_ROOT/bin"

echo "-INFO- dotfiles root: $REPO_ROOT"
echo "-INFO- script root: $SCRIPT_DIR"
[[ $DRYRUN -eq 1 ]] && echo "-INFO- Running in dry-run mode"

if [ "$REPO_ROOT" != "$SCRIPT_DIR" ]; then
  echo " -ERROR- Script was supposed to be at the root of the repo"
  exit 1
fi


download_file() {
  local name=$1
  local url=$2
  local dest="$DOWNLOAD_DIR/$name"

  if [ $DRYRUN -eq 1 ]; then
    echo "-INFO- Would download $name from $url"
    return
  fi

  if [ -e "$dest" ]; then
    echo "-INFO- $name already exists in $DOWNLOAD_DIR"
    return
  fi

  echo "-INFO- Downloading $name from $url"
  if command -v curl &> /dev/null; then
    curl -L -o "$dest" "$url"
  elif command -v wget &> /dev/null; then
    wget -O "$dest" "$url"
  else
    echo "-ERROR- Neither curl nor wget is available."
    exit 1
  fi
}

add_to_path() {
  local binary=$1
  local binary_dir=${2:-"$DOWNLOAD_DIR"}

  local shell_config
  local binary_path="$binary_dir/$binary"

  if [ $DRYRUN -eq 1 ]; then
    echo "-INFO- Would add $binary_dir to PATH"
    return
  fi

  if [ ! -e "$binary_path" ]; then
    echo "-INFO- Skipping PATH addition. $binary not found in $binary_dir."
    return
  fi

  # Validate that the file is a proper executable
  if ! file "$binary_path" | grep -q "executable"; then
    echo "-ERROR- $binary is not a valid executable. Skipping."
    rm -f "$binary_path"
    return
  fi

  # Determine the active shell configuration file
  case "$SHELL" in
    */zsh) shell_config="$HOME/.zshrc" ;;
    */bash) shell_config="$HOME/.bashrc" ;;
    *) echo "-ERROR- Unsupported shell: $SHELL"; exit 1 ;;
  esac

  # Add the binary directory to PATH if not already added
  if ! grep -q "$binary_dir" "$shell_config"; then
    echo "-INFO- Adding $binary_dir to PATH in $shell_config"
    echo "export PATH=\"$binary_dir:\$PATH\"" >> "$shell_config"
  fi
}

# Function to backup and copy tmux.conf
setup_tmux_conf() {
  local src="$REPO_ROOT/tmux.conf"
  local dest="$HOME/.tmux.conf"

  if [ $DRYRUN -eq 1 ]; then
    echo "-INFO- Would copy tmux.conf to $dest"
    return
  fi

  if [ -e "$dest" ]; then
    echo "-INFO- tmux.conf already exists at $dest."
    echo "Choose an action:"
    echo "  [b] Backup the existing tmux.conf"
    echo "  [o] Overwrite the existing tmux.conf"
    read -r -p "Enter your choice (b/o): " choice

    case "$choice" in
      b)
        mv "$dest" "${dest}.backup.$(date +%s)"
        echo "-INFO- Backed up existing tmux.conf to ${dest}.backup.$(date +%s)"
        ;;
      o)
        echo "-INFO- Overwriting the existing tmux.conf"
        ;;
      *)
        echo "-ERROR- Invalid choice. Aborting tmux.conf setup."
        return
        ;;
    esac
  fi

  cp "$src" "$dest"
  echo "-INFO- Copied tmux.conf to $dest"
}

create_softlink() {
  local ln_src=$1
  local ln_dest=$2

  ln_src_realpath=$(realpath "$ln_src")

  if [ -e "$ln_dest" ]; then
    echo "File exists at $ln_dest. Skipping..."
  else
    if [ $DRYRUN -eq 1 ]; then
      echo "Would create softlink for $ln_src_realpath at $ln_dest"
    else
      ln -s "$ln_src_realpath" "$ln_dest"
      echo "Created softlink for $ln_src_realpath at $ln_dest"
    fi
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

setup_neovim_macos() {
  echo "\n-INFO- Setting up Neovim for MacOS"
  local archive_name="nvim-macos-arm64.tar.gz"
  local extracted_dir="$DOWNLOAD_DIR/nvim-macos-arm64"

  if [ $DRYRUN -eq 1 ]; then
    echo "-INFO- Would setup Neovim for MacOS"
    return
  fi

  # if archive_name doesn't exist; return
  if [ ! -e "$DOWNLOAD_DIR/$archive_name" ]; then
    echo "-ERROR- $archive_name not found in $DOWNLOAD_DIR"
    return 1
  fi

  # Run xattr to clear "unknown developer" warning
  echo "-INFO- Clearing extended attributes for $archive_name"
  xattr -c "$DOWNLOAD_DIR/$archive_name"

  # Extract the archive
  echo "-INFO- Extracting $archive_name"
  tar -xzvf "$DOWNLOAD_DIR/$archive_name" -C "$DOWNLOAD_DIR"

  # Verify the extracted binary exists
  if [ ! -e "$extracted_dir/bin/nvim" ]; then
    echo "-ERROR- Extraction failed or binary missing in $extracted_dir"
    return 1
  fi

  # Add extracted Neovim binary to PATH
  add_to_path "nvim" "$extracted_dir/bin"
}

# Platform-specific functions
run_osx() {
  echo "\n-INFO- MacOS-specific setup"

  local nvim_archive="nvim-macos-arm64.tar.gz"
  download_file $nvim_archive "https://github.com/neovim/neovim/releases/download/v0.10.3/nvim-macos-arm64.tar.gz"
  # setup_neovim_macos $nvim_archive

  # check if brew is installed
  if ! command -v brew &> /dev/null; then
    echo "-ERROR- Homebrew is not installed. Please install Homebrew first."
    exit 1
  else
    echo "-INFO- Homebrew is installed"
  fi

  brew_cmd="brew install fd tmux"
  if [ $DRYRUN -eq 1 ]; then
    echo "-INFO- Would run: $brew_cmd"
    return
  else
    echo "-INFO- Running: $brew_cmd"
    $brew_cmd
  fi
}

run_ub() {
  echo "\n-INFO- Ubuntu-specific setup"

  download_file "nvim" "https://github.com/neovim/neovim/releases/download/v0.10.3/nvim.appimage"
  add_to_path "nvim"

  apt_cmd="sudo apt install -y fd-find tmux"
  if [ $DRYRUN -eq 1 ]; then
    echo "-INFO- Would run: $apt_cmd"
    return
  else
    echo "-INFO- Running: $apt_cmd"
    $apt_cmd
  fi
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

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dryrun)
      DRYRUN=1
      shift
      ;;
    setup)
      setup_dotfiles
      setup_tmux_conf
      run_platformwise
      exit 0
      ;;
    *)
      usage $0
      exit 0
      ;;
  esac
done