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
#   CIS Audit - Ensure Listen for (Siri) Is Disabled - Profile Installed
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   macOS includes the Siri digital assistant and if enabled it is always listening in case it is
#   needed. In Sonoma a user may choose either "Hey Siri" or either "Siri" and "Hey Siri." In
#   either case, Siri is using the microphone at all times to listen for instructions and then
#   can record questions once activated. In an organizational environment where people
#   are talking and listening on video/voice calls, there are too many opportunities for
#   unauthorized information disclosure to have a live microphone at all times. If Siri will be
#   used it may be on, with "Listen for" Off and a keyboard shortcut selected.
#
#   RATIONALE: 
#   In most environments there is too much unbounded risk of data spillage with a
#   microphone always on, listening for instruction, and listening for questions if attention is
#   obtained, relying on cloud compute to answer them. There are many examples of data
#   leakage for technology in this space, and future vulnerabilities and bugs are certainly
#   possible.
#
#   IMPACT: 
#   Siri will not be available for hands-free usage, or not available at all if turned off
#   completely.
#
#   AUDIT: 
#   Verify that an installed profile has VoiceTriggerUserEnabled set to 0.
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
        audit_Hey_Siri="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.Siri').objectForKey('VoiceTriggerUserEnabled').js
EOS
)"

        if [ "${audit_Hey_Siri}" = "true" ]; then
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
