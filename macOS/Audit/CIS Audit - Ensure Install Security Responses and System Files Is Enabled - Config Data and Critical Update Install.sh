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
#   CIS Audit - Ensure Install Security Responses and System Files Is Enabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   Ensure that system and security updates are installed after they are available from
#   Apple. This setting enables definition updates for XProtect and Gatekeeper. With this
#   setting in place, new malware and adware that Apple has added to the list of malware or
#   untrusted software will not execute. These updates do not require reboots or end user
#   admin rights.
#
#   Apple has introduced a security feature that allows for smaller downloads and the
#   installation of security updates when a reboot is not required. This feature is only
#   available when the last regular update has already been applied. This feature
#   emphasizes that a Mac must be up-to-date on patches so that Apple's security tools can
#   be used to quickly patch when a rapid response is necessary.
#
#   RATIONALE: 
#   Patches need to be applied in a timely manner to reduce the risk of vulnerabilities being
#   exploited.
#
#   IMPACT: 
#   Unpatched software may be exploited.
#
#   AUDIT: 
#   Verify that system data files and security updates install automatically.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-11
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
        audit_ConfigDataInstall_and_CriticalUpdateInstall="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
function run() {
    let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.SoftwareUpdate').objectForKey('ConfigDataInstall'))
    let pref2 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.SoftwareUpdate').objectForKey('CriticalUpdateInstall'))
    if ( pref1 == 1 && pref2 == 1 ) {
        return("true")
    } else {
        return("false")
    }
}
EOS
)"

        echo "<result>${audit_ConfigDataInstall_and_CriticalUpdateInstall}</result>"
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
