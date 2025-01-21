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
#   CIS Audit - Ensure Bluetooth Sharing Is Disabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   Bluetooth Sharing allows files to be exchanged with Bluetooth-enabled devices.
#
#   RATIONALE: 
#   Disabling Bluetooth Sharing minimizes the risk of an attacker using Bluetooth to
#   remotely attack the system.
#
#   IMPACT: 
#   There is a general expectation that Bluetooth peripherals will be used by most users in
#   Apple's ecosystem. Disabling sharing should have no impact on the use of Bluetooth
#   peripherals.
#
#   AUDIT: 
#   Verify that Bluetooth Sharing is not enabled
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
        audit_BlueToothSharing="$(/usr/bin/sudo -u ${currentUser} /usr/bin/defaults -currentHost read com.apple.Bluetooth PrefKeyServicesEnabled)"

        if [ "${audit_BlueToothSharing}" = "1" ]; then
            echo "<result>false</result>"
        else 
            echo "<result>true</result>"
        fi
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
