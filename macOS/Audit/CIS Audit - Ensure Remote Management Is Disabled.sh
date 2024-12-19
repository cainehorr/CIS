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
#   CIS Audit - Ensure Remote Management Is Disabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION:
#   Remote Management is the client portion of Apple Remote Desktop (ARD). Remote
#   Management can be used by remote administrators to view the current screen, install
#   software, report on, and generally manage client Macs.
#   
#   The screen sharing options in Remote Management are identical to those in the Screen
#   Sharing section. In fact, only one of the two can be configured. If Remote Management
#   is used, refer to the Screen Sharing section above on issues regarding screen sharing.
#   
#   Remote Management should only be enabled when a Directory is in place to manage
#   the accounts with access. Computers will be available on port 5900 on a macOS
#   System and could accept connections from untrusted hosts depending on the
#   configuration, which is a major concern for mobile systems. As with other sharing
#   options, an open port even for authorized management functions can be attacked, and
#   both unauthorized access and Denial-of-Service vulnerabilities could be exploited. If
#   remote management is required, the pf firewall should restrict access only to known,
#   trusted management consoles. Remote management should not be used across the
#   Internet without the use of a VPN tunnel.
#   
#   RATIONALE:
#   Remote Management should only be enabled on trusted networks with strong user
#   controls present in a Directory system. Mobile devices without strict controls are
#   vulnerable to exploitation and monitoring.
#   
#   IMPACT:
#   Many organizations utilize ARD for client management.
# 
#   AUDIT:   
#   Verify that Remote Management is not enabled.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-17
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
        audit_ARDAgent="$(/usr/bin/pgrep -i ARDAgent)"

        if [ -z "${audit_ARDAgent}" ]; then
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
