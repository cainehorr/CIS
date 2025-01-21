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
#   CIS Audit - Ensure Security Auditing Is Enabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   macOS's audit facility, auditd, receives notifications from the kernel when certain
#   system calls, such as open, fork, and exit, are made. These notifications are captured
#   and written to an audit log.
#   
#   Apple has deprecated auditd as of macOS 11.0 Big Sur. In macOS 14.0 Sonoma it is
#   no longer enabled by default and it is suggested to use an application that integrates
#   with the EndpointSecurity API. These applications are third party and not built into the
#   macOS. Until auditd is removed from macOS completely, running the binary is the best
#   way to collect logging in macOS and the only one that is part of the OS.
#
#   RATIONALE: 
#   Logs generated by auditd may be useful when investigating a security incident as they
#   may help reveal the vulnerable application and the actions taken by a malicious actor.
#
#   IMPACT: 
#   N/A
#
#   AUDIT: 
#   Verify that security auditing is enabled.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2025-01-06
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
    os_version="$(/usr/bin/sudo /usr/bin/sw_vers | /usr/bin/awk -F: '/ProductVersion/ {print $2}' | /usr/bin/sed 's/^[[:space:]]*//g' | /usr/bin/cut -d. -f1)"
}

audit(){
    if (( "${os_version}" > "${maximum_macOS_version_required}" )); then
        echo "<result>CIS Audit has not been tested on macOS version greater than ${maximum_macOS_version_required}.x</result>"
    elif [[ "${os_version}" = "14" ]] || [[ "${os_version}" = "15" ]]; then
        audit_auditing_is_enabled="$(/usr/bin/sudo /bin/launchctl list | /usr/bin/grep -i auditd)"

        if [ ! -z "${audit_auditing_is_enabled}" ]; then
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