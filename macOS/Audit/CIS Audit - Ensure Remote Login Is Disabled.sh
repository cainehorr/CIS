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
#   CIS Audit - Ensure Remote Login Is Disabled
#
#   PROFILE APPLICABILITY: 
#   Level 1
#
#   DESCRIPTION: 
#   Remote Login allows an interactive terminal connection to a computer.
#
#   RATIONALE: 
#   Disabling Remote Login mitigates the risk of an unauthorized person gaining access to
#   the system via Secure Shell (SSH). While SSH is an industry standard to connect to
#   posix servers, the scope of the benchmark is for Apple macOS clients, not servers.
#   
#   macOS does have an IP-based firewall available (pf, ipfw has been deprecated) that is
#   not enabled or configured. There are more details and links in the Network sub-section.
#   macOS no longer has TCP Wrappers support built in and does not have strong Brute-
#   Force password guessing mitigations, or frequent patching of openssh by Apple. Since
#   most macOS computers are mobile workstations, managing IP-based firewall rules on
#   mobile devices can be very resource intensive. All of these factors can be parts of
#   running a hardened SSH server.
#
#   IMPACT: 
#   The SSH server built into macOS should not be enabled on a standard user computer,
#   particularly one that changes locations and IP addresses. A standard user that runs
#   local applications, including email, web browser, and productivity tools, should not use
#   the same device as a server. There are Enterprise management toolsets that do utilize
#   SSH. If they are in use, the computer should be locked down to only respond to known,
#   trusted IP addresses and appropriate administrator service accounts.

#   For macOS computers that are being used for specialized functions, there are several
#   options to harden the SSH server to protect against unauthorized access, including
#   brute force attacks. There are some basic criteria that need to be considered:

#    • Do not open an SSH server to the internet without controls in place to mitigate
#   SSH brute force attacks. This is particularly important for systems bound to
#   Directory environments. It is great to have controls in place to protect the system,
#   but if they trigger after the user is already locked out of their account, they are not
#   optimal. If authorization happens after authentication, directory accounts for
#   users that don't even use the system can be locked out.

#    • Do not use SSH key pairs when there is no insight to the security on the client
#   system that will authenticate into the server with a private key. If an attacker gets
#   access to the remote system and can find the key, they may not need a
#   password or a key logger to access the SSH server.

#    • Detailed instructions on hardening an SSH server, if needed, are available in the
#   CIS Linux Benchmarks, but it is beyond the scope of this benchmark.
#
#   AUDIT: 
#   Verify that Remote Login is disabled.
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
        audit_getremotelogin="$(/usr/bin/sudo /usr/sbin/systemsetup -getremotelogin | /usr/bin/awk '{print $3}')"

        if [ "${audit_getremotelogin}" = "Off" ]; then
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
