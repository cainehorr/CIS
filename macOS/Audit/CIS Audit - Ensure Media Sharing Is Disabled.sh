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
#   CIS Audit - Ensure Media Sharing Is Disabled
#
#   PROFILE APPLICABILITY: 
#   Level 2
#
#   DESCRIPTION: 
#   Starting with macOS 10.15, Apple has provided a control which permits a user to share
#   Apple downloaded content on all Apple devices that are signed in with the same Apple
#   Account. This allows users to share downloaded Movies, Music, or TV shows with other
#   controlled macOS, iOS and iPadOS devices, as well as photos with Apple TVs.
#   
#   With this capability, guest users can also use media downloaded on the computer.
#   
#   The recommended best practice is not to use the computer as a server, but to utilize
#   Apple's cloud storage in order to download and use content stored there if content
#   tored with Apple is used on multiple devices.
#   
#   https://support.apple.com/guide/mac-help/set-up-media-sharing-on-mac-mchlp13371337/mac
#   
#   Note: In macOS 15.0 Sequoia, Apple added a supported profile key for Media Sharing
#   that replaces the keys in the benchmarks in previous versions.
#
#   RATIONALE: 
#   Disabling Media Sharing reduces the remote attack surface of the system.
#
#   IMPACT: 
#   Media Sharing allows for pre-downloaded content on a Mac to be available to other
#   Apple devices on the same network. Leaving this disabled forces device users to
#   stream or download content from each Apple authorized device. This sharing could
#   even allow unauthorized devices on the same network media access.
#
#   AUDIT: 
#   Verify that a profile is installed that disables Media Sharing.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-17
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
    os_version="$(sudo /usr/bin/sw_vers | /usr/bin/awk -F: '/ProductVersion/ {print $2}' | /usr/bin/sed 's/^[[:space:]]*//g' | /usr/bin/cut -d. -f1)"
}

audit(){
    if (( "${os_version}" > "${maximum_macOS_version_required}" )); then
        echo "<result>CIS Audit has not been tested on macOS version greater than ${maximum_macOS_version_required}.x</result>"
    elif [[ "${os_version}" = "14" ]] || [[ "${os_version}" = "15" ]]; then
        audit_MediaSharing="$(/usr/bin/sudo -u ${currentUser} /usr/bin/defaults read com.apple.amp.mediasharingd home-sharing-enabled)"

        if [ "${audit_MediaSharing}" = "0" ]; then
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
