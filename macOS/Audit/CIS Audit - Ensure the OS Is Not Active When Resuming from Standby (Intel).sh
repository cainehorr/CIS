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
#   CIS Audit - Ensure the OS Is Not Active When Resuming from Standby (Intel)
#
#   PROFILE APPLICABILITY: 
#   Level 2
#
#   DESCRIPTION: 
#   In order to use a computer with Full Disk Encryption (FDE), macOS must keep
#   encryption keys in memory to allow the use of the disk that has been FileVault
#   protected. The storage volume has been unlocked and acts as if it were not encrypted.
#   When the system is not in use, the volume is protected through encryption. When the
#   system is sleeping and available to quickly resume, the encryption keys remain in
#   memory.
#   
#   https://www.helpnetsecurity.com/2018/08/20/laptop-sleep-security/
#   
#   Mac systems should be set to hibernate after sleeping for a risk-acceptable time period.
#   The default value for "standbydelay" is three hours (10800 seconds). This value is likely
#   appropriate for most desktops. If Mac desktops are deployed in unmonitored, less
#   physically secure areas with confidential data, this value might be adjusted. The
#   desktop would have to retain power, however, so that the running OS or physical RAM
#   could be attacked.
#   
#   MacBooks should be set so that the standbydelay is 15 minutes (900 seconds) or less.
#   This setting should allow laptop users in most cases to stay within physically secured
#   areas while going to a conference room, auditorium, or other internal location without
#   having to unlock the encryption. When the user goes home at night, the laptop will auto-
#   hibernate after 15 minutes and require the FileVault password to unlock prior to logging
#   back into the system when it resumes.
#   
#   MacBooks should also be set to a hibernate mode that removes power from the RAM.
#   This will stop the possibility of cold boot attacks on the system.
#   
#   Macs running Apple silicon chips, rather than Intel chips, do not require the same
#   configuration as Intel-based Macs.
#
#   RATIONALE: 
#   To mitigate the risk of data loss, the system should power down and lock the encrypted
#   drive after a specified time. Laptops should hibernate 15 minutes or less after sleeping.
#
#   IMPACT: 
#   The laptop will take additional time to resume normal operation if only sleeping rather
#   than hibernating.
#   
#   Setting hibernatemode to 25 will disable the "always-on" feature of the Apple Silicon
#   Macs.
#
#   AUDIT: 
#   Verify the hibernation settings.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-27
#       Initial script creation
#       Tested against macOS 15.1.1 - Sequoia
#       Tested against macOS 14.7.1 - Sonoma
#
####################################################################################################

minimum_macOS_version_required="14"
maximum_macOS_version_required="15"

main(){
	run_as_root
    acquire_logged_in_user
    get_os_version
    get_processor_type
	# audit
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

get_processor_type_method_02(){
    processor_type="$(/usr/sbin/sysctl -n machdep.cpu.brand_string)"

    echo ${processor_type}

    if [[ ! -z $(/usr/sbin/sysctl -n machdep.cpu.brand_string | /usr/bin/grep -e Intel) ]]; then
        processor_type="Intel"
        echo ${processor_type}
    elif [[ ! -z $(/usr/sbin/sysctl -n machdep.cpu.brand_string | /usr/bin/grep -e Apple) ]]; then
        processor_type="ARM"
        echo ${processor_type}
    else 
        processor_type="UNKNOWN"
        echo ${processor_type}
    fi
}

audit(){
    if (( "${os_version}" > "${maximum_macOS_version_required}" )); then
        echo "<result>CIS Audit has not been tested on macOS version greater than ${maximum_macOS_version_required}.x</result>"
    elif [[ "${os_version}" = "14" ]] || [[ "${os_version}" = "15" ]]; then
        if [ "${processor_type}" = "Intel" ]; then
            audit_="$()"

            if [ "${audit_}" = "true" ]; then
                echo "<result>true</result>"
            else 
                echo "<result>false</result>"
            fi
        else 
           echo "<result>Processor Is Not Intel</result>"
        fi
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit

/usr/bin/sudo /usr/sbin/system_profiler SPHardwareDataType | /usr/bin/grep -e MacBook
/usr/bin/sudo /usr/bin/pmset -b -g | /usr/bin/grep -e standby
/usr/bin/sudo /usr/bin/pmset -b -g | /usr/bin/grep hibernatemode
