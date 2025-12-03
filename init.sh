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
brew tap caskroom/cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
brew install --cask brave-browser
brew install --cask iterm2
brew install --cask rectangle
brew install --cask vlc
brew install --cask the-unarchiver
brew install --cask firefox

brew install ffmpeg

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils

# Other useful Homebrew stuff
brew install diff-so-fancy
brew install tree
# brew install git-extras
brew install yt-dlp
brew install terminal-notifier
brew install shellcheck
brew install wifi-password
brew install rename
brew install magic-wormhole
brew install asciinema # https://asciinema.org/
brew install tldr # better manpages

# Just for fun
brew install fortune
brew install cowsay

# Fonts
brew tap caskroom/fonts
brew cask install font-noto-sans
brew cask install font-vollkorn
brew cask install font-open-sans
brew cask install font-source-sans-pro
brew cask install font-computer-modern
brew cask install font-comic-neue
brew cask install font-montserrat

# Ruby
# Install RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable --ruby
gem install rubocop
gem install awesome_print

# NPM
# Install latest LTS
# brew install node
# npm install -g gitjk
# npm install -g npmlog
# npm install -g semver
# npm install -g rimraf
# npm install -g fsevents
# npm install -g git-fire # 🔥
# npm install -g eslint

# Python
brew install pyenv
# pip3 install --upgrade pip
# pip3 install coursera-dl
# ## Web dev stuff
# pip3 install flask
# pip3 install django
# pip3 install pylint
# ## ML stuff
# pip3 install pandas
# pip3 install bs4
# pip3 install sklearn
# pip3 install numpy
# pip3 install scipy
# pip3 install requests
# pip3 install tensorflow
# pip3 install lxml
# pip3 install nltk
# pip3 install jupyter

# SDKs
brew cask install google-cloud-sdk
brew cask install android-platform-tools
pip3 install awscli

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

# Symlink macOS system settings
ln -s "${dotfiles_repo}/macos/plist/com.${USER}.airportoff.plist" "${HOME}/Library/LaunchAgents/com.${USER}.airportoff.plist"
