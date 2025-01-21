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
#   CIS Audit - Ensure Guest Account Is Disabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   The guest account allows users access to the system without having to create an
#   account or password. Guest users are unable to make setting changes and cannot
#   remotely login to the system. All files, caches, and passwords created by the guest user
#   are deleted upon logging out.
#
#   RATIONALE: 
#   Disabling the guest account mitigates the risk of an untrusted user doing basic
#   reconnaissance and possibly using privilege escalation attacks to take control of the
#   system.
#
#   IMPACT: 
#   A guest user can use that access to find out additional information about the system
#   and might be able to use privilege escalation vulnerabilities to establish greater access.
#
#   AUDIT: 
#   Ensure that the guest account is not available.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2025-01-06
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
    os_version="$(/usr/bin/sudo /usr/bin/sw_vers | /usr/bin/awk -F: '/ProductVersion/ {print $2}' | /usr/bin/sed 's/^[[:space:]]*//g' | /usr/bin/cut -d. -f1)"
}

audit(){
    if (( "${os_version}" > "${maximum_macOS_version_required}" )); then
        echo "<result>CIS Audit has not been tested on macOS version greater than ${maximum_macOS_version_required}.x</result>"
    elif [[ "${os_version}" = "14" ]] || [[ "${os_version}" = "15" ]]; then
        audit_guest_account_active="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
function run() {
let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX').objectForKey('DisableGuestAccount'))
let pref2 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX').objectForKey('EnableGuestAccount'))
let pref3 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.loginwindow').objectForKey('GuestEnabled'))
if (( pref1 == 1 && pref2 == 0 ) || ( pref3 == 0 )) {
return("true")
} else {
return("false")
}
}
EOS
)"

        if [ "${audit_guest_account_active}" = "true" ]; then
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

/usr/bin/sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false