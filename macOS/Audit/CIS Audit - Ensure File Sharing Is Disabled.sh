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
#   CIS Audit - Ensure File Sharing Is Disabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   File sharing from a user workstation creates additional risks, such as:
#   
#    • Open ports are created that can be probed and attacked
#   
#    • Passwords are attached to user accounts for access that may be exposed and
#   endanger other parts of the organizational environment, including directory
#   accounts
#   
#    • Increased complexity makes security more difficult and may expose additional
#   attack vectors
#   
#   Apple's File Sharing uses the Server Message Block (SMB) protocol to share to other
#   computers that can mount SMB shares. This includes other macOS computers.
#   
#   Apple warns that SMB sharing stored passwords is less secure, and anyone with
#   system access can gain access to the password for that account. When sharing with
#   SMB, each user accessing the Mac must have SMB enabled. Storing passwords,
#   especially copies of valid directory passwords, decreases security for the directory
#   account and should not be used.
#
#   RATIONALE: 
#   By disabling File Sharing, the remote attack surface and risk of unauthorized access to
#   files stored on the system is reduced.
#
#   IMPACT: 
#   File Sharing can be used to share documents with other users, but hardened servers
#   should be used rather than user endpoints. Turning on File Sharing increases the
#   visibility and attack surface of a system unnecessarily.
#
#   AUDIT: 
#   Verify that File Sharing is not enabled.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2023-12-17
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
        audit_smbd="$(/usr/bin/sudo /bin/launchctl list | /usr/bin/grep -c com.apple.smbd)"

        if [ "${audit_smbd}" = "0" ]; then
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
