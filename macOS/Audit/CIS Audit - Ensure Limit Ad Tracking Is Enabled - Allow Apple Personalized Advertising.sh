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
#   CIS Audit - Ensure Limit Ad Tracking Is Enabled - Allow Apple Personalized Advertising
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   Apple provides a framework that allows advertisers to target Apple users and end-users
#   with advertisements. While many people prefer to see advertising that is relevant to
#   them and their interests, the detailed information that is collected, correlated, and
#   available to advertisers in repositories via data mining is often disconcerting. This
#   information is valuable to both advertisers and attackers, and has been used with other
#   metadata to reveal users' identities.
#   
#   Organizations should manage advertising settings on computers rather than allow users
#   to configure the settings.
#   
#   Apple Information
#   https://support.apple.com/en-us/HT205223
#   
#   Ad tracking should be limited on 10.15 and prior.
#
#   RATIONALE: 
#   Organizations should manage user privacy settings on managed devices to align with
#   organizational policies and user data protection requirements.
#
#   IMPACT: 
#   Uses will see generic advertising rather than targeted advertising. Apple warns that this
#   will reduce the number of relevant ads.
#
#   AUDIT: 
#   Verify that limited ad tracking is enabled.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-26
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
        audit_allowApplePersonalizedAdvertising="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess').objectForKey('allowApplePersonalizedAdvertising').js
EOS
)"

        if [ "${audit_allowApplePersonalizedAdvertising}" = "false" ]; then
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
