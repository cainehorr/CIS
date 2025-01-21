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
#   CIS Audit - Ensure XProtect Is Updated
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   XProtect is Apple's native signature-based antivirus technology. XProtect both finds and
#   blocks the execution of known malware. There are many AV and Endpoint Threat
#   Detection and Response (ETDR) tools available for Mac OS. The native Apple
#   provisioned tool looks for specific known malware and is completely integrated into the
#   OS. No matter what other tools are being used, XProtect should have the latest
#   signatures available.
#
#   RATIONALE: 
#   Apple creates signatures for known malware that actually affects Macs and that
#   knowledge should be leveraged.
#
#   IMPACT: 
#   Some organizations may have effective Mac OS anti-malware tools that XProtect
#   conflicts with.
#
#   AUDIT: 
#   Verify that XProtect is updated.
#
####################################################################################################
#
#   CHANGE CONTROL LOG
#
#   Version 1.0 - 2025-01-09
#       Initial script creation
#       Tested against macOS 14.7.1 - Sonoma
#
####################################################################################################

minimum_macOS_version_required="14"
maximum_macOS_version_required="15"

directory_path_to_plist="/Library/Application Support/XProtect"
path_to_plist="${directory_path_to_plist}/com.XProtect_updated.plist"

main(){
	# run_as_root
    # get_processor_type
    # get_os_version
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
    # if (( "${os_version}" > "${maximum_macOS_version_required}" )); then
        # echo "<result>CIS Audit has not been tested on macOS version greater than ${maximum_macOS_version_required}.x</result>"
    # elif [[ "${os_version}" = "14" ]] || [[ "${os_version}" = "15" ]]; then
        while [[ -z ${XProtect_latest_version} ]]; do
            loopcomplete=$((loopcomplete+1))
            XProtect_URL=$(/usr/bin/curl --max-time 240 -s https://swscan.apple.com/content/catalogs/others/index-15-14-13-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog | /usr/bin/grep -o 'https.*XProtectPlistConfigData.*pkm' | /usr/bin/tail -1)
            XProtect_latest_version=$(/usr/bin/curl --max-time 240 -s ${XProtect_URL} | /usr/bin/grep -o 'CFBundleShortVersionString[^ ]*' | /usr/bin/cut -d '"' -f 2)
            
echo "Lastest Version ${XProtect_latest_version}"

            if [[ ${loopcomplete} -ge 10 ]]; then
                exit
            elif [[ -z ${XProtect_latest_version} ]]; then
                sleep 10
            fi

        done

        XProtect_installed_version=$(/usr/bin/defaults read /Library/Apple/System/Library/CoreServices/XProtect.bundle/Contents/Info.plist CFBundleShortVersionString)

        if [ -d ${directory_path_to_plist} ]; then
            if [ -f ${path_to_plist} ];then
                XProtect_version_detection=$(/usr/bin/defaults read ${com_xprotect_updated_plist} ${XProtect_latest_version} 2> /dev/null)
            else 
                /usr/bin/sudo /usr/bin/touch ${path_to_plist}
                XProtect_version_detection=$(/usr/bin/defaults read ${com_xprotect_updated_plist} ${XProtect_latest_version} 2> /dev/null)
            fi
        else 
            /usr/bin/sudo /bin/mkdir ${directory_path_to_plist}
            /usr/bin/sudo /usr/bin/touch ${path_to_plist}
            XProtect_version_detection=$(/usr/bin/defaults read ${com_xprotect_updated_plist} ${XProtect_latest_version} 2> /dev/null)
        fi

        if [[ ${XProtect_latest_version} != ${XProtect_installed_version} ]] && [[ -z ${XProtect_version_detection} ]]; then
            /usr/bin/sudo /usr/bin/defaults write ${com_xprotect_updated_plist} ${XProtect_latest_version} $(/bin/date +%s)
            echo "<result>Update Pending</result>"
        elif [[ ${XProtect_latest_version} != ${XProtect_installed_version} ]] && [[ $(($(/bin/date +%s) - ${XProtect_version_detection})) -le "86400" ]]; then
            echo "<result>Update Pending</result>"
        elif [[ ${XProtect_latest_version} != ${XProtect_installed_version} ]]; then
            echo "<result>${XProtect_installed_version}</result>"
        else
            echo "<result>True</result>"
            # /bin/rm ${com_xprotect_updated_plist} 2> /dev/null
        fi
    # else
        # echo "<result>CIS Audit requires macOS version ${minimum_macOS_version_required}.x or higher</result>"
    # fi
}

main

exit 
