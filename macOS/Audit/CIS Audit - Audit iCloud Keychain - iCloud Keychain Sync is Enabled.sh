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
#   CIS Audit - Audit iCloud Keychain - Profile Is Installed That Sets iCloud Keychain Sync To Organizational Settings
#
#   PROFILE APPLICABILITY: 
#   Level 2
#
#   DESCRIPTION: 
#   The iCloud keychain is Apple's password manager that works with macOS and iOS. The capability 
#   allows users to store passwords in either iOS or macOS for use in Safari on both platforms and 
#   other iOS-integrated applications. The most pervasive use is driven by iOS use rather than 
#   macOS. The passwords stored in a macOS keychain on an Enterprise-managed computer could be 
#   stored in Apple's cloud and then be available on a personal computer using the same account. 
#   The stored passwords could be for organizational as well as for personal accounts.
#
#   If passwords are no longer being used as organizational tokens, they are not in scope for iCloud 
#   keychain storage.
#
#   RATIONALE: 
#   Ensure that the iCloud keychain is used consistently with organizational requirements.
#
#   IMPACT: 
#   Not Applicable
#
#   AUDIT: 
#   Verify that a profile is installed that sets iCloud Keychain sync to your organization's 
#   settings.
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
        audit_allowCloudKeychainSync="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess').objectForKey('allowCloudKeychainSync').js
EOS
)"

        echo "<result>${audit_allowCloudKeychainSync}</result>"
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
