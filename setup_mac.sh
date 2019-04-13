# Some custom MacVim?
alias vim='mvim -v'
alias vi='mvim -v'

# Macvim works better than default vim?
brew install macvim

# Prettify C/C++
brew install clang-format

# Fast code search using Ag
brew install the_silver_searcher

# Custom find tool, that ignores .gitignore
# And has other useful defaults, helpful with FZF
brew install fd

# Fuzzy search from command line and Vim
brew install fzf

echo "export FZF_DEFAULT_COMMAND='fd --type file'" >> ~/.zshrc
echo "export FZF_CTRL_T_COMMAND=\"$FZF_DEFAULT_COMMAND\"" >> ~/.zshrc
