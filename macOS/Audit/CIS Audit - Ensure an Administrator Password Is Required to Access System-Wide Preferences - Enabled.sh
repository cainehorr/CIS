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
#   CIS Audit - Ensure an Administrator Password Is Required to Access System-Wide Preferences - Enabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   System Preferences controls system and user settings on a macOS Computer. System
#   Preferences allows the user to tailor their experience on the computer as well as
#   allowing the System Administrator to configure global security settings. Some of the
#   settings should only be altered by the person responsible for the computer.
#
#   RATIONALE: 
#   By requiring a password to unlock system-wide System Preferences, the risk of a user
#   changing configurations that affect the entire system is mitigated and requires an admin
#   user to re-authenticate to make changes.
#
#   IMPACT: 
#   Users will need to enter their password to unlock some additional preference panes that
#   are unlocked by default like Network, Startup and Printers & Scanners.
#
#   AUDIT: 
#   Verify that an administrator password is required to access system-wide preferences.
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
        audit_Admin_Password_Required_For_System_Wide_Preferences="$()"

        authDBs=("system.preferences" "system.preferences.energysaver" "system.preferences.network" "system.preferences.printing" "system.preferences.sharing" "system.preferences.softwareupdate" "system.preferences.startupdisk" "system.preferences.timemachine")

        audit_Admin_Password_Required_For_System_Wide_Preferences="1"

        for section in ${authDBs[@]}; do
            if [[ $(/usr/bin/security -q authorizationdb read "$section" | /usr/bin/xmllint -xpath 'name(//*[contains(text(), "shared")]/following-sibling::*[1])' -) != "false" ]]; then
                audit_Admin_Password_Required_For_System_Wide_Preferences="0"
            fi

            if [[ $(security -q authorizationdb read "$section" | /usr/bin/xmllint -xpath '//*[contains(text(), "group")]/following-sibling::*[1]/text()' - ) != "admin" ]]; then
                audit_Admin_Password_Required_For_System_Wide_Preferences="0"
            fi

            if [[ $(/usr/bin/security -q authorizationdb read "$section" | /usr/bin/xmllint -xpath 'name(//*[contains(text(), "authenticate-user")]/following-sibling::*[1])' -) != "true" ]]; then 
                audit_Admin_Password_Required_For_System_Wide_Preferences="0"
            fi

            if [[ $(/usr/bin/security -q authorizationdb read "$section" | /usr/bin/xmllint -xpath 'name(//*[contains(text(), "session-owner")]/following-sibling::*[1])' -) != "false" ]]; then
                audit_Admin_Password_Required_For_System_Wide_Preferences="0"
            fi
        done

        if [ "${audit_Admin_Password_Required_For_System_Wide_Preferences}" = "1" ]; then
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
