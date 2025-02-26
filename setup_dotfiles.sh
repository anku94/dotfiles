#!/usr/bin/env bash

set -eu

# Define Neovim download URLs
NV_MACOS_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz"
NV_MACOS_SHA256="36caf80e02c775b6cc04b1467f6689043b73233a0f7e78fb91cacc2c80f3b64f"

NV_UBUNTU_URL="https://github.com/neovim/neovim/releases/download/v0.10.3/nvim.appimage"

# Define your dotfiles mapping here (bash syntax)
declare -A DOTFILES_MAP
DOTFILES_MAP=(
  ["nvim/init.lua"]="$HOME/.config/nvim/init.lua"
  ["nvim/lua"]="$HOME/.config/nvim/lua"
  ["nvim/patches"]="$HOME/.config/nvim/patches"
  ["style/efm-langserver.yaml"]="$HOME/.config/efm-langserver/config.yaml"
)

# Initialize DRYRUN flag
DRYRUN=0

REPO_ROOT=$(git rev-parse --show-toplevel)

message() {
  echo -e "-INFO- $1"
}

# Add near the top of your script
cleanup() {
  # Clean up temporary files, etc.
  message "Cleaning up..."
}

trap cleanup EXIT

# Add near the beginning of your script
check_requirements() {
  local missing_cmds=()

  for cmd in curl sha256sum file realpath; do
    if ! command -v $cmd &>/dev/null; then
      missing_cmds+=($cmd)
    fi
  done

  if [ ${#missing_cmds[@]} -gt 0 ]; then
    message "Missing required commands: ${missing_cmds[*]}"
    message "Please install them before continuing."
    exit 1
  fi
}

check_requirements

# Add this function to determine the preferred shell
determine_preferred_shell() {
  if command -v zsh &>/dev/null; then
    PREFERRED_SHELL="zsh"
    SHELL_CONFIG="$HOME/.zshrc"
  else
    PREFERRED_SHELL="bash"
    SHELL_CONFIG="$HOME/.bashrc"
  fi

  message "Using $PREFERRED_SHELL as preferred shell"
}

# Call this function early in the script
determine_preferred_shell

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
  local url=$1
  local dest=$2
  local sha256=${3:-""}

  local name=$(basename "$url")

  if [ $DRYRUN -eq 1 ]; then
    message "Would download $name from $url"
    return
  fi

  if [ -e "$dest" ] && [ -n "$sha256" ]; then
    message "$name already exists in $DOWNLOAD_DIR"
    message "Checking integrity"

    assert_integrity "$dest" "$sha256"

    message "Integrity check passed. Skipping download."
    return
  else
    message "Downloading $name from $url"
  fi

  if command -v curl &>/dev/null; then
    curl -L -o "$dest" "$url"
  elif command -v wget &>/dev/null; then
    wget -O "$dest" "$url"
  else
    message "Neither curl nor wget is available."
    exit 1
  fi

  if [ -n "$sha256" ]; then
    assert_integrity "$dest" "$sha256"
  fi
}

assert_integrity() {
  local file=$1
  local expected_sha256=$2
  local actual_sha256

  if command -v sha256sum &>/dev/null; then
    actual_sha256=$(sha256sum "$file" | awk '{print $1}')
  elif command -v shasum &>/dev/null; then
    actual_sha256=$(shasum -a 256 "$file" | awk '{print $1}')
  else
    message "No SHA256 verification tool found. Skipping integrity check."
    return
  fi

  message "SHA256 actual: ${actual_sha256:0:10}..., expected: ${expected_sha256:0:10}..."

  if [ "$actual_sha256" != "$expected_sha256" ]; then
    message "Integrity check failed for $file"
    message "Please delete the file and re-run the script"
    exit 1
  else
    message "Integrity check passed for $file"
  fi
}

add_to_path() {
  local binary=$1
  local binary_dir=${2:-"$DOWNLOAD_DIR"}

  local binary_path="$binary_dir/$binary"

  if [ $DRYRUN -eq 1 ]; then
    message "Would add $binary_dir to PATH"
    return
  fi

  if [ ! -e "$binary_path" ]; then
    message "Skipping PATH addition. $binary not found in $binary_dir."
    return
  fi

  # Validate that the file is a proper executable
  if ! file "$binary_path" | grep -q "executable"; then
    message "$binary is not a valid executable. Skipping."
    rm -f "$binary_path"
    return
  fi

  # Use the global SHELL_CONFIG variable instead of determining it each time
  # Add the binary directory to PATH if not already added
  if ! grep -q "$binary_dir" "$SHELL_CONFIG"; then
    message "Adding $binary_dir to PATH in $SHELL_CONFIG"
    echo "export PATH=\"$binary_dir:\$PATH\"" >>"$SHELL_CONFIG"
  fi
}

# Function to backup and copy tmux.conf
setup_tmux_conf() {
  local src="$REPO_ROOT/tmux.conf"
  local dest="$HOME/.tmux.conf"
  local tmp_conf="/tmp/tmux.conf.tmp"

  if [ $DRYRUN -eq 1 ]; then
    message "Would copy tmux.conf to $dest with shell set to $PREFERRED_SHELL"
    return
  fi

  # Create a temporary copy with the correct shell
  cp "$src" "$tmp_conf"

  # Replace the shell path in the tmux.conf
  if [[ "$PREFERRED_SHELL" == "zsh" ]]; then
    # If zsh is available, keep the zsh setting
    message "Using zsh in tmux configuration"
  else
    # If zsh is not available, use bash instead
    message "Replacing zsh with bash in tmux configuration"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' 's|set-option -g default-shell /usr/bin/zsh|set-option -g default-shell /bin/bash|g' "$tmp_conf"
    else
      sed -i 's|set-option -g default-shell /usr/bin/zsh|set-option -g default-shell /bin/bash|g' "$tmp_conf"
    fi
  fi

  if [ -e "$dest" ]; then
    message "tmux.conf already exists at $dest."
    message "Choose an action:"
    message "  [b] Backup the existing tmux.conf"
    message "  [o] Overwrite the existing tmux.conf"
    read -r -p "Enter your choice (b/o): " choice

    case "$choice" in
    b)
      mv "$dest" "${dest}.backup.$(date +%s)"
      message "Backed up existing tmux.conf to ${dest}.backup.$(date +%s)"
      ;;
    o)
      message "Overwriting the existing tmux.conf"
      ;;
    *)
      message "Invalid choice. Aborting tmux.conf setup."
      rm -f "$tmp_conf"
      return
      ;;
    esac
  fi

  # Copy the modified tmux.conf to the destination
  cp "$tmp_conf" "$dest"
  rm -f "$tmp_conf"
  message "Copied tmux.conf to $dest with shell set to $PREFERRED_SHELL"
}

create_softlink() {
  local ln_src=$1
  local ln_dest=$2
  local dest_dir=$(dirname "$ln_dest")

  ln_src_realpath=$(realpath "$ln_src")

  if [ -e "$ln_dest" ]; then
    message "File exists at $ln_dest. Skipping..."
  else
    if [ $DRYRUN -eq 1 ]; then
      message "Would create directory $dest_dir if needed"
      message "Would create softlink for $ln_src_realpath at $ln_dest"
    else
      mkdir -p "$dest_dir"
      ln -s "$ln_src_realpath" "$ln_dest"
      message "Created softlink for $ln_src_realpath at $ln_dest"
    fi
  fi
}

# Function to setup_dotfiles if a softlink exists at each destination
setup_dotfiles() {
  message "\nChecking for existing softlinks..."

  # Bash syntax for iterating over associative array keys
  for file in "${!DOTFILES_MAP[@]}"; do
    message "\n-INFO- Checking $file"
    # if file does not exist at source
    if [ ! -e "$file" ]; then
      message "   !!!! File does not exist at $file"
      continue
    fi

    destination="${DOTFILES_MAP[$file]}"
    if [ -L "$destination" ]; then
      message "   - Softlink exists at $destination"
    else
      message "   !!!! Softlink does not exist at $destination"
      create_softlink "$file" "$destination"
    fi
  done
}

get_nvim_version() {
  local nvurl=$1
  version=$(echo "$nvurl" | egrep -o "download/(.*)/nvim.*" | cut -d'/' -f2)
  echo $version
}

setup_neovim_macos() {
  message "\n-INFO- Setting up Neovim for MacOS"

  # download_dir/nvim-macos-arm64-<version>.tar.gz
  local archive_path=$1
  # download_dir/nvim-macos-arm64-<version>
  local extracted_dir=$(echo "$archive_path" | sed 's/\.tar\.gz//')

  # macos-arm64-<version>.tar.gz
  local archive_name=$(basename "$archive_path")

  if [ $DRYRUN -eq 1 ]; then
    message "-INFO- Would setup Neovim for MacOS"
    return
  fi

  # if archive_name doesn't exist; return
  if [ ! -e "$archive_path" ]; then
    message "-ERROR- $archive_name not found in $DOWNLOAD_DIR"
    return 1
  fi

  # Run xattr to clear "unknown developer" warning
  message "-INFO- Clearing extended attributes for $archive_name"
  xattr -c "$archive_path"

  # Extract the archive
  message "-INFO- Extracting $archive_name"
  # tar -xzvf "$DOWNLOAD_DIR/$archive_name" -C "$DOWNLOAD_DIR"
  mkdir -p "$extracted_dir"

  message "-INFO- [CMD] tar -xzf $archive_path -C $extracted_dir --strip-components=1"
  tar -xzf "$archive_path" -C "$extracted_dir" --strip-components=1

  # Verify the extracted binary exists
  if [ ! -e "$extracted_dir/bin/nvim" ]; then
    message "-ERROR- Extraction failed or binary missing in $extracted_dir"
    return 1
  fi

  # Add extracted Neovim binary to PATH
  add_to_path "nvim" "$extracted_dir/bin"
}

run_osx_navi() {
  message "\n-INFO- navi cheatsheet setup. TODO"
}

# Add this function near the top of your script
run_cmd() {
  local cmd="$1"
  local description="${2:-Running command}"

  if [ $DRYRUN -eq 1 ]; then
    message "Would run: $cmd"
    return 0
  else
    message "$description: $cmd"
    eval "$cmd"
    return $?
  fi
}

# Array to store aliases
declare -a ALIASES=()

# Function to add an alias
add_alias() {
  local alias_name="$1"
  local alias_command="$2"

  # Store the alias definition
  ALIASES+=("alias $alias_name='$alias_command'")

  if [ $DRYRUN -eq 1 ]; then
    message "Would add alias: $alias_name='$alias_command'"
  else
    message "Added alias: $alias_name='$alias_command'"
  fi
}

# Function to write all aliases to the shell config file
write_aliases() {
  if [ ${#ALIASES[@]} -eq 0 ]; then
    message "No aliases to write"
    return
  fi

  local start_marker="# BEGIN DOTFILES SCRIPT ALIASES"
  local end_marker="# END DOTFILES SCRIPT ALIASES"

  if [ $DRYRUN -eq 1 ]; then
    message "Would write ${#ALIASES[@]} aliases to $SHELL_CONFIG"
    return
  fi

  # Remove existing aliases section if it exists
  if grep -q "$start_marker" "$SHELL_CONFIG"; then
    message "Removing existing aliases section"
    # Platform-specific sed command
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "/$start_marker/,/$end_marker/d" "$SHELL_CONFIG"
    else
      sed -i "/$start_marker/,/$end_marker/d" "$SHELL_CONFIG"
    fi
  fi

  message "Writing ${#ALIASES[@]} aliases to $SHELL_CONFIG"

  # Append the new aliases section
  {
    echo ""
    echo "$start_marker"
    echo "# These aliases were automatically added by the dotfiles setup script"
    echo "# Last updated: $(date)"
    for alias_def in "${ALIASES[@]}"; do
      echo "$alias_def"
    done
    echo "$end_marker"
    echo ""
  } >>"$SHELL_CONFIG"
}

install_mac_utilities() {
  run_cmd "brew install fd tmux the_silver_searcher tree findutils" "Installing utilities"
  run_cmd "sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist" "Setting up locate database"

  # Add some useful aliases for Mac
  add_alias "ll" "ls -la"
  add_alias "fd" "fd -H"       # Include hidden files by default
  add_alias "ag" "ag --hidden" # Include hidden files by default
}

# Platform-specific functions
run_osx() {
  message "\n-INFO- MacOS-specific setup"

  # Neovim setup
  local nvim_version=$(get_nvim_version "$NV_MACOS_URL")
  local nvim_archive="nvim-macos-arm64-$nvim_version.tar.gz"
  local nvim_archive_path="$DOWNLOAD_DIR/$nvim_archive"

  message "-INFO- Will download neovim as $nvim_archive"
  download_file "$NV_MACOS_URL" "$nvim_archive_path" "$NV_MACOS_SHA256"
  setup_neovim_macos $nvim_archive_path

  # Check for Homebrew
  if ! command -v brew &>/dev/null; then
    message "-ERROR- Homebrew is not installed. Please install Homebrew first."
    exit 1
  else
    message "-INFO- Homebrew is installed"
  fi

  # Install utilities
  install_mac_utilities
}

# Add this function to ensure ~/.local/bin is in PATH
ensure_local_bin_in_path() {
  if [ $DRYRUN -eq 1 ]; then
    message "Would ensure ~/.local/bin is in PATH"
    return
  fi

  if ! grep -q "$HOME/.local/bin" "$SHELL_CONFIG"; then
    message "Adding ~/.local/bin to PATH in $SHELL_CONFIG"
    echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >>"$SHELL_CONFIG"
  fi
}

run_ub() {
  message "\n-INFO- Ubuntu-specific setup"

  # Create download directory if it doesn't exist
  mkdir -p "$DOWNLOAD_DIR"

  # Download and set up Neovim
  local nvim_archive="$DOWNLOAD_DIR/nvim.appimage"
  download_file "$NV_UBUNTU_URL" "$nvim_archive"

  if [ $DRYRUN -eq 0 ]; then
    # Make the AppImage executable
    run_cmd "chmod +x $nvim_archive" "Making Neovim AppImage executable"
  fi

  add_to_path "nvim.appimage"

  # Install utilities
  run_cmd "sudo apt update" "Updating package lists"
  run_cmd "sudo apt install -y fd-find tmux tree silversearcher-ag mlocate" "Installing utilities"

  # Set up locate database
  run_cmd "sudo updatedb" "Updating locate database"

  # Add Ubuntu-specific aliases
  add_alias "ll" "ls -la"
  add_alias "fd" "fdfind -H"   # Ubuntu uses fdfind instead of fd
  add_alias "ag" "ag --hidden" # Include hidden files by default

  # Create symlink for fd (Ubuntu uses fdfind)
  if [ $DRYRUN -eq 1 ]; then
    message "Would create symlink from fdfind to fd in ~/.local/bin"
  else
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
    message "Created symlink from fdfind to fd in ~/.local/bin"
  fi

  # Ensure ~/.local/bin is in PATH
  ensure_local_bin_in_path
}

# Function to check the platform and run the appropriate function
run_platformwise() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    run_osx
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v lsb_release &>/dev/null && lsb_release -i | grep -qi ubuntu; then
      run_ub
    else
      message "Unknown Linux distribution."
    fi
  else
    message "Unsupported platform."
  fi
}

# Function to set up Prezto for zsh
setup_prezto() {
  if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
    if [ "$PREFERRED_SHELL" != "zsh" ]; then
      message "Prezto requires zsh, but zsh is not available. Skipping Prezto setup."
      return 1
    fi

    message "Setting up Prezto for zsh"

    if [ $DRYRUN -eq 1 ]; then
      message "Would clone Prezto repository to ${ZDOTDIR:-$HOME}/.zprezto"
      message "Would create symlinks for Prezto configuration files"
      return 0
    fi

    # Clone the Prezto repository
    run_cmd "git clone --recursive https://github.com/sorin-ionescu/prezto.git \"${ZDOTDIR:-$HOME}/.zprezto\"" "Cloning Prezto repository"

    # Create a temporary zsh script to create the symlinks
    local tmp_script="/tmp/setup_prezto_links.zsh"
    cat >"$tmp_script" <<'EOF'
#!/usr/bin/env zsh
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  if [ ! -e "${ZDOTDIR:-$HOME}/.${rcfile:t}" ]; then
    echo "Creating symlink for ${rcfile:t}"
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
  else
    echo "File ${ZDOTDIR:-$HOME}/.${rcfile:t} already exists, skipping"
  fi
done
EOF

    # Make the script executable
    chmod +x "$tmp_script"

    # Run the script with zsh
    message "Creating symlinks for Prezto configuration files"
    zsh "$tmp_script"

    # Clean up
    rm -f "$tmp_script"

    message "Prezto setup complete. Please restart your shell or run 'source ~/.zshrc' to apply changes."
  else
    message "Prezto is already installed at ${ZDOTDIR:-$HOME}/.zprezto"
  fi
}

# first, cd to the directory containing this script
message "-INFO- Changing directory to $REPO_ROOT"
cd $REPO_ROOT

usage() {
  local script=$1
  message "Usage: $script [options] setup"
  message "Options:"
  message "  --dryrun       Show what would be done without making changes"
  message "  --with-prezto  Set up Prezto for zsh (if zsh is available)"
  exit 1
}

# Parse command line arguments
if [ $# -eq 0 ]; then
  usage $0
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case $1 in
  --dryrun)
    DRYRUN=1
    shift
    ;;
  --with-prezto)
    WITH_PREZTO=1
    shift
    ;;
  setup)
    setup_dotfiles
    setup_tmux_conf
    run_platformwise
    # Set up Prezto if requested
    if [ "${WITH_PREZTO:-0}" -eq 1 ]; then
      setup_prezto
    fi
    write_aliases
    exit 0
    ;;
  *)
    usage $0
    exit 1
    ;;
  esac
done
