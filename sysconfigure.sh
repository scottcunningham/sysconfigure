#/bin/bash

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
git config --global user.email "scottcunningham92@gmail.com"

# Get shell config
echo "Fetching zsh config from bitbucket"
if [ -f .zshrc ] 
	then mv .zshrc .zshrc.$DATETIME.old
fi

cd src

git clone https://github.com/scottcunningham/dotfiles
cd dotfiles
./install.sh
cd

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

cd src
echo "Grabbing vim config/plugins from Github"
git clone https://github.com/scottcunningham/vimrc

ln -s vimrc/vimrc ~/.vimrc

# Go $HOME
echo "Done!"
cd
