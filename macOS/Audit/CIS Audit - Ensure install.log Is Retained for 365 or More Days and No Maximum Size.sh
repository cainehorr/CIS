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
#   CIS Audit - Ensure install.log Is Retained for 365 or More Days and No Maximum Size
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   macOS writes information pertaining to system-related events to the file
#   /var/log/install.log and has a configurable retention policy for this file. The default
#   logging setting limits the file size of the logs and the maximum size for all logs. The
#   default allows for an errant application to fill the log files and does not enforce sufficient
#   log retention. The Benchmark recommends a value based on standard use cases. The
#   value should align with local requirements within the organization.
#   
#   The default value has an "all_max" file limitation, no reference to a minimum retention,
#   and a less precise rotation argument.
#   
#   The all_max flag control will remove old log entries based only on the size of the log
#   files. Log size can vary widely depending on how verbose installing applications are in
#   their log entries. The decision here is to ensure that logs go back a year, and depending
#   on the applications a size restriction could compromise the ability to store a full year.
#   
#   While this Benchmark is not scoring for a rotation flag, the default rotation is sequential
#   rather than using a timestamp. Auditors may prefer timestamps in order to simply review
#   specific dates where event information is desired.
#   
#   Please review the File Rotation section in the man page for more information.
#   
#   man asl.conf
#   
#   • The maximum file size limitation string should be removed "all_max="
#   • An organization-appropriate retention should be added "ttl="
#   • The rotation should be set with timestamps "rotate=utc" or "rotate=local"
#
#   RATIONALE: 
#   Archiving and retaining install.log for at least a year is beneficial in the event of an
#   incident as it will allow the user to view the various changes to the system along with the
#   date and time they occurred.
#
#   IMPACT: 
#   Without log files system maintenance and security, forensics cannot be properly
#   performed.
#
#   WARNING: By allowing "No max size", there is the potential risk that log files could potentially
#   consume the available hard drive space.
#
#   AUDIT: 
#   Verify that log files are retained for at least 365 days with no maximum size.
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
        audit_log_files_ttl="$(/usr/bin/sudo /usr/bin/grep -i 'ttl' /etc/asl/com.apple.install | /usr/bin/grep -o 'ttl=365')"    # The output must include ttl≥365
        audit_log_files_max_size="$(/usr/bin/sudo /usr/bin/grep -i 'all_max=' /etc/asl/com.apple.install | /usr/bin/grep -o 'all_max=')"  # No results should be returned.

        if [ "${audit_log_files_ttl}" = "ttl=365" ] && [ -z "${audit_log_files_max_size}" ]; then
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
        audit_security_audit_flags_are_enabled_fw="$(/usr/bin/sudo /usr/bin/grep -e "^flags:" /etc/security/audit_control | /usr/bin/grep -o 'fw')"