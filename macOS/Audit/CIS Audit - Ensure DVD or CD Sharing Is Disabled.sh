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
#   CIS Audit - Ensure DVD or CD Sharing Is Disabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   DVD or CD Sharing allows users to remotely access the system's optical drive. While
#   Apple does not ship Macs with built-in optical drives any longer, external optical drives
#   are still recognized when they are connected. In testing, the sharing of an external
#   optical drive persists when a drive is reconnected.
#
#   RATIONALE: 
#   Disabling DVD or CD Sharing minimizes the risk of an attacker using the optical drive as
#   a vector for attack and exposure of sensitive data.
#
#   IMPACT: 
#   Many Apple devices are now sold without optical drives, however drive sharing may be
#   needed for legacy optical media. The media should be explicitly re-shared as needed
#   rather than using a persistent share. Optical drives should not be used for long-term
#   storage. To store necessary data from an optical drive it should be copied to another
#   form of external storage. Optionally, an image can be made of the optical drive so that it
#   is stored in its original form on another form of external storage.
#
#   AUDIT: 
#   Verify if DVD or CD Sharing Is Disabled
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

get_os_version(){
    os_version="$(sudo /usr/bin/sw_vers | /usr/bin/awk -F: '/ProductVersion/ {print $2}' | /usr/bin/sed 's/^[[:space:]]*//g' | /usr/bin/cut -d. -f1)"
}

audit(){
    if (( "${os_version}" > "${maximum_macOS_version_required}" )); then
        echo "<result>CIS Audit has not been tested on macOS version greater than ${maximum_macOS_version_required}.x</result>"
    elif [[ "${os_version}" = "14" ]] || [[ "${os_version}" = "15" ]]; then
        audit_ODSAgent="$(/usr/bin/sudo /bin/launchctl list | /usr/bin/grep -c com.apple.ODSAgent)"

        if [ "${audit_ODSAgent}" = "0" ]; then
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
