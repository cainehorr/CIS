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
#   CIS Audit - Ensure Set Time and Date Automatically Is Enabled - Date and Time Are Automatically Set
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   Correct date and time settings are required for authentication protocols, file creation,
#   modification dates, and log entries.
#
#   Note: If your organization has internal time servers, enter them here. Enterprise mobile
#   devices may need to use a mix of internal and external time servers. If multiple servers
#   are required, use the Date & Time System Preference with each server separated by a space.
#
#   Additional Note: The default Apple time server is time.apple.com. Variations include
#   time.euro.apple.com. While it is certainly more efficient to use internal time servers,
#   there is no reason to block access to global Apple time servers or to add a
#   time.apple.com alias to internal DNS records. There are no reports that Apple gathers
#   any information from NTP synchronization, as the computers already phone home to
#   Apple for Apple services including iCloud use and software updates. Best practice is to
#   allow DNS resolution to an authoritative time service for time.apple.com, preferably to
#   connect to Apple servers, but local servers are acceptable as well.
#
#   RATIONALE: 
#   Kerberos may not operate correctly if the time on the Mac is off by more than 5 minutes.
#   This in turn can affect Apple's single sign-on feature, Active Directory logons, and other
#   features.
#
#   IMPACT: 
#   The timed service will periodically synchronize with named time servers and will make
#   the computer time more accurate.
#
#   AUDIT: 
#   Ensure that date and time are automatically set.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-12
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
        audit_getusingnetworktime="$(/usr/bin/sudo /usr/sbin/systemsetup -getusingnetworktime | /usr/bin/awk '{print $3}')"

        echo "<result>${audit_getusingnetworktime}</result>"
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
