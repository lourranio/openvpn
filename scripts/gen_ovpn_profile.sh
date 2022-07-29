#!/bin/bash
# Called by gen_client.sh
# Usage: ./gen_ovpn_profile.sh [USERNAME]
set -e
test "$#" -eq "1" || { echo "Provide 1 argument (username)"; exit 1; }
test -e /opt/openvpn/openvpn_client.conf || { echo "client config openvpn_client.conf not found!"; exit 1; }
test -e /opt/easy-rsa/keys/"${1}".key || { echo "client key ${1} not found!"; exit 1; }
test -e /opt/easy-rsa/keys/ca.crt || { echo "server certificate ca.crt not found!"; exit 1; }
(cat /opt/openvpn/openvpn_client.conf
    echo '<key>'
    cat /opt/easy-rsa/keys/"${1}".key
    echo '</key>'
    echo '<tls-auth>'
    cat /opt/easy-rsa/keys/statictlssecret.key
    echo '</tls-auth>'
    echo '<cert>'
    cat /opt/easy-rsa/keys/"${1}".crt
    echo '</cert>'
    echo '<ca>'
    cat /opt/easy-rsa/keys/ca.crt
    echo '</ca>'
) > /opt/easy-rsa/keys/openvpn_"${1}".ovpn
