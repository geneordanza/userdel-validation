#!/bin/bash
#
# Description:
#   This program validate the following conditions and generate an output file
#   called userdel-validate.txt:
#   - Any running process by userid
#   - Cron job setup by userid
#   - Files (if any) on user's home directory
#   - Last time user has log in
#
# Author: Gene Ordanza <geronimo.ordanza@fisglobal.com>
#
# NOTES:
#   * This script requires an input file called userlist which contain a list
#     of userid you need to check.
#   * The script will generate a file called "checkuser.txt" when done
#   * The script will skip over userids not found on /etc/passwd
#   * Some server does not use NOPASSWD parameter in /etc/sudoer file, very
#     annoying if you need to check 3 or more userids.
#   *

LOG=checkuser.txt

printf "\n\tUser Listing on `hostname|tr '[:lower:]' '[:upper:]'`" > $LOG
printf "\n\tDATE: `date +%m-%d-%Y`\n" >> $LOG

for user in $(cat userlist); do

    grep -i $user /etc/passwd &>/dev/null
    if [ $? -eq 0 ]; then
        sudo ls /home/$user > $user-homedir
        if [[ `ls -l $user-homedir | awk '{print $5}'` -eq 0 ]]; then
            printf "\n* $user's home directory is empty\n" >> $LOG
        else
            printf "\n* $user's home directory CONTAIN files\n" >> $LOG
        fi
    else
        continue
    fi

    ps aux | grep $user | grep -v 'grep' > $user-process
    if [[ `ls -l $user-process | awk '{print $5}'` -eq 0 ]]; then
        printf "  There are no running process under $user\n" >> $LOG
    else
        printf "  Processes running under \"$user\".  Check manually\n" >> $LOG
    fi

    sudo crontab -l -u $user > $user-cron
    if [[ `ls -l $user-cron | awk '{print $5}'` -eq 0 ]]; then
        printf "  There are no cron job under $user\n" >> $LOG
    else
        printf "  Crontab running under $user. Check manually\n" >> $LOG
    fi

    #sudo lastlog -u $user|awk -v id="$user" '/id/ {print $5, $6, $NF}' >> $LOG
    sudo lastlog -u $user|tail -n1|awk '
        {print "  Last login: ", $5, $6, $NF}' >> $LOG

    echo "" >> $LOG
    rm -f $user-homedir $user-process $user-cron

done

echo "  NOTE: \"Last login:  in**\" means that the user never log in." >> $LOG
