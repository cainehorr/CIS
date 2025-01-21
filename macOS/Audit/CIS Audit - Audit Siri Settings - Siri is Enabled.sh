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
#   CIS Audit - Audit Siri Settings - Siri is Enabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   With macOS 10.12 Sierra, Apple has introduced Siri from iOS to macOS. While there
#   are data spillage concerns with the use of data-gathering personal assistant software,
#   the risk here does not seem greater in sending queries to Apple through Siri than in
#   sending search terms in a browser to Google or Microsoft. While it is possible that Siri
#   will be used for local actions rather than Internet searches, Siri could, in theory, tell
#   Apple about confidential Programs and Projects that should not be revealed. This
#   appears to be a usage edge case.
#   
#   In cases where sensitive or protected data is processed and Siri could expose that
#   information through assisting a user in navigating their machine, it should be disabled.
#   Siri does need to phone home to Apple, so it should not be available from air-gapped
#   networks as part of its requirements.
#   
#   Most of the use case data published has shown that Siri is a tremendous time saver on
#   iOS where multiple screens and menus need to be navigated through. Information like
#   sports scores, weather, movie times, and simple to-do items on existing calendars can
#   be easily found with Siri. None of the standard use cases should be more risky than
#   already approved activity.
#   
#   For information on Apple's privacy policy for Siri, click here.
#   https://support.apple.com/en-us/HT210657
#
#   RATIONALE: 
#   Where "normal" user activity is already limited, Siri use should be controlled as well.
#
#   IMPACT: 
#   N/A
#
#   AUDIT: 
#   Verify the Siri settings.
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
        audit_Siri_Enabled="$(/usr/bin/sudo -u ${currentUser} /usr/bin/defaults read com.apple.assistant.support.plist 'Assistant Enabled')"

        if [ "${audit_Siri_Enabled}" = "1" ]; then
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
