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
#   CIS Audit - Audit iPhone Mirroring - Allow iPhone Mirroring
#
#   PROFILE APPLICABILITY: 
#   Level 2
#
#   DESCRIPTION: 
#   iPhone Mirroring is a new feature offered in iOS 18 and macOS 15.0 Sequoia. It
#   allows a macOS device to remotely access an iOS device connected to the same Apple
#   Account. If a user has different Apple Accounts signed into iOS and macOS (ex. a
#   managed Apple Account on macOS and a personal Apple Account on iOS), the feature
#   is not available.
#
#   RATIONALE: 
#   Enabling iPhone Mirroring may allow a macOS device to capture data from an iOS
#   device (ex Image Capture). This would occur where the macOS device has not been
#   approved to access that information by your organization's policies and the iOS device
#   has been approved (or vice-versa).
#   
#   If iPhone Mirroring is currently in use on an iOS device, the lock screen will have a
#   notification that states iPhone in Use and state what device is using it. If iPhone
#   Mirroring was in use on an iOS device but is no longer in use, the first time the user
#   unlocks the iOS device it will notify the user that iPhone was used from Mac.
#
#   IMPACT: 
#   If iPhone Mirroring is disabled, it would stop a user from accessing information on
#   their iOS device while using their macOS device.
#
#   AUDIT: 
#   Verify the configuration for iPhone mirroring.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-27
#       Initial script creation
#       Tested against macOS 15.x - Sequoia
#
####################################################################################################

minimum_macOS_version_required="15"
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
    os_version="$(sudo /usr/bin/sw_vers | /usr/bin/awk -F: '/ProductVersion/ {print $2}' | /usr/bin/sed 's/^[[:space:]]*//g' | /usr/bin/cut -d. -f1)"
}

audit(){
    if (( "${os_version}" > "${maximum_macOS_version_required}" )); then
        echo "<result>CIS Audit has not been tested on macOS version greater than ${maximum_macOS_version_required}.x</result>"
    elif [[ "${os_version}" = "15" ]]; then
        audit_allowiPhoneMirroring="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple. applicationaccess').objectForKey('allowiPhoneMirroring').js
EOS
)"

        if [ "${audit_allowiPhoneMirroring}" = "true" ]; then
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
