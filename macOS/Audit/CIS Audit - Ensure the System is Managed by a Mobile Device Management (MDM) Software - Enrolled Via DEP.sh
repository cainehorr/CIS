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
#   CIS Audit - Ensure the System is Managed by a Mobile Device Management (MDM) Software - Enrolled Via DEP
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   Apple provides the capability to manage macOS, iOS, and iPadOS using Mobile Device
#   Management (MDM). Profiles are used to configure devices to enforce security controls
#   as well as to configure the devices for authorized access. Many security controls
#   available on Apple devices are only available through the use of profile settings using
#   MDM. This capability is also misused by attackers who have added rogue profiles to the
#   list of unwanted software and fake software updates to induce users to approve the
#   installation of malicious content. Organizations should have Mobile Device Management
#   software in place to harden organizationally managed devices and take advantage of
#   additional Apple controls, as well as to make the devices more resistant to attackers
#   enticing users to install unwanted content from rogue MDMs.
#
#   RATIONALE: 
#   Mobile Device Management is the preferred Apple method to manage Apple devices.
#   Some capability in this technology is a requirement for the enforcement of some
#   controls. Users with managed devices should be trained and familiar with authorized
#   content provided through the organization's MDM.
#
#   IMPACT: 
#   An MDM is yet another additional tool that requires technically adept personnel to
#   manage correctly. In theory, proper use of an MDM can make services provisioning
#   simpler with configuration profiles to reach authorized services.
#
#   AUDIT: 
#   Verify the system is enrolled in a Mobile Device Management software.
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
        audit_Enrolled_via_DEP="$(sudo /usr/bin/profiles status -type enrollment | /usr/bin/awk -F: '/Enrolled via DEP/ {print $2}' | /usr/bin/grep -c "Yes")"

        if [ "${audit_Enrolled_via_DEP}" = "1" ]; then
            audit_Enrolled_via_DEP="true"
        else
            audit_Enrolled_via_DEP="false"
        fi

        echo "<result>${audit_Enrolled_via_DEP}</result>"
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
