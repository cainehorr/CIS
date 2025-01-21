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
#   CIS Audit - Audit History and Remove History Items - History Retention Profile Installed
#
#   PROFILE APPLICABILITY: 
#   Level 2
#
#   DESCRIPTION: 
#   Organizational management of user web browsing history is a challenge affected by
#   multiple facets. Organizations should decide whether to manage browser history and
#   how much history should be maintained.
#
#   RATIONALE: 
#   There are conflicting concerns in the retention of browser history. Unlimited retention:
#   
#   • Consumes disk space
#   • Is preferred by on-disk forensics teams
#   • Is user searchable for old visited pages
#   • Raises some user privacy concerns
#   • Has security concerns regarding retaining old links that may be stale or lead to
#   compromised pages, or pages with changes or inappropriate content
#   
#   Old browser history becomes stale and the use or misuse of the data can lead to
#   unwanted outcomes. Search engine results are maintained and often provide much
#   more relevant current information than old website visit information.
#
#   IMPACT: 
#   If old browsing history is not available, it will not be available to authorized or
#   unauthorized users. Some users may find old and even stale information useful.
#
#   AUDIT: 
#   Verify that a profile is installed that sets how long the history is kept in Safari.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2025-01-10
#       Initial script creation
#       Tested against macOS 14.7.1 - Sonoma
#
####################################################################################################

minimum_macOS_version_required="14"
maximum_macOS_version_required="15"

main(){
	run_as_root
    get_processor_type
    get_os_version
    acquire_logged_in_user
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

get_processor_type(){
    # processor_type="$(/usr/sbin/sysctl -n machdep.cpu.brand_string | /usr/bin/grep -e Intel | /usr/bin/awk '{print substr($1, 1, length($1)-3)}')"

    processor_type="$(/usr/sbin/sysctl -n machdep.cpu.brand_string)"

    if [[ ! -z $(/usr/sbin/sysctl -n machdep.cpu.brand_string | /usr/bin/grep -e Intel) ]]; then
        processor_type="Intel"
    elif [[ ! -z $(/usr/sbin/sysctl -n machdep.cpu.brand_string | /usr/bin/grep -e Apple) ]]; then
        processor_type="ARM"
    else 
        processor_type="UNKNOWN"
    fi
}

get_os_version(){
    os_version="$(/usr/bin/sudo /usr/bin/sw_vers | /usr/bin/awk -F: '/ProductVersion/ {print $2}' | /usr/bin/sed 's/^[[:space:]]*//g' | /usr/bin/cut -d. -f1)"
}

acquire_logged_in_user(){
    currentUser=$(/usr/bin/stat -f "%Su" "/dev/console")
}

audit(){
    if (( "${os_version}" > "${maximum_macOS_version_required}" )); then
        echo "<result>CIS Audit has not been tested on macOS version greater than ${maximum_macOS_version_required}.x</result>"
    elif [[ "${os_version}" = "14" ]] || [[ "${os_version}" = "15" ]]; then
        audit_safari_history_age_in_days="$(/usr/bin/sudo /usr/sbin/system_profiler SPConfigurationProfileDataType | /usr/bin/grep HistoryAgeInDaysLimit | /usr/bin/tr -d ' ')"

        if [ -z "${audit_safari_history_age_in_days}" ]; then
            echo "<result>false</result>"
        else 
            echo "<result>false</result>"
        fi
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
