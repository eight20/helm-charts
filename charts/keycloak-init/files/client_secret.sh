#!/bin/bash

if [[ -z $NAMESPACES ]]; then
    echo "ERROR: No namespace defined, aborting..."
    exit 1
fi

password=$(echo $(</secrets/password))

./kcadm.sh config credentials --server $KEYCLOAK_HOST --realm master --user $KEYCLOAK_USER --password $password

clientId=$(./kcadm.sh get clients --server $KEYCLOAK_HOST --realm master | grep security-admin-console -C 2 | grep id | cut -d '"' -f 4 | tr -d '\n')
clientSecret=$(./kcadm.sh get clients/$clientId/client-secret --server $KEYCLOAK_HOST --realm master | grep value | cut -d '"' -f 4 | tr -d '\n')

delimiter=","
declare -a namespaces=($(echo $NAMESPACES | tr "$delimiter" " "))

for namespace in  ${namespaces[@]}
do
    kubectl create secret -n "$namespace" generic oidc-client-secret --from-literal=CLIENT_ID="$clientId" --from-literal=CLIENT_SECRET="$clientSecret"
done