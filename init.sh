#!/bin/bash
# Initialization for development on MacOS
# Python 3, Ruby, and ES6.

# Applications that have to be installed manually
# Little Snitch https://www.obdev.at/products/littlesnitch/index.html

# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
git config --file="$(brew --repository)/.git/config" --replace-all homebrew.analyticsdisabled true
touch ~/.SideBarEnhancements.optout

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# ZSH!
brew install zsh zsh-completions
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
chsh -s /bin/zsh

# Security
# Apple's default openssl is outdated
brew install openssl

# Cask files
brew tap caskroom/cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
brew cask install google-chrome
brew cask install sublime-text
brew cask install iterm2
brew cask install totalfinder
brew tap trinitronx/homebrew-truecrypt
brew cask install truecrypt
brew cask install spectacle
brew cask install flux
brew cask install dropbox
brew cask install vlc
brew cask install postgres
brew cask install ccleaner
brew cask install dash
brew cask install the-unarchiver
brew cask install firefox
brew cask install skype
brew cask install anki
brew cask install calibre
brew cask install flash-player
brew cask install kap
brew cask install unetbootin
brew cask install transmission
brew cask install gpgtools
brew cask install torbrowser
brew cask install viscosity
# brew cask install virtualbox

# Science Rules
brew tap homebrew/science
brew install wget --with-iri
brew install go
brew install ant
brew install ffmpeg
brew install libav
brew install eigen
brew install opencv
brew install gpg

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils

# Other useful Homebrew stuff
brew install diff-so-fancy
brew install tree
brew install heroku
brew install youtube-dl
brew install terminal-notifier
brew install shellcheck
brew install wifi-password
brew install rename

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
npm install -g eslint

# Python
brew install python3
pip3 install --upgrade pip
pip3 install awscli
## Web dev stuff
pip3 install flask
pip3 install django
pip3 install pylint
## ML stuff
pip3 install pandas
pip3 install bs4
pip3 install sklearn
pip3 install numpy
pip3 install scipy
pip3 install requests
pip3 install tensorflow
pip3 install lxml
pip3 install nltk
pip3 install jupyter

# Symlink stuff
dotfiles_repo=`pwd`
ln -s "${dotfiles_repo}/.aliases"      "${HOME}/.aliases"
ln -s "${dotfiles_repo}/.bash_profile" "${HOME}/.bash_profile"
ln -s "${dotfiles_repo}/.bash_prompt"  "${HOME}/.bash_prompt"
ln -s "${dotfiles_repo}/.bashrc"       "${HOME}/.bashrc"
ln -s "${dotfiles_repo}/.curlrc"       "${HOME}/.curlrc"
ln -s "${dotfiles_repo}/.exports"      "${HOME}/.exports"
ln -s "${dotfiles_repo}/.functions"    "${HOME}/.functions"
ln -s "${dotfiles_repo}/.gitconfig"    "${HOME}/.gitconfig"
ln -s "${dotfiles_repo}/.gitignore"    "${HOME}/.gitignore"
ln -s "${dotfiles_repo}/.inputrc"      "${HOME}/.inputrc"
ln -s "${dotfiles_repo}/.macos"        "${HOME}/.macos"
ln -s "${dotfiles_repo}/.pryrc"        "${HOME}/.pryrc"
ln -s "${dotfiles_repo}/.screenrc"     "${HOME}/.screenrc"
ln -s "${dotfiles_repo}/.vimrc"        "${HOME}/.vimrc"
ln -s "${dotfiles_repo}/.wgetrc"       "${HOME}/.wgetrc"
ln -s "${dotfiles_repo}/.zshrc"        "${HOME}/.zshrc"

# Remove existing ys.zsh-theme and replace it with the custom one
rm "${HOME}/.oh-my-zsh/themes/ys.zsh-theme"
ln -s "${dotfiles_repo}/terminal/ys.zsh-theme" "${HOME}/.oh-my-zsh/themes/ys.zsh-theme"

# Symlink Sublime Text settings
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/CoffeeScript.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Default (OSX).sublime-keymap"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/EJS.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/HTML.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/JavaScript (Babel).sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/JavaScript.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Python.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Ruby Haml.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Ruby.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Sass.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/SublimeLinter.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/SublimeLinter/Monokai (SL).tmTheme"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/YAML.sublime-settings"

ln -s "${dotfiles_repo}/sublime/CoffeeScript.sublime-settings"       "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/CoffeeScript.sublime-settings"
ln -s "${dotfiles_repo}/sublime/EJS.sublime-settings"                "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/EJS.sublime-settings"
ln -s "${dotfiles_repo}/sublime/HTML.sublime-settings"               "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/HTML.sublime-settings"
ln -s "${dotfiles_repo}/sublime/JavaScript (Babel).sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/JavaScript (Babel).sublime-settings"
ln -s "${dotfiles_repo}/sublime/JavaScript.sublime-settings"         "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/JavaScript.sublime-settings"
ln -s "${dotfiles_repo}/sublime/Python.sublime-settings"             "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Python.sublime-settings"
ln -s "${dotfiles_repo}/sublime/Ruby Haml.sublime-settings"          "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Ruby Haml.sublime-settings"
ln -s "${dotfiles_repo}/sublime/Ruby.sublime-settings"               "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Ruby.sublime-settings"
ln -s "${dotfiles_repo}/sublime/Sass.sublime-settings"               "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Sass.sublime-settings"
ln -s "${dotfiles_repo}/sublime/SublimeLinter.sublime-settings"      "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/SublimeLinter.sublime-settings"
ln -s "${dotfiles_repo}/sublime/SublimeLinter/Monokai (SL).tmTheme"  "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/SublimeLinter/Monokai (SL).tmTheme"
ln -s "${dotfiles_repo}/sublime/YAML.sublime-settings"               "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/YAML.sublime-settings"           

 # These settings can't be symlinked
cp "${dotfiles_repo}/sublime/Preferences.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Preferences.sublime-settings"
cp "${dotfiles_repo}/sublime/Default (OSX).sublime-keymap" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Default (OSX).sublime-keymap"
