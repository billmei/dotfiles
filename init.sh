#!/bin/bash
# Initialization for development on MacOS
# Python 3, Ruby, and ES6.

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export HOMEBREW_NO_ANALYTICS=1
brew analytics off

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# ZSH!
brew install zsh zsh-completions
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s /bin/zsh

# Security
# Apple's default openssl is outdated
brew install openssl

# Cask files
# export HOMEBREW_CASK_OPTS="--appdir=/Applications"
# brew install --cask brave-browser
# brew install --cask iterm2
# brew install --cask rectangle
# brew install --cask vlc
# brew install --cask the-unarchiver
# brew install --cask firefox

brew install ffmpeg

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils

# Other useful Homebrew stuff
brew install git-delta
brew install tree
# brew install yt-dlp
brew install terminal-notifier
brew install asciinema # https://asciinema.org/
brew install tldr # better manpages

# Symlink stuff
dotfiles_repo=`pwd`
ln -s "${dotfiles_repo}/.aliases"      "${HOME}/.aliases"
ln -s "${dotfiles_repo}/.bash_profile" "${HOME}/.bash_profile"
ln -s "${dotfiles_repo}/.bash_prompt"  "${HOME}/.bash_prompt"
ln -s "${dotfiles_repo}/.bashrc"       "${HOME}/.bashrc"
ln -s "${dotfiles_repo}/.curlrc"       "${HOME}/.curlrc"
ln -s "${dotfiles_repo}/.completions"  "${HOME}/.completions"
ln -s "${dotfiles_repo}/.extra"        "${HOME}/.extra"
ln -s "${dotfiles_repo}/.exports"      "${HOME}/.exports"
ln -s "${dotfiles_repo}/.functions"    "${HOME}/.functions"
ln -s "${dotfiles_repo}/.gitconfig"    "${HOME}/.gitconfig"
ln -s "${dotfiles_repo}/.gitignore"    "${HOME}/.gitignore"
ln -s "${dotfiles_repo}/.inputrc"      "${HOME}/.inputrc"
ln -s "${dotfiles_repo}/.irbrc"        "${HOME}/.irbrc"
ln -s "${dotfiles_repo}/.macos"        "${HOME}/.macos"
ln -s "${dotfiles_repo}/.path"         "${HOME}/.path"
ln -s "${dotfiles_repo}/.pryrc"        "${HOME}/.pryrc"
ln -s "${dotfiles_repo}/.screenrc"     "${HOME}/.screenrc"
ln -s "${dotfiles_repo}/.vimrc"        "${HOME}/.vimrc"
ln -s "${dotfiles_repo}/.wgetrc"       "${HOME}/.wgetrc"
rm "${HOME}/.zshrc"
ln -s "${dotfiles_repo}/.zshrc"        "${HOME}/.zshrc"

# Symlink Linting config
ln -s "${dotfiles_repo}/config/ruby/rubocop/default.yml" default.yml
ln -s "${dotfiles_repo}/config/ruby/rubocop/enabled.yml" enabled.yml
ln -s "${dotfiles_repo}/config/ruby/rubocop/disabled.yml" disabled.yml

# Remove existing ys.zsh-theme and replace it with the custom one
rm "${HOME}/.oh-my-zsh/themes/ys.zsh-theme"
ln -s "${dotfiles_repo}/terminal/ys.zsh-theme" "${HOME}/.oh-my-zsh/themes/ys.zsh-theme"

# Symlink VSCode config
ln -s "${dotfiles_repo}/vscode/keybindings.json" "${HOME}/Library/Application Support/Code/User/keybindings.json"
# Workaround from Chromium bug
# https://github.com/electron/electron/issues/2617#issuecomment-571447707
mkdir "${HOME}/Library/Keybindings"
ln -s "${dotfiles_repo}/macos/DefaultKeyBinding.dict" "${HOME}/Library/KeyBindings/DefaultKeyBinding.dict"
