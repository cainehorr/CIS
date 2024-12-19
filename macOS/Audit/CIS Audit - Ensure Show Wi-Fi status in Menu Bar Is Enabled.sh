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
#   CIS Audit - Ensure Show Wi-Fi status in Menu Bar Is Enabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   The Wi-Fi status in the menu bar indicates if the system's wireless internet capabilities
#   are enabled. If so, the system will scan for available wireless networks in order to
#   connect. At the time of this revision, all computers Apple builds have wireless network
#   capability, which has not always been the case. This control only pertains to systems
#   that have a wireless NIC available. Operating systems running in a virtual environment
#   may not score as expected, either.
#
#   RATIONALE: 
#   Enabling "Show Wi-Fi status in menu bar" is a security awareness method that helps
#   mitigate public area wireless exploits by making the user aware of their wireless
#   connectivity status.
#
#   IMPACT: 
#   The user of the system should have a quick check on their wireless network status
#   available.
#
#   AUDIT: 
#   Verify that the Wi-Fi status shows in the menu bar.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-18
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
        audit_WiFi_Menu_Bar_Icon="$(/usr/bin/sudo -u ${currentUser} /usr/bin/defaults -currentHost read com.apple.controlcenter.plist WiFi)"

        if [ "${audit_WiFi_Menu_Bar_Icon}" = "2" ]; then
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
