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
#   BENCHMARK BENCHMARK VERSION:
#   CIS Apple macOS 15.0 Sequoia Benchmark, v1.0.0 - 10-28-2024
#
####################################################################################################
#
#   BENCHMARK NAME:
#   CIS Audit - Ensure AirPlay Receiver Is Disabled - Allow AirPlay Incoming Requests
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   In macOS Monterey (12.0), Apple has added the capability to share content from
#   another Apple device to the screen of a host Mac. While there are many valuable uses
#   of this capability, such sharing on a standard Mac user workstation should be enabled
#   ad hoc as required rather than allowing a continuous sharing service. The feature can
#   be restricted by Apple Account or network and is configured to use by accepting the
#   connection on the Mac. Part of the concern is frequent connection requests may
#   function as a denial-of-service and access control limits may provide too much
#   information to an attacker.
#
#   https://macmost.com/how-to-use-a-mac-as-an-airplay-receiver.html
#
#   https://support.apple.com/guide/mac-pro-rack/use-airplay-apdf1417128d/mac
#
#   RATIONALE: 
#   This capability appears very useful for kiosk and shared work spaces. The ability to
#   allow by network could be especially useful on segregated guest networks where
#   visitors could share their screens on computers with bigger monitors, including
#   computers connected to projectors.
#
#   IMPACT: 
#   Turning off AirPlay sharing by default will not allow users to share without turning the
#   service on. The service should be enabled as needed rather than left on.
#
#   AUDIT: 
#   Verify that AirPlay Receiver is disabled.
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
        audit_AirplayRecieverEnabled="$(/usr/bin/sudo -u ${currentUser} /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.controlcenter').objectForKey('AirplayRecieverEnabled').js
EOS
)"

        echo "<result>${audit_AirplayRecieverEnabled}</result>"
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
