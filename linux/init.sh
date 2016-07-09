#!/bin/bash
# Web development environment for linux (Python 3)

GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Google Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update
sudo apt-get -y install google-chrome-stable

# git
echo -e "${CYAN}Enter the name you want to use to sign git commits${NC}"
read gh_name
echo -e "${CYAN}Enter the email you want to use to sign git commits${NC}"
read gh_email

# github ssh key
echo -e "${CYAN}Setting up your SSH key for Github${NC}"
ssh-keygen -t rsa -C $gh_email

sudo apt-get -y install xclip && xclip -sel clip < ~/.ssh/id_rsa.pub
echo -e "${CYAN}Paste your clipboard at:${NC}"
echo "https://github.com/settings/ssh"

echo -e "${CYAN}Press Enter to continue${NC}"
read any_key

echo -e "${CYAN}Fetching repositories Sublime Text 3 and Flux${NC}"
echo -e "${CYAN}(Press Enter to continue when prompted)${NC}"
echo -e "${GREEN}==========================${NC}"
# sublime text 3 from ppa: http://www.webupd8.org/2013/07/sublime-text-3-ubuntu-ppa-now-available.html
sudo add-apt-repository ppa:webupd8team/sublime-text-3
sudo add-apt-repository ppa:kilian/f.lux

echo -e "${CYAN}Installing Heroku Toolbelt${NC}"
echo -e "${CYAN}(Enter root password when prompted)${NC}"
echo -e "${GREEN}==========================${NC}"
wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh

echo -e "${CYAN}Continuing automated installation.${NC}"
echo -e "${CYAN}Go grab a cup of tea and come back in two hours :)${NC}"
echo -e "${GREEN}==========================${NC}"

sudo apt-get -y install git meld
git config --global user.name $gh_name
git config --global user.email $gh_email
heroku status
sudo apt-get update
sudo apt-get -y install sublime-text-installer
sudo apt-get -y install fluxgui

echo -e "${CYAN}Installing gnome tools${NC}"
echo -e "${GREEN}==========================${NC}"
sudo apt-get -y install gparted
sudo apt-get -y install gnome-system-tools

echo -e "${CYAN}Installing vlc${NC}"
echo -e "${GREEN}==========================${NC}"
sudo apt-get -y install vlc browser-plugin-vlc

echo -e "${CYAN}Installing pip${NC}"
echo -e "${GREEN}==========================${NC}"
sudo apt-get -y install python-pip
sudo apt-get -y install python3-pip

echo -e "${CYAN}Installing basic site-wide python tools${NC}"
echo -e "${GREEN}==========================${NC}"
sudo -H pip2 install virtualenv flask django requests pylint
sudo -H pip3 install virtualenv flask django requests pylint
sudo apt-get -y install python3-venv

echo -e "${CYAN}Installing basic site-wide ruby tools${NC}"
echo -e "${GREEN}==========================${NC}"
sudo apt-get -y install ruby-foreman

echo -e "${CYAN}Installing python data mining and machine learning stuff${NC}"
echo -e "${GREEN}==========================${NC}"
sudo apt-get -y install build-essential python-dev python3-dev python3-setuptools
sudo apt-get -y install python3-numpy python3-scipy libatlas-dev libatlas3gf-base
sudo apt-get -y install python-gpgme
sudo apt-get -y install libffi-dev libssl-dev libxml2-dev libxslt1-dev
sudo -H pip3 install scikit-learn cairocffi scrapy pandas nltk matplotlib

echo -e "${CYAN}Installing python text parsing and file conversion stuff${NC}"
echo -e "${GREEN}==========================${NC}"
sudo apt-get -y install pandoc
sudo -H pip3 install pypandoc beautifulsoup4
sudo apt-get -y install pdftk
echo -e "${CYAN}The next one requires 3 GB of disk space, be patient!${NC}"
sudo apt-get -y install texlive-full

echo -e "${CYAN}Installing GIMP and Inkscape{NC}"
echo -e "${GREEN}==========================${NC}"
sudo apt-get -y install gimp inkscape

echo -e "${CYAN}Installing Calibre${NC}"
echo -e "${GREEN}==========================${NC}"
sudo -v && wget -nv -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | sudo python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()"

echo -e "${CYAN}Installing Android Debug Bridge${NC}"
echo -e "${GREEN}==========================${NC}"
sudo add-apt-repository -y ppa:phablet-team/tools
sudo apt-get update
sudo apt-get install -y android-tools-adb android-tools-fastboot

echo -e "${CYAN}Installing node and npm${NC}"
echo -e "${GREEN}==========================${NC}"
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g bower
sudo npm install -g grunt
sudo npm install -g gulp

echo -e "${CYAN}Installing Truecrypt v7.1a from GRC${NC}"
echo -e "${GREEN}==========================${NC}"
wget https://www.grc.com/misc/truecrypt/truecrypt-7.1a-linux-x64.tar.gz
tar xfvz truecrypt-7.1a-linux-x64.tar.gz
sudo sh truecrypt-7.1a-setup-x64

echo -e "${CYAN}Installing PureVPN's OpenVPN package${NC}"
echo -e "${GREEN}==========================${NC}"
sudo apt-get -y install network-manager-openvpn
sudo apt-get -y install network-manager-openvpn-gnome
sudo restart network-manager
echo -e "${GREEN}==========================${NC}"
echo -e "${CYAN}Finish install by going here:${NC}"
echo "http://support.purevpn.com/openvpn-configuration-guide-for-linux-mint"
