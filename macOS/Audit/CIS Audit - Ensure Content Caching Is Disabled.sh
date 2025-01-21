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
#   CIS Audit - Ensure Content Caching Is Disabled
#
#   PROFILE APPLICABILITY: 
#   Level 2
#
#   DESCRIPTION: 
#   Starting with 10.13 (macOS High Sierra), Apple introduced a service to make it easier to
#   deploy data from Apple, including software updates, where there are bandwidth
#   constraints to the Internet and fewer constraints or greater bandwidth exist on the local
#   subnet. This capability can be very valuable for organizations that have throttled and
#   possibly metered Internet connections. In heterogeneous enterprise networks with
#   multiple subnets, the effectiveness of this capability would be determined by how many
#   Macs were on each subnet at the time new, large updates were made available
#   upstream. This capability requires the use of mac OS clients as P2P nodes for updated
#   Apple content. Unless there is a business requirement to manage operational Internet
#   connectivity and bandwidth, user endpoints should not store content and act as a
#   cluster to provision data.
#   
#   Content types supported by Content Caching in macOS:
#   https://support.apple.com/en-us/HT204675
#
#   RATIONALE: 
#   The main use case for Mac computers is as mobile user endpoints. P2P sharing
#   services should not be enabled on laptops that are using untrusted networks. Content
#   Caching can allow a computer to be a server for local nodes on an untrusted network.
#   While there are certainly logical controls that could be used to mitigate risk, they add to
#   the management complexity. Since the value of the service is in specific use cases,
#   organizations with the use case described above can accept risk as necessary.
#
#   IMPACT: 
#   This setting will adversely affect bandwidth usage between local subnets and the
#   Internet.
#
#   AUDIT: 
#   Verify that Content Caching is not enabled.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2024-12-17
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
        audit_allowContentCaching="$(/usr/bin/sudo /usr/bin/osascript -l JavaScript << EOS
function run() {
let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.AssetCache').objectForKey('Activated'))
let pref2 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess').objectForKey('allowContentCaching'))
if ( ( pref1 == 0 ) || ( pref2 == 0 ) ) {
return("true")
} else {
return("false")
}
}
EOS
)"

        echo "<result>${audit_allowContentCaching}</result>"
    else
        echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    fi
}

main

exit
