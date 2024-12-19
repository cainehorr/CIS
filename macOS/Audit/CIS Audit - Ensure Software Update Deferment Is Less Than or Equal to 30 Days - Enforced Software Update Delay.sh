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
#   CIS Audit - Ensure Software Update Deferment Is Less Than or Equal to 30 Days - Enforced Software Update Delay
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   Apple provides the capability to manage software updates on Apple devices through
#   mobile device management. Part of those capabilities permit organizations to defer
#   software updates and allow for testing. Many organizations have specialized software
#   and configurations that may be negatively impacted by Apple updates. If software
#   updates are deferred, they should not be deferred for more than 30 days. This control
#   only verifies that deferred software updates are not deferred for more than 30 days.
#
#   RATIONALE: 
#   Apple software updates almost always include security updates. Attackers evaluate
#   updates to create exploit code in order to attack unpatched systems. The longer a
#   system remains unpatched, the greater an exploit possibility exists in which there are
#   publicly reported vulnerabilities.
#
#   IMPACT: 
#   Some organizations may need more than 30 days to evaluate the impact of software updates.
#
#   AUDIT: 
#   Verify that a profile is installed that defers software updates to at most 30 days.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-11
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
        audit_enforcedSoftwareUpdateDelay="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess').objectForKey('enforcedSoftwareUpdateDelay').js
EOS
)"

        echo "<result>${audit_enforcedSoftwareUpdateDelay}</result>"
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
