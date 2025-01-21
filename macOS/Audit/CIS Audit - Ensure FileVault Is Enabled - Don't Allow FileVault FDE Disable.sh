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
#   CIS Audit - Ensure FileVault Is Enabled - Don't Allow FileVault FDE Disable
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   FileVault secures a system's data by automatically encrypting its boot volume and
#   requiring a password or recovery key to access it.
#   
#   FileVault should be used with a saved escrow key to ensure that the owner can decrypt
#   their data if the password is lost.
#   
#   FileVault may also be enabled using command line using the fdesetup command. To
#   use this functionality, consult the Der Flounder blog for more details (see link below
#   under References).
#
#   RATIONALE: 
#   Encrypting sensitive data minimizes the likelihood of unauthorized users gaining access
#   to it.
#
#   IMPACT: 
#   Mounting a FileVault encrypted volume from an alternate boot source will require a valid
#   password to decrypt it. Apple has also implemented an escalating policy for failed
#   passwords. To find out more about that, read here: Passcodes and passwords
#   
#   https://support.apple.com/guide/security/passcodes-and-passwords-sec20230a10d/1/web/1
#
#   AUDIT: 
#   Verify that FileVault dontAllowFDEDisable is set to "true"
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-26
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
        audit_dontAllowFDEDisable="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX').objectForKey('dontAllowFDEDisable').js
EOS
)"

        if [ "${audit_dontAllowFDEDisable}" = "true" ]; then
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
