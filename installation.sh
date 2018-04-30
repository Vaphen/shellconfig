#!/bin/sh

password=""

readPassword() {
    echo -n 'Enter the root password: '
    stty -echo
    read password
    stty echo
    echo
}

getSuRights() {
    echo "$password" | sudo -S echo 1>/dev/null 2>/dev/null
    if [ ! $? = 0 ]; then
	echo "-x You entered a wrong password."
	exit 1
    fi
}

revokeSuRights() {
    sudo -k
}


installIotaExecutable() {
    getSuRights

    if sudo -S ls /usr/bin/iota 1>/dev/null 2>/dev/null; then
	echo "-x IOTA executable already found at /usr/bin/iota"
    else
	sudo -S cp ./iota /usr/bin/
	sudo -S chmod 775 /usr/bin/iota
	echo "-> IOTA executable saved as /usr/bin/iota"
    fi
    revokeSuRights
}

installIotaCronJob() {
    jobLine="*/3 * * * * iota"

    if crontab -l | grep -q "iota"; then
	echo "-x IOTA cronjob already existent"
    else
        crontab -l > /tmp/crons
        echo "$jobLine" >> /tmp/crons
	crontab /tmp/crons
    	rm /tmp/crons
	iota 2>/dev/null 1>/dev/null
	echo "-> IOTA cronjob installed"
    fi
}

installBackground() {
    if ! command -v feh 2>/dev/null 1>/dev/null; then
	echo "-x Feh not found. Install it in order to set the backgroud image"
	return
    fi	    
    if [ -f $HOME/.xsession ] && cat $HOME/.xsession | grep -q "feh"; then
	echo "-x Background already set"
    else
	if [ -f $HOME/Pictures/bg.jpg ]; then
	    echo "-- Background file $HOME/Pictures/bg.jpg already existent. Using this one."
	else
	    mkdir -p $HOME/Pictures
	    cp ./bg.jpg $HOME/Pictures/
	fi
        command="feh --bg-scale $HOME/Pictures/bg.jpg"
       	$command >> $HOME/.xsession
        echo $command >> $HOME/.xsession
        feh --bg-scale $HOME/Pictures/bg.jpg
	echo "-> Background set"
    fi
}

installLambdaZshTheme() {
    if [ -d $HOME/.oh-my-zsh/custom ]; then
	mkdir $HOME/.oh-my-zsh/custom/themes 2>/dev/null 1>/dev/null
	if [ -f $HOME/.oh-my-zsh/custom/themes/lambda-mod.zsh-theme ]; then
		echo "-x Lambda mod theme already existent at $HOME/.oh-my-zsh/custom/themes/lambda-mod.zsh-theme"
	else
	    cp ./lambda-mod.zsh-theme $HOME/.oh-my-zsh/custom/themes/
	fi
	if [ -f $HOME/.zshrc ]; then
	    mv $HOME/.zshrc $HOME/.zshrc.`date +%d:%m:%Y_%T`
	fi
    	cp ./.zshrc $HOME/
	echo "-> Lambda zsh theme installed."
    else
	echo "-x Have you installed oh-my-zsh? $HOME/.oh-my-zsh/custom/themes not found."
    fi
}

readPassword
installIotaExecutable
installIotaCronJob
installLambdaZshTheme
installBackground
