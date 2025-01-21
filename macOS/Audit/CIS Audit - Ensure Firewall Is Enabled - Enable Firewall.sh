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
#   CIS Audit - Ensure Firewall Is Enabled - Enable Firewall
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   A firewall is a piece of software that blocks unwanted incoming connections to a system.
#   The socketfilter Firewall is what is used when the Firewall is turned on in the Security &
#   Privacy Preference Pane. Logging is required to appropriately monitor what access is
#   allowed and denied. The logs can be viewed in the macOS Unified Logs.
#
#   https://www.mandiant.com/resources/blog/reviewing-macos-unified-logs
#
#   In previous versions of macOS (prior to macOS 15 Sequoia) there was an additional
#   step to turn on firewall logging after enabling the firewall. As of macOS 15 logging is
#   turned on automatically without user interaction. The logging recommendation has been
#   removed in the macOS 15 benchmark and will not be included going forward. If your
#   organization is looking for more detailed information about network security, you will
#   need a third-party solution.
#
#   RATIONALE: 
#   A firewall minimizes the threat of unauthorized users gaining access to your system
#   while connected to a network or the Internet.
#
#   IMPACT: 
#   The firewall may block legitimate traffic. Applications that are unsigned will require
#   special handling.
#
#   AUDIT: 
#   Verify that the firewall is enabled.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-12
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
        audit_EnableFirewall="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.security.firewall').objectForKey('EnableFirewall').js
EOS
)"

        echo "<result>${audit_EnableFirewall}</result>"
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
