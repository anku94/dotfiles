#!/usr/bin/env bash

set -eu

SCRIPT_DIR=$(realpath "$(dirname "$0")")
source "$SCRIPT_DIR/setupsrc/common.sh"
source "$SCRIPT_DIR/setupsrc/ubuntu.sh"
source "$SCRIPT_DIR/setupsrc/macos.sh"

# --- Init ---

check_requirements
detect_platform
detect_sudo
determine_preferred_shell
mkdir -p "$DOWNLOAD_DIR"

message "dotfiles root: $REPO_ROOT"
message "Platform: $PLATFORM"
[[ $DRYRUN -eq 1 ]] && message "Running in dry-run mode"

# --- Task profiles ---

TASKS_MINE=(neovim nvim_dotfiles lazygit ripgrep fd tmux efm_dotfiles prezto gitconfig claude)
TASKS_GUEST=(ripgrep fd tmux)

# --- Usage ---

usage() {
  message "Usage: $0 [options] <--mine|--guest>"
  message "Options:"
  message "  --dryrun    Show what would be done without making changes"
  message "Profiles:"
  message "  --mine      Full setup"
  message "  --guest     Minimal setup (ripgrep, fd, tmux)"
  exit 1
}

# --- Parse args ---

if [ $# -eq 0 ]; then
  usage
fi

while [[ $# -gt 0 ]]; do
  case $1 in
  --dryrun)
    DRYRUN=1
    shift
    ;;
  --mine)
    run_all_tasks "${TASKS_MINE[@]}"
    write_aliases
    exit 0
    ;;
  --guest)
    run_all_tasks "${TASKS_GUEST[@]}"
    write_aliases
    exit 0
    ;;
  *)
    usage
    ;;
  esac
done
