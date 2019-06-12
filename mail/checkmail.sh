#!/bin/sh

STATE=`nmcli networking connectivity`

if [ $STATE = 'full' ]
then
    ~/.dotfiles/mail/msmtp-runqueue.sh
    mbsync -qq gwenlofmanio
    notmuch new
    afew -tn
    exit 0
fi
echo "No internet connection."
exit 0
