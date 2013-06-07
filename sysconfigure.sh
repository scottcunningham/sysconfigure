#!/bin/bash

# Scott Cunningham <cunninsc@tcd.ie>
# http://bitbucket.com/scottbpc/sysconfigure

SYSCONFIGURE_PATH=`pwd`
DATETIME=`date | sed s/' '/-/g | sed s/:/_/g`

if cat /etc/issue | grep -i suse > /dev/null
	then 
		PKG_INSTALLER='zypper install'
		ARCHIVE_INSTALLER='rpm -i'
		PKG_TYPE='rpm'
		UPDATE_CMD="zypper refresh"
elif cat /etc/issue | grep -i debian > /dev/null
	then 
		INSTALLER='apt-get install'
		PKG_INSTALLER='dpkg -i'
		PKG_TYPE='deb'
		UPDATE_CMD="apt-get update"
elif cat /etc/issue | grep -i ubuntu > /dev/null
	then 
		INSTALLER='apt-get install'
		PKG_INSTALLER='dpkg -i'
		PKG_TYPE='deb'
		UPDATE_CMD="apt-get update"
fi

echo $DATETIME

# Should always start this script in $HOME
cd 

# Install packages
if [ -f $SYSCONFIGURE_PATH/pkgs ]
    echo Installing `cat $SYSCONFIGURE_PATH/pkgs`
    then sudo $UPDATE_CMD && sudo $INSTALLER `cat $SYSCONFIGURE_PATH/pkgs`
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
if [ -f .zshrc ] 
	then mv .zshrc .zshrc.$DATETIME.old
fi
git clone https://scottbpc@bitbucket.org/scottbpc/zshrc.git
ln -s zshrc/.zshrc .

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
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.$PKG_TYPE -O chrome-$DATETIME.$PKG_TYPE
sudo $PKG_INSTALLER chrome-$DATETIME.$PKG_TYPE

# Fix any broken dependencies that Chrome leaves behind
sudo apt-get -f install

rm chrome-$DATETIME.$PKG_TYPE

echo "Installing google talk plugin"
wget https://dl.google.com/linux/direct/google-talkplugin_current_amd64.$PKG_TYPE -O google-talk-$DATETIME.$PKG_TYPE
sudo $PKG_INSTALLER google-talk-$DATETIME.$PKG_TYPE

# Fix any broken dependencies that this leaves behind too
sudo apt-get -f install

rm google-talk-$DATETIME.$PKG_TYPE

# Go $HOME
echo "Done!"
cd
