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
#   CIS Audit - Ensure an Inactivity Interval of 20 Minutes Or Less for the Screen Saver Is Enabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   A locking screen saver is one of the standard security controls to limit access to a
#   computer and the current user's session when the computer is temporarily unused or
#   unattended. In macOS, the screen saver starts after a value is selected in the drop-
#   down menu. 20 minutes or less is an acceptable value. Any value can be selected
#   through the command line or script, but a number that is not reflected in the GUI can be
#   problematic. 20 minutes is the default for new accounts.
#
#   RATIONALE: 
#   Setting an inactivity interval for the screen saver prevents unauthorized persons from
#   viewing a system left unattended for an extensive period of time.
#
#   IMPACT: 
#   If the screen saver is not set, users may leave the computer available for an
#   unauthorized person to access information.
#
#   AUDIT: 
#   verify that the screen saver is set to activate after less than or equal to 20 minutes of 
#   inactivity
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2025-01-03
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
        audit_screensaver_idle_time="$(/usr/bin/sudo -u ${currentUser} /usr/bin/osascript -l JavaScript << EOS
function run() {
let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.screensaver').objectForKey('idleTime'))
if ( pref1 <= 1200 ) {
return("true")
} else {
return("false")
}
}
EOS
)"

        if [ "${audit_screensaver_idle_time}" = "true" ]; then
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
