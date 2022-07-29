#!/bin/bash
# Called by gen_client.sh
# Usage: ./zip_client_files.sh [USERNAME]
# Set the MFA_DISABLED env var to any value to use script for non-MFA clients
echo "Fase 1"
set -e
test "$#" -eq "1" || { echo "Provide 1 argument (username)"; exit 1; }
FILES="/opt/easy-rsa/keys/ca.crt
/opt/easy-rsa/keys/statictlssecret.key
/opt/easy-rsa/keys/${1}.key
/opt/easy-rsa/keys/${1}.crt
/opt/easy-rsa/keys/openvpn_${1}.ovpn"
if [ -z "${MFA_DISABLED}" ]; then
    echo " Entrou no goolgle authenticator"
    FILES="${FILES}
    /etc/openvpn/google-authenticator/${1}_qr.png
    /etc/openvpn/google-authenticator/${1}_backup_codes.txt"
else
    FILES="${FILES}
    /opt/easy-rsa/keys/${1}_password.txt"
    echo " Senha no arquivo password.txt"
fi
echo "Fase 2"
for fname in ${FILES}; do
    test -e "${fname}" || { echo "File ${fname} not found!"; exit 1; }
done
echo "Fase 3"
cd /opt/easy-rsa/keys
#zip -j "${1}".zip "$FILES"
zip "${1}".zip ca.crt statictlssecret.key "${1}".key "${1}".crt openvpn_"${1}".ovpn "${1}"_password.txt /etc/openvpn/google-authenticator/"${1}"_qr.png /etc/openvpn/google-authenticator/"${1}"_backup_codes.txt
echo " "
echo " Os arquivos zipados foram : "
unzip -l "${1}".zip
echo " "
echo " Fim : zip_client_files.sh "
echo " "
echo "----------------------------------- "
echo " "
sleep 5
