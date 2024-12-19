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
#   CIS Audit - Ensure Location Services Is Enabled
#
#   PROFILE APPLICABILITY: 
#   Level 2
#
#   DESCRIPTION: 
#   macOS uses location information gathered through local Wi-Fi networks to enable
#   applications to supply relevant information to users. With the operating system verifying
#   the location, users do not need to change the time or the time zone. The computer will
#   change them based on the user's location. They do not need to specify their location for
#   weather or travel times, and they will receive alerts on travel times to meetings and
#   appointments where location information is supplied.

#   Location Services simplify some processes with mobile computers, such as asset
#   management and time or log management.

#   There are some use cases where it is important that the computer not be able to report
#   its exact location. While the general use case is to enable Location Services, it should
#   not be allowed if the physical location of the computer and the user should not be public
#   knowledge.
#
#   RATIONALE: 
#   Location Services are helpful in most use cases and can simplify log and time
#   management where computers change time zones.
#
#   IMPACT: 
#   N/A
#
#   AUDIT: 
#   Verify that Location Services is enabled.
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
        audit_locationd="$(/usr/bin/sudo /bin/launchctl list | /usr/bin/grep -c com.apple.locationd)"

        audit_LocationServicesEnabled="$(/usr/bin/sudo -u _locationd /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.locationd').objectForKey(
'LocationServicesEnabled').js
EOS
)"

        if [ "${audit_locationd}" = "1" ] && [ "${audit_LocationServicesEnabled}" = "true" ]; then
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
