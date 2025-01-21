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
#   CIS Audit - Audit Hide IP Address in Safari Setting - Hide IP From Tracker Status
#
#   PROFILE APPLICABILITY: 
#   Level 2
#
#   DESCRIPTION: 
#   Public (Routable) IP addresses can be used to track people to their current location,
#   including home and business addresses. While a valid IP address is necessary to load
#   the site, the valid address does not need to be provided to known trackers and should
#   be hidden.
#
#   RATIONALE: 
#   Trackers can correlate your visits through various applications, including websites, and
#   are a threat to your privacy.
#
#   IMPACT: 
#   Website address blocking through iCloud Private Relay may prevent some wanted
#   pages from loading that use IP geolocation access controls.
#   Some organizations use IP address access controls (ACLs). If your organization or
#   partners are using IP address ACLs, there will be unreachable web services if Apple
#   hides the IP address.
#
#   AUDIT: 
#   Verify if IP addresses are hidden from trackers in Safari
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2025-01-10
#       Initial script creation
#       Tested against macOS 14.7.1 - Sonoma
#
####################################################################################################

minimum_macOS_version_required="14"
maximum_macOS_version_required="15"

main(){
	run_as_root
    get_processor_type
    get_os_version
    acquire_logged_in_user
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

get_processor_type(){
    # processor_type="$(/usr/sbin/sysctl -n machdep.cpu.brand_string | /usr/bin/grep -e Intel | /usr/bin/awk '{print substr($1, 1, length($1)-3)}')"

    processor_type="$(/usr/sbin/sysctl -n machdep.cpu.brand_string)"

    if [[ ! -z $(/usr/sbin/sysctl -n machdep.cpu.brand_string | /usr/bin/grep -e Intel) ]]; then
        processor_type="Intel"
    elif [[ ! -z $(/usr/sbin/sysctl -n machdep.cpu.brand_string | /usr/bin/grep -e Apple) ]]; then
        processor_type="ARM"
    else 
        processor_type="UNKNOWN"
    fi
}

get_os_version(){
    os_version="$(/usr/bin/sudo /usr/bin/sw_vers | /usr/bin/awk -F: '/ProductVersion/ {print $2}' | /usr/bin/sed 's/^[[:space:]]*//g' | /usr/bin/cut -d. -f1)"
}

acquire_logged_in_user(){
    currentUser=$(/usr/bin/stat -f "%Su" "/dev/console")
}

audit(){
    if (( "${os_version}" > "${maximum_macOS_version_required}" )); then
        echo "<result>CIS Audit has not been tested on macOS version greater than ${maximum_macOS_version_required}.x</result>"
    elif [[ "${os_version}" = "14" ]] || [[ "${os_version}" = "15" ]]; then
        audit_WBSPrivacyProxyAvailabilityTraffic="$(/usr/bin/sudo -u ${currentUser} /usr/bin/defaults read /Users/${currentUser}/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari WBSPrivacyProxyAvailabilityTraffic)"

        if [ "${audit_WBSPrivacyProxyAvailabilityTraffic}" = "33422560" ]; then
            echo "<result>IP Address is not hidden from Trackers</result>"
        elif [ "${audit_WBSPrivacyProxyAvailabilityTraffic}" = "33422564" ]; then
            echo "<result>IP Address is hidden from Trackers Only</result>"
        elif [ "${audit_WBSPrivacyProxyAvailabilityTraffic}" = "33422572" ]; then
            echo "<result>IP Address is hidden from Trackers and Websites</result>"
        else 
            echo "<result>IP Address is not hidden from Trackers</result>"
        fi
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
