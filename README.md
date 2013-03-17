userdel-validation is utility scsript that check properties of user account
prior to deleting them.

It will check for the following conditions:
- Any running process owned by userid
- Cron jobs setup by userid
- Exiting file on user home directory
- Last time user has log in
