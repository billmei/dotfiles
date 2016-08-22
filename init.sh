#!/bin/bash
# Initialization for development on MacOS
# Python 3, Ruby, and ES6.

# Applications that have to be installed manually
# Little Snitch https://www.obdev.at/products/littlesnitch/index.html
# Giphy Capture https://itunes.apple.com/us/app/giphy-capture.-the-gif-maker/id668208984?mt=12

# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
git config --file="$(brew --repository)/.git/config" --replace-all homebrew.analyticsdisabled true
brew tap homebrew/science
brew install wget
brew install go
brew install ant
brew install ffmpeg
brew install eigen
brew install opencv
brew install youtube-dl
brew install gpg

# Cask files
brew tap phinze/cask
brew install brew-cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
brew cask install google-chrome
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

# Custom settings
## Disable two-finger swipe back/forward navigation in Chrome
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool FALSE

## Speed up the green maximize window resize animation
defaults write -g NSWindowResizeTime -float 0.001

## Set the clock to 24h time
defaults write -g AppleICUForce24HourTime -bool TRUE

## Remove dock auto-hide animation delay
defaults write com.apple.Dock autohide-delay -float 0

## Make mission control animation super fast
defaults write com.apple.dock expose-animation-duration -float 0.1

## Make hidden apps translucent in the Dock
defaults write com.apple.Dock showhidden -bool YES

# From https://github.com/mathiasbynens/dotfiles/blob/master/.osx

## Disable transparency in the menu bar and elsewhere on Yosemite
defaults write com.apple.universalaccess reduceTransparency -bool true

## Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

## Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

## Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

## Disable the sudden motion sensor as it’s not useful for SSDs
sudo pmset -a sms 0

## Trackpad: map bottom right corner to right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

## Disable “natural” (Lion-style) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

## Set language and text formats
## Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
## `Inches`, `en_GB` with `en_US`, and `true` with `false`.
defaults write NSGlobalDomain AppleLanguages -array "en" "ru" "es"
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

## Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

## Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

## Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

## Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

## Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

## Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

## Always show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool YES

## Always show the ~/Library folder
chflags nohidden ~/Library

## Always show the /Volumes folder
sudo chflags nohidden /Volumes

## Save all screenshots to ~/Pictures/Screenshots instead of the Desktop
defaults write com.apple.screencapture location ~/Pictures/Screenshots

## Refresh Dock and Finder to apply the above settings
killall Dock
killall Finder
