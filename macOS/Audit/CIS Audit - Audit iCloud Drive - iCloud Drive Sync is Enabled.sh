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
#   CIS Audit - Audit iCloud Drive - iCloud Drive Sync is Enabled
#
#   PROFILE APPLICABILITY: 
#   Level 2
#
#   DESCRIPTION: 
#   iCloud Drive is Apple's storage solution for applications on both macOS and iOS to use the same 
#   files that are resident in Apple's cloud storage. The iCloud Drive folder is available much like
#   Dropbox, Microsoft OneDrive, or Google Drive. 
#
#   One of the concerns in public cloud storage is that proprietary data may be inappropriately 
#   stored in an end user's personal repository. Organizations that need specific controls on 
#   information should ensure that this service is turned off or the user knows what information 
#   must be stored on services that are approved for storage of controlled information.
#
#   RATIONALE: 
#   Organizations should review third party storage solutions pertaining to existing data
#   confidentiality and integrity requirements.
#
#   IMPACT: 
#   Users will not be able to use continuity on macOS to resume the use of newly composed but 
#   unsaved files.
#
#   AUDIT: 
#   Verify that a profile is installed that sets iCloud Drive sync to your organization's settings.
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

/usr/bin/sudosudo -u caine.horr /usr/bin/defaults read /Users/<username>/Library/Preferences/MobileMeAccounts | /usr/bin/grep -B 1 MOBILE_DOCUMENTS

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
        audit_allowCloudDocumentSync="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess').objectForKey('allowCloudDocumentSync').js
EOS
)"

        echo "<result>${audit_allowCloudDocumentSync}</result>"
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
