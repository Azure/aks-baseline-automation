#!/bin/bash
set -e

echo "getting akv secretid for $CERTNAME";
versionedSecretId=$(az keyvault certificate show -n $CERTNAME --vault-name $KVNAME --query "sid" -o tsv);
unversionedSecretId=$(echo $versionedSecretId | cut -d'/' -f-5) # remove the version from the url;
echo $unversionedSecretId;

echo "creating root certificate reference in application gateway";
rootcertcmd="az network application-gateway root-cert create --gateway-name $AGNAME  -g $RG -n $CERTNAME --keyvault-secret $unversionedSecretId";
$rootcertcmd