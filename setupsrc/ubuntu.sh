#!/usr/bin/env bash

# --- Neovim ---

neovim_install_ubuntu() {
  local tag
  tag=$(gh_latest_tag "neovim/neovim")
  message "Latest Neovim release: $tag"

  local url="https://github.com/neovim/neovim/releases/download/${tag}/nvim-linux-x86_64.appimage"
  local nvim_dest="$DOWNLOAD_DIR/nvim.appimage"

  download_file "$url" "$nvim_dest"
  chmod +x "$nvim_dest"
  add_to_path "nvim.appimage"
  add_alias "nv" "$DOWNLOAD_DIR/nvim.appimage"
}

# --- Lazygit ---

lazygit_install_ubuntu() {
  local tag
  tag=$(gh_latest_tag "jesseduffield/lazygit")
  local version="${tag#v}"
  message "Latest Lazygit release: $tag"

  local url="https://github.com/jesseduffield/lazygit/releases/download/${tag}/lazygit_${version}_Linux_x86_64.tar.gz"
  local archive_path="$DOWNLOAD_DIR/lazygit_${version}.tar.gz"

  download_file "$url" "$archive_path"
  tar -xzf "$archive_path" -C "$DOWNLOAD_DIR" lazygit
  chmod +x "$DOWNLOAD_DIR/lazygit"
  add_to_path "lazygit"
}

# --- fd ---

fd_install_ubuntu() {
  local tag
  tag=$(gh_latest_tag "sharkdp/fd")
  local version="${tag#v}"
  message "Latest fd release: $tag"

  local url="https://github.com/sharkdp/fd/releases/download/${tag}/fd-${tag}-x86_64-unknown-linux-musl.tar.gz"
  local archive_path="$DOWNLOAD_DIR/fd-${tag}.tar.gz"

  download_file "$url" "$archive_path"
  tar -xzf "$archive_path" -C "$DOWNLOAD_DIR" --strip-components=1 "fd-${tag}-x86_64-unknown-linux-musl/fd"
  chmod +x "$DOWNLOAD_DIR/fd"
  add_to_path "fd"
}

# --- Ripgrep ---

ripgrep_install_ubuntu() {
  local tag
  tag=$(gh_latest_tag "BurntSushi/ripgrep")
  local version="${tag}"
  message "Latest ripgrep release: $tag"

  local url="https://github.com/BurntSushi/ripgrep/releases/download/${tag}/ripgrep-${version}-x86_64-unknown-linux-musl.tar.gz"
  local archive_path="$DOWNLOAD_DIR/ripgrep-${version}.tar.gz"

  download_file "$url" "$archive_path"
  tar -xzf "$archive_path" -C "$DOWNLOAD_DIR" --strip-components=1 "ripgrep-${version}-x86_64-unknown-linux-musl/rg"
  chmod +x "$DOWNLOAD_DIR/rg"
  add_to_path "rg"
}
