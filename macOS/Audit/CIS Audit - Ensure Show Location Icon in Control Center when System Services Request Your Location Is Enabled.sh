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
#   CIS Audit - Ensure Show Location Icon in Control Center when System Services Request Your Location Is Enabled
#
#   PROFILE APPLICABILITY: 
#   Level 2
#
#   DESCRIPTION: 
#   This setting provides the user an understanding of the current status of Location
#   Services and which applications are using it.
#
#   RATIONALE: 
#   Apple has fully integrated location services into macOS. When user applications access
#   location an arrow is displayed next to the Control Center in the menu bar to give users
#   an indication when their location is being accessed. By default system services like time
#   zones, weather, travel times, geolocation, "Find my Mac," and advertising services do
#   not indicate the location is accessed.
#
#   Enabling the “Show location icon in the menu bar when System Services request your
#   location” setting will show an arrow in the control center when a system service
#   accesses the location. Although an indication that location was accessed, Control
#   Center will only say that it was accessed by "System Services" and not the individual
#   service. Looking in System Settings > Location Services > System Services > Details…
#   will expose exactly which system services have accessed Location Services in the last
#   24 hours. Third-party tools will be shown individually when they access location
#   services.
#   
#   IMPACT: 
#   Users may be provided visibility to a setting they cannot control if organizations control
#   Location Services globally by policy.
#
#   AUDIT: 
#   Verify the settings for location services icon to be in the menu bar
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-18
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
        audit_Location_Services_Menu_Bar_Icon="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.locationmenu').objectForKey('ShowSystemServices').js
EOS
)"

        if [ "${audit_Location_Services_Menu_Bar_Icon}" = "true" ]; then
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
