#!/bin/bash

# Scott Cunningham <cunninsc@tcd.ie>
# http://bitbucket.com/scottbpc/sysconfigure

echo_colour haha

SYSCONFIGURE_PATH=`pwd`
DATETIME=`date | sed s/' '/-/g | sed s/:/_/g`

echo $DATETIME

# Should always start this script in $HOME
cd 

# Install packages
if [ -f $SYSCONFIGURE_PATH/pkgs ]
    echo Installing `cat $SYSCONFIGURE_PATH/pkgs`
    then sudo apt-get update && sudo apt-get install `cat $SYSCONFIGURE_PATH/pkgs`
else
    echo "File ´pkgs´ missing in folder $SYSCONFIGUREPATH"
    exit 1
fi

# Set up git
echo 
echo Setting up git
sleep 1
git config --global user.name "Scott Cunningham"
git config --global user.email "cunninsc@tcd.ie"

# Get shell config
echo "Fetching zsh config from bitbucket"
mv .zshrc .zshrc.$DATETIME.old
git clone https://scottbpc@bitbucket.org/scottbpc/.zshrc.git

# Change shell - this won´t work until we fully log out/in though 
echo "Changing shell to zsh"
chsh -s `which zsh`

# Get vim config
echo "Backing up old vim config in format .vim{,rc}.\$DATE.old"
if [ -f .vimrc ] 
then
    echo "Backing up vimrc"
    mv .vimrc .vimrc.$DATETIME.old
fi
if [ -d .vim -o -f .vim ] 
then
    echo "Backing up .vim"
    mv .vim .vim.$DATETIME.old
fi

echo "Grabbing vim config/plugins from bitbucket"
git clone https://scottbpc@bitbucket.org/scottbpc/.vim.git
cd .vim 

ln -s .vim/.vimrc ~/
git submodule init
git submodule update --recursive

# update vim plugins 
git pull origin master
git submodule foreach git pull origin master

echo "Installing google-chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome-$DATETIME.deb
sudo dpkg -i chrome-$DATETIME.deb

# Fix any broken dependencies that Chrome leaves behind
sudo apt-get -f install

rm chrome-$DATETIME.deb

echo "Installing google talk plugin"
wget https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb -O google-talk-$DATETIME.deb
sudo dpkg -i google-talk-$DATETIME.deb

# Fix any broken dependencies that this leaves behind too
sudo apt-get -f install

rm google-talk-$DATETIME.deb

# Go $HOME
echo "Done!"
cd
