#!/usr/bin/env bash

# --- Neovim ---

neovim_install_macos() {
  local tag
  tag=$(gh_latest_tag "neovim/neovim")
  message "Latest Neovim release: $tag"

  local url="https://github.com/neovim/neovim/releases/download/${tag}/nvim-macos-arm64.tar.gz"
  local nvim_archive_path="$DOWNLOAD_DIR/nvim-macos-arm64-${tag}.tar.gz"
  local extracted_dir="${nvim_archive_path%.tar.gz}"

  download_file "$url" "$nvim_archive_path"

  # Clear macOS "unknown developer" warning
  xattr -c "$nvim_archive_path"

  # Extract
  mkdir -p "$extracted_dir"
  tar -xzf "$nvim_archive_path" -C "$extracted_dir" --strip-components=1

  if [ ! -e "$extracted_dir/bin/nvim" ]; then
    message "Extraction failed or binary missing in $extracted_dir"
    return 1
  fi

  add_to_path "nvim" "$extracted_dir/bin"
  add_alias "nv" "$extracted_dir/bin/nvim"
}

# --- Lazygit ---

lazygit_install_macos() {
  run_cmd "brew install lazygit" "Installing lazygit"
}

# --- fd ---

fd_install_macos() {
  run_cmd "brew install fd" "Installing fd"
}

# --- Ripgrep ---

ripgrep_install_macos() {
  run_cmd "brew install ripgrep" "Installing ripgrep"
}
