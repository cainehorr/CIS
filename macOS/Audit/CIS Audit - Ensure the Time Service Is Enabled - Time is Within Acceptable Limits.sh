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
#   CIS Audit - Ensure the Time Service Is Enabled - Time is Within Acceptable Limits
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   In macOS 10.14, Apple replace ntp with timed for time services, and is used to ensure
#   correct time is kept. Correct date and time settings are required for authentication
#   protocols, file creation, modification dates and log entries.
#
#   RATIONALE: 
#   Kerberos may not operate correctly if the time on the Mac is off by more than 5 minutes.
#   This in turn can affect Apple's single sign-on feature, Active Directory logons, and other
#   features.
#
#   IMPACT: 
#   Accurate time is required for many computer functions.
#
#   AUDIT: 
#   Verify that the time on the computer is within acceptable limits.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-13
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
        audit_getnetworktimeserver="$(/usr/bin/sudo /usr/sbin/systemsetup -getnetworktimeserver | /usr/bin/awk -F: '/Network Time Server/ {print $2}' | /usr/bin/sed 's/^[[:space:]]*//g')"

        audit_offset="$(/usr/bin/sudo /usr/bin/sntp ${audit_getnetworktimeserver} | /usr/bin/awk '{print $1}' | /usr/bin/cut -c2-)"

        seconds_low_range="-270.0"
        seconds_high_range="270.0"

        if (( "${audit_offset}" > "${seconds_low_range}" )) && (( "${audit_offset}" < "${seconds_high_range}" )); then
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
