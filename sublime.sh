# Sublime text settings (outdated)

dotfiles_repo=`pwd`
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
