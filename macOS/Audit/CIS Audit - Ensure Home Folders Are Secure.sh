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
#   CIS Audit - Ensure Home Folders Are Secure
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   By default, macOS allows all valid users into the top level of every other user's home
#   folder and restricts access to the Apple default folders within. Another user on the same
#   system can see you have a "Documents" folder but cannot see inside it. This
#   configuration does work for personal file sharing but can expose user files to standard
#   accounts on the system.
#   
#   The best parallel for Enterprise environments is that everyone who has a Dropbox
#   account can see everything that is at the top level but can't see your pictures. Similarly
#   with macOS, users can see into every new Directory that is created because of the
#   default permissions.
#   
#   Home folders should be restricted to access only by the user. Sharing should be used
#   on dedicated servers or cloud instances that are managing access controls. Some
#   environments may encounter problems if execute rights are removed as well as read
#   and write. Either no access or execute only for group or others is acceptable.
#
#   RATIONALE: 
#   Allowing all users to view the top level of all networked users' home folder may not be
#   desirable since it may lead to the revelation of sensitive information.
#
#   IMPACT: 
#   If implemented, users will not be able to use the "Public" folders in other users' home
#   folders. "Public" folders with appropriate permissions would need to be set up in the
#   /Shared folder.
#
#   AUDIT: 
#   Ensure that all home folders are secure.
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
        audit_all_home_folders_are_secure="$(/usr/bin/sudo /usr/bin/find /System/Volumes/Data/Users -mindepth 1 -maxdepth 1 -type d -not -perm 700 | /usr/bin/grep -v "Shared" | /usr/bin/grep -v "Guest")"

        if [ -z "${audit_all_home_folders_are_secure}" ]; then
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
