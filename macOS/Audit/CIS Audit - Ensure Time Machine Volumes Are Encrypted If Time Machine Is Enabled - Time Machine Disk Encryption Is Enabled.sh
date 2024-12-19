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
#   CIS Audit - Ensure Time Machine Volumes Are Encrypted If Time Machine Is Enabled - Time Machine Disk Encryption Is Enabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   One of the most important security tools for data protection on macOS is FileVault. With
#   encryption in place, it makes it difficult for an outside party to access your data if they
#   get physical possession of the computer. One very large weakness in data protection
#   with FileVault is the level of protection on backup volumes. If the internal drive is
#   encrypted but the external backup volume that goes home in the same laptop bag is
#   not, it is self-defeating. Apple tries to make this mistake easily avoided by providing a
#   checkbox to enable encryption when setting up a Time Machine backup. Using this
#   option does require some password management, particularly if a large drive is used
#   with multiple computers. A unique, complex password to unlock the drive can be stored
#   in keychains on multiple systems for ease of use.
#   
#   While some portable drives may contain non-sensitive data and encryption may make
#   interoperability with other systems difficult, backup volumes should be protected just like
#   boot volumes.
#   
#   Note: This recommendation needs to be set on devices where Time Machine is
#   enabled. If Time Machine is disabled, the audit is passed by default.
#
#   RATIONALE: 
#   Backup volumes need to be encrypted.
#
#   IMPACT: 
#   N/A
#
#   AUDIT: 
#   Verify if the Time Machine disk encryption is enabled.
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
        audit_Time_Machine_Status="$(/usr/bin/sudo /usr/bin/defaults read /Library/Preferences/com.apple.TimeMachine.plist | /usr/bin/grep -c NotEncrypted)"

        if [ "${audit_Time_Machine_Status}" = "0" ]; then
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
