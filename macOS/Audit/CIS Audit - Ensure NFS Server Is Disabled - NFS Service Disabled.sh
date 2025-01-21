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
#   CIS Audit - Ensure NFS Server Is Disabled - NFS Service Disabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   macOS can act as an NFS fileserver. NFS sharing could be enabled to allow someone
#   on another computer to mount shares and gain access to information from the user's
#   computer. File sharing from a user endpoint has long been considered questionable,
#   and Apple has removed that capability from the GUI. NFSD is still part of the Operating
#   System and can be easily turned on to export shares and provide remote connectivity to
#   an end-user computer.
#   
#   The etc/exports file contains the list of NFS shared directories. If the file exists, it is likely
#   that NFS sharing has been enabled in the past or may be available periodically. As an
#   additional check, the audit verifies that there is no /etc/exports file.
#
#   RATIONALE: 
#   File serving should not be done from a user desktop. Dedicated servers should be used.
#   Open ports make it easier to exploit the computer.
#
#   IMPACT: 
#   The nfs server is both a point of attack for the system and a means for unauthorized file
#   transfers.
#
#   AUDIT: 
#   Verify that the NFS fileserver service is not enabled.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2025-01-08
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
        audit_nfsd_disabled="$(/usr/bin/sudo /bin/launchctl list | /usr/bin/grep -c com.apple.nfsd)"

        if [ "${audit_nfsd_disabled}" = "0" ]; then
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
