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
#   CIS Audit - Ensure iCloud Drive Document and Desktop Sync Is Disabled - Allow Cloud Desktop and Documents
#
#   PROFILE APPLICABILITY: 
#   Level 2
#
#   DESCRIPTION: 
#   With macOS 10.12, Apple introduced the capability to have a user's Desktop and
#   Documents folders automatically synchronize to the user's iCloud Drive, provided they
#   have enough room purchased through Apple on their iCloud Drive. This capability
#   mirrors what Microsoft is doing with the use of OneDrive and Office 365. There are
#   concerns with using this capability.
#
#   The storage space that Apple provides for free is used by users with iCloud mail, all of a
#   user's Photo Library created with the ever larger Multi-Pixel iPhone cameras, and all
#   iOS Backups. Adding a synchronization capability for users who have files going back a
#   decade or more, storage may be tight using the free 5GB provided without purchasing
#   much larger storage capacity from Apple. Users with multiple computers running 10.12
#   and above with unique content on each will have issues as well.
#
#   Enterprise users may not be allowed to store Enterprise information in a third-party
#   public cloud. In previous implementations, such as iCloud Drive or DropBox, the user
#   selected what files were synchronized even if there were no other controls. The new
#   feature synchronizes all files in a folder widely used to put working files.
#
#   The automatic synchronization of all files in a user's Desktop and Documents folders
#   should be disabled.
#
#   https://derflounder.wordpress.com/2016/09/23/icloud-desktop-and-documents-in-macos-sierra-the-good-the-bad-and-the-ugly/
#
#   RATIONALE: 
#   Automated Document synchronization should be planned and controlled to approved storage.
#
#   IMPACT: 
#   Users will not be able to use iCloud for the automatic sync of the Desktop and 
#   Documents folders.
#
#   AUDIT: 
#   Verify that a profile is installed that disables iCloud Document and Desktop Sync.
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
        audit_allowCloudDesktopAndDocuments="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess').objectForKey('allowCloudDesktopAndDocuments').js
EOS
)"

        echo "<result>${audit_allowCloudDesktopAndDocuments}</result>"
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
