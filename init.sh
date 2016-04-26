#!/bin/bash
# Initialization for development on MacOS

# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
git config --file="$(brew --repository)/.git/config" --replace-all homebrew.analyticsdisabled true
brew tap homebrew/science
brew install wget
brew install go
brew install node
brew install ant
brew install ffmpeg
brew install eigen
brew install opencv
brew install youtube-dl
brew install gpg
npm install -g gitjk

# Cask files
brew tap phinze/cask
brew install brew-cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
brew cask install google-chrome
brew cask install vlc
brew cask install iterm2
brew cask install flux
brew cask install spectacle
brew cask install dropbox
brew cask install heroku-toolbelt
brew cask install sublime-text
brew cask install postgres
brew cask install ccleaner
brew cask install dash
brew cask install the-unarchiver
brew cask install firefox
brew cask install skype
brew cask install gpgtools
# brew cask install virtualbox

# Fonts
brew tap caskroom/fonts
brew cask install font-noto-sans
brew cask install font-vollkorn
brew cask install font-open-sans
brew cask install font-source-sans-pro
brew cask install font-computer-modern
brew cask install font-comic-neue
brew cask install font-montserrat
