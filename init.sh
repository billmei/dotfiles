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
brew cask install veracrypt
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
brew cask install sequel-pro
# brew cask install virtualbox

# Security stuff
# brew cask install youll-never-take-me-alive # Requires forced hibernation which is too inconvenient
brew cask install linkliar
# brew cask install little-snitch # Unfortunately, logs browsing history
brew cask install micro-snitch

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
pip3 install coursera-dl
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
ln -s "${dotfiles_repo}/.irbrc"        "${HOME}/.irbrc"
ln -s "${dotfiles_repo}/.macos"        "${HOME}/.macos"
ln -s "${dotfiles_repo}/.pryrc"        "${HOME}/.pryrc"
ln -s "${dotfiles_repo}/.screenrc"     "${HOME}/.screenrc"
ln -s "${dotfiles_repo}/.vimrc"        "${HOME}/.vimrc"
ln -s "${dotfiles_repo}/.wgetrc"       "${HOME}/.wgetrc"
ln -s "${dotfiles_repo}/.zshrc"        "${HOME}/.zshrc"

# Symlink Linting config
ln -s "${dotfiles_repo}/config/ruby/rubocop/default.yml" default.yml
ln -s "${dotfiles_repo}/config/ruby/rubocop/enabled.yml" enabled.yml
ln -s "${dotfiles_repo}/config/ruby/rubocop/disabled.yml" disabled.yml

# Remove existing ys.zsh-theme and replace it with the custom one
rm "${HOME}/.oh-my-zsh/themes/ys.zsh-theme"
ln -s "${dotfiles_repo}/terminal/ys.zsh-theme" "${HOME}/.oh-my-zsh/themes/ys.zsh-theme"

# Symlink Sublime Text settings
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/CoffeeScript.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/EJS.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Hack.tmLanguage"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Jack.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/HTML.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/JavaScript (Babel).sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/JavaScript.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Markdown.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Plain text.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Python.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Ruby Haml.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Ruby.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Sass.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Shell-Unix-Generic.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/SublimeLinter.sublime-settings"
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/YAML.sublime-settings"

rm -r "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/SublimeLinter"
rm -r "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/snippets"

ln -s "${dotfiles_repo}/sublime/CoffeeScript.sublime-settings"       "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/CoffeeScript.sublime-settings"
ln -s "${dotfiles_repo}/sublime/EJS.sublime-settings"                "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/EJS.sublime-settings"
ln -s "${dotfiles_repo}/sublime/Hack.tmLanguage"                     "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Hack.tmLanguage"
ln -s "${dotfiles_repo}/sublime/Jack.sublime-settings"               "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Jack.sublime-settings"
ln -s "${dotfiles_repo}/sublime/HTML.sublime-settings"               "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/HTML.sublime-settings"
ln -s "${dotfiles_repo}/sublime/JavaScript (Babel).sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/JavaScript (Babel).sublime-settings"
ln -s "${dotfiles_repo}/sublime/JavaScript.sublime-settings"         "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/JavaScript.sublime-settings"
ln -s "${dotfiles_repo}/sublime/Markdown.sublime-settings"           "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Markdown.sublime-settings"
ln -s "${dotfiles_repo}/sublime/Plain text.sublime-settings"         "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Plain text.sublime-settings"
ln -s "${dotfiles_repo}/sublime/Python.sublime-settings"             "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Python.sublime-settings"
ln -s "${dotfiles_repo}/sublime/Ruby Haml.sublime-settings"          "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Ruby Haml.sublime-settings"
ln -s "${dotfiles_repo}/sublime/Ruby.sublime-settings"               "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Ruby.sublime-settings"
ln -s "${dotfiles_repo}/sublime/Sass.sublime-settings"               "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Sass.sublime-settings"
ln -s "${dotfiles_repo}/sublime/Shell-Unix-Generic.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Shell-Unix-Generic.sublime-settings"
ln -s "${dotfiles_repo}/sublime/SublimeLinter.sublime-settings"      "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/SublimeLinter.sublime-settings"
ln -s "${dotfiles_repo}/sublime/YAML.sublime-settings"               "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/YAML.sublime-settings"

mkdir "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/SublimeLinter"
ln -s ${dotfiles_repo}/sublime/SublimeLinter/* "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/SublimeLinter/"
mkdir "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/snippets"
ln -s ${dotfiles_repo}/sublime/snippets/* "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/snippets/"

# These settings have to be done sequentially so they don't get overwritten
rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Preferences.sublime-settings" && \
  ln -s "${dotfiles_repo}/sublime/Preferences.sublime-settings" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Preferences.sublime-settings"

rm "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Default (OSX).sublime-keymap" && \
  ln -s "${dotfiles_repo}/sublime/Default (OSX).sublime-keymap" "${HOME}/Library/Application Support/Sublime Text 3/Packages/User/Default (OSX).sublime-keymap"

# Symlink macOS system settings
ln -s "${dotfiles_repo}/macos/plist/com.kortaggio.airportoff.plist" "${HOME}/Library/LaunchAgents/com.kortaggio.airportoff.plist"
