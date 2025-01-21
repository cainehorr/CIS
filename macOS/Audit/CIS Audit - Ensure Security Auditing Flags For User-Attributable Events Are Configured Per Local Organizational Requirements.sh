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
#   CIS Audit - Ensure Security Auditing Flags For User-Attributable Events Are Configured Per Local Organizational Requirements
#
#   PROFILE APPLICABILITY: 
#   Level 2
#
#   DESCRIPTION: 
#   Auditing is the capture and maintenance of information about security-related events.
#   Auditable events often depend on differing organizational requirements.
#
#   RATIONALE: 
#   Maintaining an audit trail of system activity logs can help identify configuration errors,
#   troubleshoot service disruptions, and analyze compromises or attacks that have
#   occurred, have begun, or are about to begin. Audit logs are necessary to provide a trail
#   of evidence in case the system or network is compromised.
#   
#   Depending on the governing authority, organizations can have vastly different auditing
#   requirements. In this control we have selected a minimal set of audit flags that should
#   be a part of any organizational requirements. The flags selected below may not
#   adequately meet organizational requirements for users of this benchmark. The auditing
#   checks for the flags proposed here will not impact additional flags that are selected.
#
#   IMPACT: 
#   N/A
#
#   AUDIT: 
#   Verify the Security Auditing Flags that are enabled.
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
        # The output should include the following flags:
        # • -fm - audit failed file attribute modification events
        # • ad - audit successful/failed administrative events
        # • -ex - audit failed program execution
        # • aa - audit all authorization and authentication events
        # • -fr - audit all failed read actions where enforcement stops a read of a file
        # • lo - audit successful/failed login/logout events
        # • -fw - audit all failed write actions where enforcement stopped a file write

        audit_security_audit_all_required_flags_are_enabled="$(/usr/bin/sudo /usr/bin/grep -e "^flags:" /etc/security/audit_control)"
        
        if [ "${audit_security_audit_all_required_flags_are_enabled}" = "flags:-fm,ad,-ex,aa,-fr,lo,-fw" ]; then
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
