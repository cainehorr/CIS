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
#   CIS Audit - Ensure All Apple-Provided Software Is Current - Last Full Successful Date
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   Software vendors release security patches and software updates for their products
#   when security vulnerabilities are discovered. There is no simple way to complete this
#   action without a network connection to an Apple software repository. Please ensure
#   appropriate access for this control. This check is only for what Apple provides through
#   software update.
#
#   Software updates should be run at minimum every 30 days. Run the following command
#   to verify when software update was previously run:
#
#   $ /usr/bin/sudo defaults read /Library/Preferences/com.apple.SoftwareUpdate | grep -e LastFullSuccessfulDate
#
#   The response should be in the last 30 days (Example): 
#       LastFullSuccessfulDate = "2020-07-30 12:45:25 +0000";
#
#   RATIONALE: 
#   It is important that these updates be applied in a timely manner to prevent unauthorized
#   persons from exploiting the identified vulnerabilities.
#
#   IMPACT: 
#   Installation of updates can be disruptive to the users especially if a restart is required.
#   Major updates need to be applied after creating an organizational patch policy. It is also
#   advised to run updates and forced restarts during system downtime and not while in active use.
#
#   AUDIT: 
#   Verify when software update was previously run.
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
        audit_LastFullSuccessfulDate="$(/usr/bin/sudo /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate | /usr/bin/grep -e LastFullSuccessfulDate | /usr/bin/sed 's/^[[:space:]]*//g' | /usr/bin/cut -d\" -f2)"
        
        echo "<result>${audit_LastFullSuccessfulDate}</result>"
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
