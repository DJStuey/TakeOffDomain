#!/bin/bash
#########################################################################################
#Script to Take Computer off Ivanhoe Grammar School Domain
#Prepared by Stuart Lamont
#February 2016
#########################################################################################

#Get Computer Name and send an email to the JSS Administrator
COMPNAME=`/usr/sbin/scutil --get ComputerName`
echo $COMPNAME "Has begun running the TOD Script, Please remove it from the JSS" | mail -s "Computer TOD" stuart.lamont@ivanhoe.com.au

#########################################################################################
##REMOVE WiFi Profiles
#########################################################################################
## Get UUID of requested MDM Profile
currentuser=`ls -la /dev/console | cut -d " " -f 4`
MDMUUID=`sudo -u $currentuser profiles -Lv | grep "name: $4" -4 | awk -F": " '/attribute: profileIdentifier/{print $NF}'`

## Remove said profile, identified by UUID
if [[ $MDMUUID ]]; then
    sudo -u $currentuser profiles -R -p $MDMUUID
else
    echo "No Profile Found"
fi
#########################################################################################

#quit Self Service
killall "Self Service"



#remove Adobe and SparkVUE
jamf policy trigger -event uninstallAdobe
jamf policy trigger -event uninstallSparkVUE



#Force Un-Bind from Active Directory
dsconfigad -force -remove -u johndoe -p nopasswordhere

#Remove Office 2016 License
#if test -e "/Library/Preferences/com.microsoft.office.licensingV2.plist"; then
rm -rf /Library/Preferences/com.microsoft.office.licensingV2.plist
#fi
#Remove Parallels Desktop License
#if test -e "/Applications/Parallels Desktop.app”; then
    prlsrvctl deactivate-license
#fi
#Remove Local Admin Script
#if test -e "/Applications/Utilities/LocalAdmin.app”; then
    rm -rf /Applications/Utilities/LocalAdmin.app
#fi
#Remove Cocoa Dialog
#if test -e "/Applications/Utilities/CocoaDialog.app”; then
    rm -rf "/Applications/Utilities/CocoaDialog.app"
#fi
#Remove Office Serializer Installer
#if test -e "/Applications/Utilities/Office_2016_VL_serializer.pkg”; then
    rm -rf "/Applications/Utilities/Office_2016_VL_serializer.pkg"
#fi

#Remove Outlook Signature Script
#if test -e "/Applications/Utilities/Outlook for Mac Signature.app”; then
    rm -rf "/Applications/Utilities/Outlook for Mac Signature.app"
#fi
#remove Outlook Setup Script
#if test -e "/Applications/Utilities/Outlook Setup.app”; then
    rm -rf "/Applications/Utilities/Outlook Setup.app"
#fi

#Remove LoginScript LaunchAgent
#if test -e "/Library/LaunchAgents/com.Ivanhoe.MountHomeFolder.plist”; then
    rm -rf "/Library/LaunchAgents/com.Ivanhoe.MountHomeFolder.plist"
#fi
#Remove LoginScript
#if test -e "/Applications/Utilities/LoginScript.app”; then
    rm -rf "/Applications/Utilities/LoginScript.app"
#fi

#########################################################################################
#REMOVE WATCHGUARD CLIENT
#########################################################################################
#define some variable
INST_DIR=/Applications/WatchGuard/SSOClient/
DAEM_DIR=/Library/LaunchDaemons/
DAEM_PST=com.watchguard.ssodaemon.plist
AGNT_DIR=/Library/LaunchAgents/
AGNT_PST=com.watchguard.ssoclient.plist

if [ -f ${AGNT_DIR}${AGNT_PST} ]; then
    /usr/bin/sudo -u $USER /bin/launchctl unload ${AGNT_DIR}${AGNT_PST}
    echo "Try to stop agent."
    rm -f ${AGNT_DIR}${AGNT_PST}
    echo "Remove agent configuration file."
else
    echo "Failed to remove agent configuration file, not exist!!!"
fi

if [ -f ${DAEM_DIR}${DAEM_PST} ]; then
    /bin/launchctl unload ${DAEM_DIR}${DAEM_PST}
    echo "Try to stop daemon."
    rm -f ${DAEM_DIR}${DAEM_PST}
    echo "Remove daemon configruation file."
else
    echo "Failed to remove daemon configuration file, not exist!!!"
fi

if [ -d ${INST_DIR} ]; then
    rm -rf ${INST_DIR}
    echo "Remove sso client product folder."
else
    echo "Failed to remove sso client product folder, not exist!!!"
fi
#
#
#########################################################################################

#Remove PaperCut Client and LaunchAgent
rm -rf /Library/LaunchAgent/com.papercut.client.com
rm -rf /Applications/PCClient.app

#remove IT Account
jamf policy trigger -event removeITaccount

#remove JAMF Binaries
jamf removeFramework

#restart computer
shutdown -r now
