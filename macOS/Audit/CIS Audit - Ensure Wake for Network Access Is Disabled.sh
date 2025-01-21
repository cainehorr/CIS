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
#   CIS Audit - Ensure Wake for Network Access Is Disabled - Wake On Management Disabled
#
#   PROFILE APPLICABILITY: 
#   Level 
#
#   DESCRIPTION: 
#   This feature allows the computer to take action when the user is not present and the
#   computer is in energy saving mode. These tools require FileVault to remain unlocked
#   and fully rejoin known networks. This macOS feature is meant to allow the computer to
#   resume activity as needed regardless of physical security controls.
#   This feature allows other users to be able to access your computer’s shared resources,
#   such as shared printers or Apple Music playlists, even when your computer is in sleep
#   mode. In a closed network when only authorized devices could wake a computer, it
#   could be valuable to wake computers in order to do management push activity. Where
#   mobile workstations and agents exist, the device will more likely check in to receive
#   updates when already awake. Mobile devices should not be listening for signals on any
#   unmanaged network or where untrusted devices exist that could send wake signals.
#
#   RATIONALE: 
#   Disabling this feature mitigates the risk of an attacker remotely waking the system and
#   gaining access.
#
#   IMPACT: 
#   Management programs like Apple Remote Desktop Administrator use wake-on-LAN to
#   connect with computers. If turned off, such management programs will not be able to
#   wake a computer over the LAN. If the wake-on-LAN feature is needed, do not turn off
#   this feature.
#   
#   The control to prevent computer sleep has been retired for this version of the
#   Benchmark. Forcing the computer to stay on and use energy in case a management
#   push is needed is contrary to most current management processes. Only keep
#   computers unslept if after hours pushes are required on closed LANs.
#   
#   Turning off Wake for Network Access will also not allow Find My to work when the
#   computer is asleep. It will also give this warning: "You won’t be able to locate, lock, or
#   erase this Mac while it’s asleep because Wake for network access is turned off."
#
#   AUDIT: 
#   Verify if Wake for network access is not enabled
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2025-01-02
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
        audit_womp="$(/usr/bin/sudo /usr/bin/pmset -g custom | /usr/bin/grep -e womp | /usr/bin/grep "1")"

        if [ -z "${audit_womp}" ]; then
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
