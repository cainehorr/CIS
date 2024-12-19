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
#   CIS Audit - Ensure Backup Automatically is Enabled If Time Machine Is Enabled
#
#   PROFILE APPLICABILITY: 
#   Level 2
#
#   DESCRIPTION: 
#   Backup solutions are only effective if the backups run on a regular basis. The time to
#   check for backups is before the hard drive fails or the computer goes missing. In order
#   to simplify the user experience so that backups are more likely to occur, Time Machine
#   should be on and set to Back Up Automatically whenever the target volume is available.
#   
#   Operational staff should ensure that backups complete on a regular basis and the
#   backups are tested to ensure that file restoration from backup is possible when needed.
#   
#   Backup dates are available even when the target volume is not available in the Time
#   Machine plist.
#   
#   SnapshotDates = ( "2020-08-20 12:10:22 +0000", "2021-02-03 23:43:22 +0000", "2022-
#   02-19 21:37:21 +0000", "2023-02-22 13:07:25 +0000", "2024-08-20 14:07:14 +0000"
#   
#   When the backup volume is connected to the computer, more extensive information is
#   available through tmutil. See man tmutil.
#   
#   Note: This recommendation needs to be set on devices where Time Machine is
#   enabled. If Time Machine is disabled, the audit is passed by default.
#
#   RATIONALE: 
#   Backups should automatically run whenever the backup drive is available.
#
#   IMPACT: 
#   The backup will run periodically in the background and could have user impact while
#   running.
#
#   AUDIT: 
#   Verify that automatic backups are set if Time Machine is enabled.
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
        audit_TimeMachine_AutoBackup="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
function run() {
let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.TimeMachine').objectForKey('AutoBackup'))
if ( pref1 == null ) {
return("Preference Not Set")
} else if ( pref1 == 1 ) {
return("true")
} else {
return("false")
}
}
EOS
)"

        if [ "${audit_TimeMachine_AutoBackup}" = "false" ]; then
            echo "<result>false</result>"
        else 
            echo "<result>true</result>"
        fi
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
