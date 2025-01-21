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
#   CIS Audit - Ensure Install of macOS Updates Is Enabled - Automatically Install MacOS Updates
#
#   PROFILE APPLICABILITY: 
#   Level 
#
#   DESCRIPTION: 
#   Ensure that macOS updates are installed after they are available from Apple. This
#   setting enables macOS updates to be automatically installed. Some environments will
#   want to approve and test updates before they are delivered. It is best practice to test
#   first where updates can and have caused disruptions to operations. Automatic updates
#   should be turned off where changes are tightly controlled and there are mature testing
#   and approval processes. Automatic updates should not be turned off simply to allow the
#   administrator to contact users in order to verify installation. A dependable, repeatable
#   process involving a patch agent or remote management tool should be in place before
#   auto-updates are turned off.
#
#   RATIONALE: 
#   Patches need to be applied in a timely manner to reduce the risk of vulnerabilities being
#   exploited.
#
#   IMPACT: 
#   Unpatched software may be exploited.
#
#   AUDIT: 
#   Verify that macOS updates are automatically checked and installed.
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
        audit_AutomaticallyInstallMacOSUpdates="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.SoftwareUpdate').objectForKey('AutomaticallyInstallMacOSUpdates').js
EOS
)"

        echo "<result>${audit_AutomaticallyInstallMacOSUpdates}</result>"
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
