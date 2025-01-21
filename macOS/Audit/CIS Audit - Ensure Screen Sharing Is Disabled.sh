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
#   CIS Audit - Ensure Screen Sharing Is Disabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   Screen Sharing allows a computer to connect to another computer on a network and
#   display the computer’s screen. While sharing the computer’s screen, the user can
#   control what happens on that computer, such as opening documents or applications,
#   opening, moving, or closing windows, and even shutting down the computer.
#
#   While mature administration and management does not use graphical connections for
#   standard maintenance, most help desks have capabilities to assist users in performing
#   their work when they have technical issues and need support. Help desks use graphical
#   remote tools to understand what the user sees and assist them so they can get back to
#   work. For MacOS, some of these remote capabilities can use Apple's OS tools. Control
#   is therefore not meant to prohibit the use of a just-in-time graphical view from authorized
#   personnel with authentication controls. Sharing should not be enabled except in narrow
#   windows when help desk support is required.
#
#   Screen Sharing on macOS can allow the use of the insecure VNC protocol. VNC is a
#   clear text protocol that should not be used on macOS. 
#
#   RATIONALE: 
#   Disabling Screen Sharing mitigates the risk of remote connections being made without
#   the user of the console knowing that they are sharing the computer.
#
#   IMPACT: 
#   Help desks may require the periodic use of a graphical connection mechanism to assist
#   users. Any support that relies on native MacOS components will not work unless a
#   scripted solution to enable and disable sharing is used, as necessary.
#
#   AUDIT: 
#   Verify that Screen Sharing is not enabled
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
        audit_screensharing="$(/usr/bin/sudo /bin/launchctl list | /usr/bin/grep -E com.apple.screensharing$)"

        if [ -z "${audit_screensharing}" ]; then
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
