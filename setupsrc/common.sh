#!/usr/bin/env bash

set -eu

# --- Shared variables ---

REPO_ROOT=$(git rev-parse --show-toplevel)
DOWNLOAD_DIR="$REPO_ROOT/bin"
DRYRUN=0
HAS_SUDO=0
PLATFORM=""

# --- Platform detection ---

detect_platform() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v lsb_release &>/dev/null && lsb_release -i | grep -qi ubuntu; then
      PLATFORM="ubuntu"
    else
      PLATFORM="linux"
    fi
  else
    PLATFORM="unknown"
  fi
  message "Platform: $PLATFORM"
}

# --- Sudo detection ---

detect_sudo() {
  if sudo -n true 2>/dev/null; then
    HAS_SUDO=1
  else
    message "No sudo access detected. Commands requiring sudo will be skipped."
  fi
}

# --- Shell detection ---

determine_preferred_shell() {
  if command -v zsh &>/dev/null; then
    PREFERRED_SHELL="zsh"
    SHELL_CONFIG="$HOME/.zshrc"
  else
    PREFERRED_SHELL="bash"
    SHELL_CONFIG="$HOME/.bashrc"
  fi
  message "Shell: $PREFERRED_SHELL"
}

# --- Requirement checks ---

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

# --- GitHub helpers ---

# Get the latest release tag for a GitHub repo
# Usage: gh_latest_tag "neovim/neovim"  =>  "v0.10.4"
gh_latest_tag() {
  local repo=$1
  curl -sI "https://github.com/$repo/releases/latest" \
    | grep -i '^location:' \
    | grep -oE '[^/]+$' \
    | tr -d '\r'
}

# --- Logging ---

message() {
  echo -e "-INFO- $1"
}

# --- Command runners ---

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

run_sudo_cmd() {
  local cmd="$1"
  local description="${2:-Running sudo command}"

  if [ $HAS_SUDO -eq 0 ]; then
    message "Skipping (no sudo): $description"
    return 0
  fi

  run_cmd "$cmd" "$description"
}

# --- Download + integrity ---

download_file() {
  local url=$1
  local dest=$2
  local sha256=${3:-""}
  local name=$(basename "$url")

  if [ $DRYRUN -eq 1 ]; then
    message "Would download $name from $url"
    return
  fi

  if [ -e "$dest" ]; then
    message "$name already exists in $(dirname "$dest")"
    if [ -n "$sha256" ]; then
      assert_integrity "$dest" "$sha256"
      message "Integrity check passed."
    fi
    message "Skipping download."
    return
  fi

  message "Downloading $name from $url"

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
  fi
}

# --- Path + symlink helpers ---

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

  if ! file "$binary_path" | grep -q "executable"; then
    message "$binary is not a valid executable. Skipping."
    rm -f "$binary_path"
    return
  fi

  if ! grep -q "$binary_dir" "$SHELL_CONFIG"; then
    message "Adding $binary_dir to PATH in $SHELL_CONFIG"
    echo "export PATH=\"$binary_dir:\$PATH\"" >>"$SHELL_CONFIG"
  fi
}

create_softlink() {
  local ln_src=$1
  local ln_dest=$2
  local dest_dir=$(dirname "$ln_dest")
  local ln_src_realpath=$(realpath "$ln_src")

  if [ -e "$ln_dest" ]; then
    message "File exists at $ln_dest. Skipping..."
  elif [ $DRYRUN -eq 1 ]; then
    message "Would create softlink for $ln_src_realpath at $ln_dest"
  else
    mkdir -p "$dest_dir"
    ln -s "$ln_src_realpath" "$ln_dest"
    message "Created softlink for $ln_src_realpath at $ln_dest"
  fi
}

# --- Alias management ---

declare -a ALIASES=()

add_alias() {
  local alias_name="$1"
  local alias_command="$2"

  ALIASES+=("alias $alias_name='$alias_command'")

  if [ $DRYRUN -eq 1 ]; then
    message "Would add alias: $alias_name='$alias_command'"
  else
    message "Added alias: $alias_name='$alias_command'"
  fi
}

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

  if grep -q "$start_marker" "$SHELL_CONFIG"; then
    message "Removing existing aliases section"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "/$start_marker/,/$end_marker/d" "$SHELL_CONFIG"
    else
      sed -i "/$start_marker/,/$end_marker/d" "$SHELL_CONFIG"
    fi
  fi

  message "Writing ${#ALIASES[@]} aliases to $SHELL_CONFIG"

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

# --- Tasks: tmux ---

tmux_install() {
  # Install tmux binary if not present
  if ! command -v tmux &>/dev/null; then
    if [ "$PLATFORM" = "ubuntu" ]; then
      run_sudo_cmd "sudo apt install -y tmux" "Installing tmux"
    elif [ "$PLATFORM" = "macos" ]; then
      run_cmd "brew install tmux" "Installing tmux"
    fi
  else
    message "tmux already installed."
  fi

  # Install tmux.conf
  local src="$REPO_ROOT/tmux.conf"
  local dest="$HOME/.tmux.conf"
  local tmp_conf="/tmp/tmux.conf.tmp"

  if [ ! -e "$src" ]; then
    message "tmux.conf not found in repo. Skipping config."
    return
  fi

  cp "$src" "$tmp_conf"

  # Replace shell path if zsh is not available
  if [[ "$PREFERRED_SHELL" != "zsh" ]]; then
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
      message "Backed up existing tmux.conf"
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

  cp "$tmp_conf" "$dest"
  rm -f "$tmp_conf"
  message "Installed tmux.conf to $dest"
}

# --- Tasks: efm_dotfiles ---

efm_dotfiles_install() {
  local src="$REPO_ROOT/style/efm-langserver.yaml"
  local dest="$HOME/.config/efm-langserver/config.yaml"

  if [ ! -e "$src" ]; then
    message "efm-langserver.yaml not found in repo. Skipping."
    return
  fi

  create_softlink "$src" "$dest"
}

# --- Tasks: prezto ---

prezto_install() {
  if [ "$PREFERRED_SHELL" != "zsh" ]; then
    message "Prezto requires zsh. Skipping."
    return
  fi

  if [ -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
    message "Prezto already installed."
    return
  fi

  run_cmd "git clone --recursive https://github.com/sorin-ionescu/prezto.git \"${ZDOTDIR:-$HOME}/.zprezto\"" "Cloning Prezto repository"

  local tmp_script="/tmp/setup_prezto_links.zsh"
  cat >"$tmp_script" <<'EOF'
#!/usr/bin/env zsh
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  dest="${ZDOTDIR:-$HOME}/.${rcfile:t}"
  if [ ! -e "$dest" ]; then
    echo "Creating symlink for ${rcfile:t}"
    ln -s "$rcfile" "$dest"
  elif [ "${rcfile:t}" = "zshrc" ]; then
    echo "Prepending Prezto init to existing .zshrc"
    tmp="$(mktemp)"
    cat "$rcfile" "$dest" > "$tmp"
    mv "$tmp" "$dest"
  else
    echo "File $dest already exists, skipping"
  fi
done
EOF

  chmod +x "$tmp_script"
  message "Creating symlinks for Prezto configuration files"
  zsh "$tmp_script"
  rm -f "$tmp_script"

  # Configure prezto modules — replace the default pmodule block
  local zpreztorc="${ZDOTDIR:-$HOME}/.zpreztorc"
  message "Configuring prezto modules in $zpreztorc"

  local tmp="$(mktemp)"
  local replacement="$(mktemp)"
  cat >"$replacement" <<'PMOD'
zstyle ':prezto:load' pmodule \
  'autosuggestions' \
  'command-not-found' \
  'environment' \
  'history-substring-search' \
  'terminal' \
  'editor' \
  'git' \
  'history' \
  'directory' \
  'spectrum' \
  'utility' \
  'completion' \
  'prompt'
PMOD

  awk -v rfile="$replacement" '
    /^zstyle .*:prezto:load.*pmodule/ {
      while ((getline r < rfile) > 0) print r
      # Skip old continuation lines
      while (/\\$/ && (getline > 0)) {}
      next
    }
    { print }
  ' "$zpreztorc" > "$tmp"
  mv "$tmp" "$zpreztorc"
  rm -f "$replacement"

  message "Prezto setup complete. Restart your shell or run 'source ~/.zshrc' to apply."
}

# --- Tasks: gitconfig ---

gitconfig_install() {
  if git config --global user.name &>/dev/null && git config --global user.email &>/dev/null; then
    message "Git already configured: $(git config --global user.name) <$(git config --global user.email)>"
    return
  fi

  read -r -p "Enter your full name for git: " git_name
  read -r -p "Enter your gmail username (before @gmail.com): " gmail_user

  git config --global user.name "$git_name"
  git config --global user.email "${gmail_user}@gmail.com"
  message "Git configured: $git_name <${gmail_user}@gmail.com>"
}

# --- Tasks: claude ---

claude_install() {
  if command -v claude &>/dev/null; then
    message "Claude already installed. Skipping."
    return
  fi

  run_cmd "curl -fsSL https://claude.ai/install.sh | bash" "Installing Claude Code"
}

# --- Tasks: nvim_dotfiles ---

nvim_dotfiles_install() {
  local files=("nvim/init.lua" "nvim/lua" "nvim/patches")
  local dest_dir="$HOME/.config/nvim"

  for file in "${files[@]}"; do
    local dest="$dest_dir/$(basename "$file")"
    if [ ! -e "$REPO_ROOT/$file" ]; then
      message "$file does not exist in repo. Skipping."
      continue
    fi
    create_softlink "$REPO_ROOT/$file" "$dest"
  done
}

# --- Task runner ---

run_task() {
  local task=$1
  local install_fn="${task}_install_${PLATFORM}"
  local generic_fn="${task}_install"
  local rollback_fn="${task}_rollback"

  # Resolve which install function to call
  local fn=""
  if declare -f "$install_fn" &>/dev/null; then
    fn="$install_fn"
  elif declare -f "$generic_fn" &>/dev/null; then
    fn="$generic_fn"
  else
    message "Task '$task': no install function found. Skipping."
    return 0
  fi

  message "--- Running task: $task ($fn) ---"

  # Run install, catch failure for rollback
  if ! $fn; then
    message "Task '$task' failed."
    if declare -f "$rollback_fn" &>/dev/null; then
      message "Running rollback for '$task'..."
      $rollback_fn || message "Rollback for '$task' also failed."
    fi
    return 1
  fi
}

run_all_tasks() {
  local tasks=("$@")
  local failed=()

  for task in "${tasks[@]}"; do
    run_task "$task" || failed+=("$task")
  done

  if [ ${#failed[@]} -gt 0 ]; then
    message "Failed tasks: ${failed[*]}"
  else
    message "All tasks completed successfully."
  fi
}
