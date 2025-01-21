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
#   CIS Audit - Ensure Access to Audit Records Is Controlled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   The audit system on macOS writes important operational and security information that
#   can be both useful for an attacker and a place for an attacker to attempt to obfuscate
#   unwanted changes that were recorded. As part of defense-in-depth, the
#   /etc/security/audit_control configuration and the files in /var/audit should be
#   owned only by root with group wheel with read-only rights and no other access allowed.
#   macOS ACLs should not be used for these files.
#   
#   The default folder for storing logs is /var/audit, but it can be changed. This
#   recommendation will ensure that any target directory has appropriate access control in
#   place even if the target directory is not the default of /var/audit.
#
#   RATIONALE: 
#   Audit records should never be changed except by the system daemon posting events.
#   Records may be viewed or extracts manipulated, but the authoritative files should be
#   protected from unauthorized changes.
#
#   IMPACT: 
#   This control is only checking the default configuration to ensure that unwanted access to
#   audit records is not available.
#
#   AUDIT: 
#   Verify file access rights.
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
        # All output should be 0
        audit_audit_control_one="$(/usr/bin/sudo /bin/ls -n /etc/security/audit_control | /usr/bin/awk '{s+=$3} END {print s}')" 
        audit_audit_control_two="$(/usr/bin/sudo /bin/ls -n /etc/security/audit_control | /usr/bin/awk '{s+=$4} END {print s}')"
        audit_audit_control_three="$(/usr/bin/sudo /bin/ls -n /etc/security/audit_control | /usr/bin/awk '!/-r--r-----|current|total/{print $1}' | /usr/bin/wc -l | /usr/bin/tr -d ' ')"
        audit_audit_control_four="$(/usr/bin/sudo /bin/ls -n $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '{s+=$3} END {print s}')"
        audit_audit_control_five="$(/usr/bin/sudo /bin/ls -n $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '{s+=$4} END {print s}')"
        audit_audit_control_six="$(/usr/bin/sudo /bin/ls -n $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}') | /usr/bin/awk '!/-r--r-----|current|total/{print $1}' | /usr/bin/wc -l | /usr/bin/tr -d ' ')"

        if [ "${audit_audit_control_one}" = "0" ] && [ "${audit_audit_control_two}" = "0" ] && [ "${audit_audit_control_three}" = "0" ] && [ "${audit_audit_control_four}" = "0" ] && [ "${audit_audit_control_five}" = "0" ] && [ "${audit_audit_control_six}" = "0" ]; then
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
