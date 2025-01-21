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
#   CIS Audit - Audit Universal Control Settings - Disabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   Universal Control is an Apple feature that allows Mac users to control multiple other
#   Macs and iPads with the same keyboard, mouse, and trackpad using the same Apple
#   Account. The technology relies on already available iCloud services, particularly
#   Handoff.
#   
#   Universal Control simplifies the use of iCloud connectivity of multiple computers using
#   the same Apple Account. This may simplify data transfer from organizationally-managed
#   and personal devices. The use of the same iCloud account and Handoff is the
#   underlying concern that should be evaluated. The use of the same keyboard or mouse
#   across multiple devices does not by itself decrease organizational security.
#   
#   Universal Clipboard, a feature of Universal Control, allows any device using the same
#   Apple Account to access the clipboard of any other devices using the same Apple
#   Account.
#
#   RATIONALE: 
#   The use of devices together when some are organizational and some are not may
#   complicate device management standards.
#   
#   Universal control settings may also enable a user to share their clipboard across
#   multiple devices authenticated to the same Apple Account, so disabling that should be
#   discussed by the organization.
#
#   IMPACT: 
#   The user should not be impacted if Universal Control is set either way.
#
#   AUDIT: 
#   Verify a profile is installed that configures Universal Control.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-27
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
        audit_universalcontrol="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.universalcontrol').objectForKey('Disable').js
EOS
)"

        if [ "${audit_universalcontrol}" = "true" ]; then
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
