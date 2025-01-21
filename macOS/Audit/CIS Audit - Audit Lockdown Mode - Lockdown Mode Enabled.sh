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
#   CIS Audit - Audit Lockdown Mode - Lockdown Mode Enabled
#
#   PROFILE APPLICABILITY: 
#   Level 2
#
#   DESCRIPTION: 
#   Apple introduced Lockdown Mode as a security feature in their 2022 OS releases that
#   provides additional security protection Apple describes as extreme. Users and
#   organizations that suspect some users are targets of advanced attacks must consider
#   using this control.
#   
#   When lockdown mode is enabled, specific trusted websites can be excluded from
#   Lockdown protection if necessary.
#
#   RATIONALE: 
#   Lockdown Mode was designed by Apple as an aggressive approach to commonly
#   attacked OS features where additional controls could reduce the attack surface. IT
#   systems and devices, including their users, are subject to continuous exploit attempts.
#   Most of that activity is not from an advanced attacker and can be considered
#   background noise to a patched, hardened device. Advanced attackers are of more
#   concern and a risk review to understand organizational targets and use Lockdown Mode
#   where appropriate is necessary.
#
#   IMPACT: 
#   Lockdown Mode must be tested appropriately for real-world impact on users prior to
#   use. As a new feature there is not sufficient technical reporting on user impacts.
#
#   AUDIT: 
#   Verify the settings for Lockdown Mode.
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
        audit_LDMGlobalEnabled="$(/usr/bin/sudo -u ${currentUser} /usr/bin/defaults read .GlobalPreferences.plist LDMGlobalEnabled 2>/dev/null)"

        if [ "${audit_LDMGlobalEnabled}" = "1" ]; then
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
