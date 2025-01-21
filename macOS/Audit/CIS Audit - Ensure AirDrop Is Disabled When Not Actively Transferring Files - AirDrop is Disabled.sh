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
#   CIS Audit - Ensure AirDrop Is Disabled When Not Actively Transferring Files - AirDrop is Disabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   AirDrop is Apple's built-in, on-demand, ad hoc file exchange system that is compatible
#   with both macOS and iOS. It uses Bluetooth LE for discovery that limits connectivity to
#   Mac or iOS users that are in close proximity. Depending on the setting, it allows
#   everyone or only Contacts to share files when they are near each other.
#
#   In many ways, this technology is far superior to the alternatives. The file transfer is done
#   over a TLS encrypted session, does not require any open ports that are required for file
#   sharing, does not leave file copies on email servers or within cloud storage, and allows
#   for the service to be mitigated so that only people already trusted and added to contacts
#   can interact with you.
#   
#   While there are positives to AirDrop, there are privacy concerns that could expose
#   personal information. For that reason, AirDrop should be disabled, and should only be
#   enabled when needed and disabled afterwards. The recommendation against enabling
#   the sharing is not based on any known lack of security in the protocol, but for specific
#   user operational concerns.
#
#   * If AirDrop is enabled, the Mac is advertising that a Mac is addressable on the
#   local network and open to either unwanted AirDrop upload requests or for a
#   negotiation on whether the remote user is in the user's contacts list. Neither
#   process is desirable.
#  
#   * In most known use cases, AirDrop use qualifies as ad hoc networking when it
#   involves Apple device users deciding to exchange a file using the service.
#   AirDrop can thus be enabled on the fly for that exchange.
#   For organizations concerned about any use of AirDrop because of Digital Loss
#   Prevention (DLP) monitoring on other protocols, JAMF has an article on reviewing
#   AirDrop logs.
#
#   Detecting outbound AirDrop transfers and logging them
#   https://www.jamf.com/blog/stop-potential-airdrop-transfer-data-leaks-with-jamf-protect/
#
#   RATIONALE: 
#   AirDrop can allow malicious files to be downloaded from unknown sources. Contacts Only limits 
#   may expose personal information to devices in the same area.
#
#   IMPACT: 
#   Disabling AirDrop can limit the ability to move files quickly over the network without using 
#   file shares.
#   
#   AUDIT: 
#   Verify that AirDrop is disabled.
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
    os_version="$(sudo /usr/bin/sw_vers | /usr/bin/awk -F: '/ProductVersion/ {print $2}' | /usr/bin/sed 's/^[[:space:]]*//g' | /usr/bin/cut -d. -f1)"
}

audit(){
    if (( "${os_version}" > "${maximum_macOS_version_required}" )); then
        echo "<result>CIS Audit has not been tested on macOS version greater than ${maximum_macOS_version_required}.x</result>"
    elif [[ "${os_version}" = "14" ]] || [[ "${os_version}" = "15" ]]; then
        audit_DisableAirDrop="$(/usr/bin/sudo -u ${currentUser} /usr/bin/defaults read com.apple.NetworkBrowser DisableAirDrop)"

        if [ "${audit_DisableAirDrop}" = "0" ]; then
            echo "<result>false</result>"
        else 
            echo "<result>true</result>"
        fi
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
