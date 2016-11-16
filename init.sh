#!/bin/bash
# Initialization for development on MacOS
# Python 3, Ruby, and ES6.

# Applications that have to be installed manually
# Little Snitch https://www.obdev.at/products/littlesnitch/index.html
# Giphy Capture https://itunes.apple.com/us/app/giphy-capture.-the-gif-maker/id668208984?mt=12

# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
git config --file="$(brew --repository)/.git/config" --replace-all homebrew.analyticsdisabled true

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils

# Science Rules
brew tap homebrew/science
brew install wget --with-iri
brew install go
brew install ant
brew install ffmpeg
brew install eigen
brew install opencv
brew install youtube-dl
brew install gpg
brew install terminal-notifier
brew install shellcheck
brew install wifi-password

# Cask files
brew tap phinze/cask
brew install brew-cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
brew cask install google-chrome
brew cask install xtrafinder
brew cask install smoothmouse
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
brew cask install anki
brew cask install gpgtools
brew cask install flash
brew cask install radiant-player
brew cask install unetbootin
brew tap trinitronx/homebrew-truecrypt
brew cask install truecrypt
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

# NPM
brew install node
npm install -g gitjk
npm install -g npmlog
npm install -g semver
npm install -g rimraf
npm install -g fsevents
npm install -g git-fire # 🔥

# Python
brew install python3
pip install awscli
## ML stuff
pip3 install pandas
pip3 install bs4
pip3 install sklearn
pip3 install numpy
pip3 install scipy
pip3 install requests && pip install requests
pip3 install tensorflow
pip3 install lxml
pip3 install nltk
pip3 install jupyter
## Web dev stuff
pip3 install flask
pip3 install django
pip3 install pylint && pip install pylint
