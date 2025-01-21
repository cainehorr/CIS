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
#   CIS Audit - Audit Touch ID - Biometrics for Unlock Is Disabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   Apple has integrated Touch ID with macOS and allows fingerprint use for many
#   common operations. All use of Touch ID requires the presence of a password and the
#   use of that password after every reboot, or when more than 48 hours has elapsed since
#   the device was last unlocked. Touch ID is not a password replacement. The use of
#   Touch ID can, however, make the use of passwords more secure for authorized users
#   with physical access to a Mac. Normal day-to-day work operations can eliminate the
#   use of console password entry unless a reboot is required other than on Monday
#   morning. The infrequency of password screen unlock can enable a more complicated
#   pass phrase that is seldom used. When Touch ID is used it remediates the risk of
#   shoulder surfing (including video surveillance) to capture console credentials. There
#   have been many reported shoulder surfing password captures on iOS devices. Reports
#   have not been widespread on Macs, but shoulder surfing password capture is simpler
#   than the other methods of breaking in to an encrypted Mac.
#   
#   When a SmartCard or YubiKey is provisioned by an organization and is available for
#   Console authentication, that is a much more secure option than the use of Touch ID and
#   is preferred.
#
#   RATIONALE: 
#   Touch ID allows for an account-enrolled fingerprint to access a key that uses a
#   previously provided password.
#
#   IMPACT: 
#   Touch ID is more convenient for use with aggressive screen lock controls.
#
#   AUDIT: 
#   Verify Touch ID settings for Unlock.
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
        audit_biometrics_for_unlock="$(/usr/bin/sudo -u ${currentUser} /usr/bin/bioutil -r | /usr/bin/awk -F: '/Biometrics for unlock:/ {print $2}' | /usr/bin/sed 's/^[[:space:]]*//g')"

        if [ "${audit_biometrics_for_unlock}" = "0" ]; then
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
