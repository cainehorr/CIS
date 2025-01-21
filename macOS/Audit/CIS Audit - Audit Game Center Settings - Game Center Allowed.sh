#!/bin/zsh

####################################################################################################
#
#   CREATED BY: Caine Hörr <caine@cainehorr.com>
#
####################################################################################################
#
#   BENCHMARK REFERENCE: 
#   Center for Information Security (CIS) - https://workbench.cisecurity.org/
#
#   BENCHMARK VERSION:
#   CIS Apple macOS 15.0 Sequoia Benchmark, v1.0.0 - 10-28-2024
#
####################################################################################################
#
#   BENCHMARK NAME:
#   CIS Audit - Audit Game Center Settings - Game Center Allowed
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   With macOS 10.13, Apple has introduced a separate section for Game Center in
#   System Settings. It is possible to log in with the Apple Account and use the iCloud-
#   based Game Center services.
#   
#   Game Center is a feature from Apple that allows users to engage in game-related
#   activities with friends when playing multiplayer games online on the Game Center social
#   network. User profile data such as nickname, contact discovery, and also nearby
#   players may be shared through iCloud.
#   
#   Apple collects information here, such as the games users play and when they play
#   them, all scores and achievements, and the challenges users send and receive. This
#   information is used to track users' high scores, achievements, and challenges and to
#   improve Game Center.
#   
#   The automatic sign in to Game Center with AppleID should be disabled if not aligned
#   with organizational rules
#   
#   Personal profile visibility, Finding by Friends, requests from Contacts, Nearby Player
#   detection and Connecting with Friends are all visibility options that should be risk
#   accepted through an organizational policy before use.
#   
#   Users should not sign in to Game Center on organizational managed devices if not
#   covered under acceptable use. For personal devices Gam
#
#   RATIONALE: 
#   Ensure Game Center service is used consistently with organizational requirements.
#
#   IMPACT: 
#   Game Center is designed as a social network to use Apple's gaming service and
#   includes capabilities to discover players in the service as through local network
#   discovery. If the Apple feature is not needed it should not be on, and should not be
#   signed in.
#
#   AUDIT: 
#   Verify the status of iCloud Game Center service.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2025-01-06
#       Initial script creation
#       Tested against macOS 14.7.1 - Sonoma
#
####################################################################################################

minimum_macOS_version_required="14"
maximum_macOS_version_required="15"

main(){
	run_as_root
    acquire_logged_in_user
    get_os_version
	audit
}

run_as_root(){
    # This is here for local testing upon the command line
    if [ "$(/usr/bin/id -u)" != "0" ]; then
        echo ""
        echo "ERROR: Script must be run as root or with sudo."
        echo ""
        exit 1
    fi
}

acquire_logged_in_user(){
    currentUser=$(/usr/bin/stat -f "%Su" "/dev/console")
}

get_os_version(){
    os_version="$(/usr/bin/sudo /usr/bin/sw_vers | /usr/bin/awk -F: '/ProductVersion/ {print $2}' | /usr/bin/sed 's/^[[:space:]]*//g' | /usr/bin/cut -d. -f1)"
}

audit(){
    if (( "${os_version}" > "${maximum_macOS_version_required}" )); then
        echo "<result>CIS Audit has not been tested on macOS version greater than ${maximum_macOS_version_required}.x</result>"
    elif [[ "${os_version}" = "14" ]] || [[ "${os_version}" = "15" ]]; then
        audit_Game_Center_Enabled="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess').objectForKey('allowGameCenter').js
EOS
)"

        if [ "${audit_Game_Center_Enabled}" = "true" ]; then
            echo "<result>true</result>"
        else 
            echo "<result>false</result>"
        fi
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
