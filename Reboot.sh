#!/bin/bash

#######################################################################################
#
#           This script will check the last reboot date of the computer. If it has been
#     more than 3 days the user is presented a popup with the option to reboot now,
#     or delay for 2 minutes, 5 minutes, or 1 hour. 1 minute from the planned reboot
#     another popup is presented with a 1 minute countdown.
#
#     Modified for Blackbaud by Ciaran Coghlan May 6th, 2020
#######################################################################################
# jss.jhp.delay.sh
# 
# the information in the jamfhelper pop-up window can be modified by changing the following below:
#
#   -title
#   -heading
#   -description
#   -icon (eg, a .b64 encoded .png or .icns file in the script or a reference to a graphics file)
#   -button1 (limited characters in field)
#   -button2 (limited characters in field)
#   -showDelayOptions (in seconds)
#
#   for other jamfHelper options see:
#
#      /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -help
#
# the case statement takes input from the jamfHelper button exit code variable "$result"
#
# some command or a series of commands separated by pipes or newlines or other functions
# containing lists of commands could be added to the script & called by replacing "$cmdstr"
# & "$pthstr" with the function names.
###########################################################################################
#
#   Last Modified for Blackbaud by Ciaran Coghlan May 11th, 2020
#
#
###########################################################################################

cleanUp(){
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# CREATE FIRST BOOT SCRIPT
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

/bin/mkdir /usr/local/jamfps

/bin/echo "#!/bin/bash
## First Run Script to remove the installer.
## Clean up files
/bin/rm -f /Library/LaunchDaemons/org.yourorgname.rebootdelay.plist
/bin/rm -f /Library/LaunchDaemons/org.yourorgname.rebootdelaywarning.plist
/bin/rm -f /Library/Scripts/rebootwarning.sh
launchctl remove org.yourorgname.rebootdelay
launchctl remove org.yourorgname.rebootdelaywarning
/bin/sleep 2
## Update Device Inventory
/usr/local/jamf/bin/jamf recon
## Remove LaunchDaemon
/bin/rm -f /Library/LaunchDaemons/com.jamfps.cleanupDelayedRestart.plist
## Remove Script
/bin/rm -fdr /usr/local/jamfps
exit 0" > /usr/local/jamfps/cleanupDelayedRestart.sh

/usr/sbin/chown root:admin /usr/local/jamfps/cleanupDelayedRestart.sh
/bin/chmod 755 /usr/local/jamfps/cleanupDelayedRestart.sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# LAUNCH DAEMON
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cat << EOF > /Library/LaunchDaemons/com.jamfps.cleanupDelayedRestart.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.jamfps.cleanupDelayedRestart</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>/usr/local/jamfps/cleanupDelayedRestart.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

##Set the permission on the file just made.
/usr/sbin/chown root:wheel /Library/LaunchDaemons/com.jamfps.cleanupDelayedRestart.plist
/bin/chmod 644 /Library/LaunchDaemons/com.jamfps.cleanupDelayedRestart.plist
}

lastBootRaw=$(sysctl kern.boottime | awk -F'[= |,]' '{print $6}')

lastBootFormat=$(date -jf "%s" "$lastBootRaw" +"%m-%d-%Y")


today=$(date +%s)
#today=$(date -v+4d +%s) ###########For Testing #############################################

diffDays=$(( (today - lastBootRaw) / 10 ))

#echo $diffDays

if [ $diffDays -ge 4 ];then

    #echo "4 days or more Running Reboot script"
    file=$(find /Library/Application\ Support/Logo/BBLogo.png)
    if [ ! -z "$file" ]
    then
        useIcon=/Library/Application\ Support/Logo/BBLogo.png
        #echo "found"
    else
        useIcon=/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns
        #echo "not found"
    fi

else
    #echo "3 days or less Exiting"
    exit 0
fi

jamfhelper()
{
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
-windowType utility \
-title "Blackbaud System Admin" \
-heading "It's time to reboot" \
-description "This computer has not restarted since $lastBootFormat. Restart now or choose a delay option." \
-icon "$useIcon" \
-iconSize 110 \
-button1 "Delay" \
-button2 "Restart Now" \
-showDelayOptions "120, 3600, 10800" # 2 Minutes, 1 Hour, 3 Hour
}

# variables
result=$(jamfhelper)
delayint=$(echo "$result" | /usr/bin/sed 's/.$//')
warndelayint=$(expr $delayint - 60)
#echo $delayint
#echo $warndelayint
defercal=$(($(/bin/date +%s) + delayint))
hour=$(/bin/date -j -f "%s" "$defercal" "+%H")
minute=$(/bin/date -j -f "%s" "$defercal" "+%M")
#echo $hour
#echo $minute
warndefercal=$(($(/bin/date +%s) + warndelayint))
warnhour=$(/bin/date -j -f "%s" "$warndefercal" "+%H")
warnminute=$(/bin/date -j -f "%s" "$warndefercal" "+%M")
#echo $warnhour
#echo $warnminute

# write launch daemon populated with variables from jamfHelper output

delay()
{
/bin/cat <<EOF > /Library/LaunchDaemons/org.yourorgname.rebootdelay.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.yourorgname.rebootdelay</string>
    <key>ProgramArguments</key>
    <array>
        <string>reboot</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>$hour</integer>
        <key>Minute</key>
        <integer>$minute</integer>
    </dict>
</dict>
</plist>
EOF
}

warndelay()
{
/bin/cat <<EOF > /Library/LaunchDaemons/org.yourorgname.rebootdelaywarning.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.yourorgname.rebootdelaywarning</string>
    <key>ProgramArguments</key>
    <array>
        <string>sh</string>
        <string>/Library/Scripts/rebootwarning.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>$warnhour</integer>
        <key>Minute</key>
        <integer>$warnminute</integer>
    </dict>
</dict>
</plist>
EOF
}

warnScript()
{
/bin/cat <<EOF > /Library/Scripts/rebootwarning.sh
#!/bin/bash

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
-windowType utility \
-title "Blackbaud System Admin" \
-heading "It's time to reboot" \
-description "This computer is set to reboot in 1 minute." \
-timeout 60 \
-timeout int \
-lockHUD \
-icon "$useIcon" \
-iconSize 110 \
-button1 "Ok"

EOF
}

finalPrep()
{
# unload launchd
#launchctl unload /Library/LaunchDaemons/org.yourorgname.rebootdelay.plist
#launchctl unload /Library/LaunchDaemons/org.yourorgname.rebootdelaywarning.plist

# set ownership on delay launch daemon
chown root:wheel /Library/LaunchDaemons/org.yourorgname.rebootdelay.plist
chmod 644 /Library/LaunchDaemons/org.yourorgname.rebootdelay.plist

# set ownership on delaywarning launch daemon
chown root:wheel /Library/LaunchDaemons/org.yourorgname.rebootdelaywarning.plist
chmod 644 /Library/LaunchDaemons/org.yourorgname.rebootdelaywarning.plist

#load launchd
launchctl load /Library/LaunchDaemons/org.yourorgname.rebootdelay.plist
launchctl load /Library/LaunchDaemons/org.yourorgname.rebootdelaywarning.plist

}

# select action based on user input

case "$result" in
    *1 )    delay
            warndelay
            warnScript
            finalPrep
            cleanUp
            ;;
    *2 )    reboot
            echo "Reboot Called"
            ;;
esac

exit 0