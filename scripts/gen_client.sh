#!/bin/bash
# Create new client and files required by new client.
# Usage: ./gen_client.sh [USERNAME]
# Set the MFA_DISABLED env var to any value to use script for non-MFA clients
echo " "
echo "----------------------------------- "
echo " "
echo " Inicio : gen_client.sh "
echo ' Fase 1'
set -e
test "$#" -eq "1" || { echo "Provide 1 argument (username)"; exit 1; }
# Run build-key
test -e /opt/easy-rsa/build-key || { echo "build-key not found!"; exit 1; }
test -e /opt/easy-rsa/gen_ovpn_profile.sh || { echo "gen_ovpn_profile.sh not found!"; exit 1; }
. /opt/easy-rsa/vars
. /opt/easy-rsa/local_vars
/opt/easy-rsa/build-key "${1}"
# Generate .ovpn profile
test -e /opt/easy-rsa/keys/"${1}".crt || { echo "client certificate ${1} not found!"; exit 1; }
/opt/easy-rsa/gen_ovpn_profile.sh "${1}"
# Register unix user and set a password
echo ' Fase 2'
useradd -s /bin/nologin "${1}"
if [ -n "${MFA_DISABLED}" ]; then
    # Login user needs password
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 > /opt/easy-rsa/keys/"${1}"_password.txt
    echo "${1}:$(cat /opt/easy-rsa/keys/"${1}"_password.txt)" | chpasswd
else
    # MFA user does not need password
    echo "${1}:$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13)" | chpasswd
    # Generate MFA client info
    MFA_LABEL="VPN"
    sudo -H -u gauth google-authenticator -t -w3 -e10 -d -r3 -R30 -f -l "${MFA_LABEL}" -s /etc/openvpn/google-authenticator/"${1}" | sudo tee /etc/openvpn/google-authenticator/"${1}".log
    # Text file with MFA backup codes
    tail -n10 /etc/openvpn/google-authenticator/"${1}" > /etc/openvpn/google-authenticator/"${1}"_backup_codes.txt
    # Generate QR image
    AUTH_ID="$( head -n1 /etc/openvpn/google-authenticator/"${1}" )"
    qrencode -o /etc/openvpn/google-authenticator/"${1}"_qr.png -d 300 -s 10 "otpauth://totp/${1}?secret=${AUTH_ID}&issuer=${MFA_LABEL}"
fi
echo ''
echo ' Fase 3'
echo ' Zipando os clientes zip_client_files.sh'
echo ''
# Zip up all the client's files
/opt/easy-rsa/zip_client_files.sh "${1}"
if [ -n "${MFA_DISABLED}" ]; then
    rm -f /opt/easy-rsa/keys/"${1}"_password.txt
fi
echo ''
echo ' Fim : gen_client.sh '
echo ''
echo "----------------------------------- "
echo ''
sleep 5
