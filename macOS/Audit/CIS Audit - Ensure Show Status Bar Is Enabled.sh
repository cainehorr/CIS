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
#   CIS Audit - Ensure Show Status Bar Is Enabled - Profile Installed
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   The Status Bar in Safari shows the full URL of any link on hover. It protects the user
#   from visiting sites where the domain has been obfuscated by allowing the user to review
#   whether the link points to an unexpected location.
#
#   RATIONALE: 
#   Showing the Status Bar allows the user to review the full URL of hyperlinks.
#
#   IMPACT: 
#   The Status Bar is only visible at the very bottom of the Web page when a hyperlink is
#   hovered over. There should be no noticeable impact.
#
#   AUDIT: 
#   Verify that a profile is installed that enables the status bar in Safari.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2025-01-10
#       Initial script creation
#       Tested against macOS 14.7.1 - Sonoma
#
####################################################################################################

minimum_macOS_version_required="14"
maximum_macOS_version_required="15"

main(){
	run_as_root
    get_processor_type
    get_os_version
    acquire_logged_in_user
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

get_processor_type(){
    # processor_type="$(/usr/sbin/sysctl -n machdep.cpu.brand_string | /usr/bin/grep -e Intel | /usr/bin/awk '{print substr($1, 1, length($1)-3)}')"

    processor_type="$(/usr/sbin/sysctl -n machdep.cpu.brand_string)"

    if [[ ! -z $(/usr/sbin/sysctl -n machdep.cpu.brand_string | /usr/bin/grep -e Intel) ]]; then
        processor_type="Intel"
    elif [[ ! -z $(/usr/sbin/sysctl -n machdep.cpu.brand_string | /usr/bin/grep -e Apple) ]]; then
        processor_type="ARM"
    else 
        processor_type="UNKNOWN"
    fi
}

get_os_version(){
    os_version="$(/usr/bin/sudo /usr/bin/sw_vers | /usr/bin/awk -F: '/ProductVersion/ {print $2}' | /usr/bin/sed 's/^[[:space:]]*//g' | /usr/bin/cut -d. -f1)"
}

acquire_logged_in_user(){
    currentUser=$(/usr/bin/stat -f "%Su" "/dev/console")
}

audit(){
    if (( "${os_version}" > "${maximum_macOS_version_required}" )); then
        echo "<result>CIS Audit has not been tested on macOS version greater than ${maximum_macOS_version_required}.x</result>"
    elif [[ "${os_version}" = "14" ]] || [[ "${os_version}" = "15" ]]; then
        audit_safari_ShowOverlayStatusBar="$(/usr/bin/sudo /usr/sbin/system_profiler SPConfigurationProfileDataType | /usr/bin/grep ShowOverlayStatusBar | /usr/bin/tr -d ' ')"

        if [ "${audit_safari_ShowOverlayStatusBar}" = "ShowOverlayStatusBar = 1;" ]; then
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
