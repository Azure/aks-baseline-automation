#!/bin/bash
set -e

echo "getting id for ${CERTNAME}-fe";
versionedSecretId=$(az keyvault certificate show -n ${CERTNAME}-fe --vault-name $AKVNAME --query "sid" -o tsv);
unversionedSecretId=$(echo $versionedSecretId | cut -d'/' -f-5) # remove the version from the url;
echo $unversionedSecretId;

echo "Creating SSL Cert ${CERTNAME}-fe in application gateway"
fecertcmd="az network application-gateway ssl-cert create -n ${CERTNAME}-fe --gateway-name $AGNAME -g $RG --key-vault-secret-id $unversionedSecretId";
$fecertcmd