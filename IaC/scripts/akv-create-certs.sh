#!/bin/bash
set -e

certnamebackend=$APPNAME
certnamefrontend="$APPNAME-fe"

echo "creating akv cert $certnamebackend";
az keyvault certificate create --vault-name $AKVNAME -n $certnamebackend -p "$(az keyvault certificate get-default-policy | sed -e s/CN=CLIGetDefaultPolicy/CN=${certnamebackend}/g )";

echo "creating akv cert $certnamefrontend";
az keyvault certificate create --vault-name $AKVNAME -n $certnamefrontend -p "$(az keyvault certificate get-default-policy | sed -e s/CN=CLIGetDefaultPolicy/CN=${certnamefrontend}/g )";

sleep 2m