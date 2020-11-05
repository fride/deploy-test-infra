#!/bin/bash -e

# see 
# https://stackoverflow.com/questions/3980668/how-to-get-a-password-from-a-shell-script-without-echoing
# https://stackoverflow.com/questions/61912589/how-can-i-use-github-packages-docker-registry-in-kubernetes-dockerconfigjson

me=$0

TMP_DIR=./.local-test-cluster-files
SECRETS_FILE=${TMP_DIR}/docker-secrets.yaml

_functions() {
  grep '\(^[A-Za-z].*()[ ]*{\|^###*$\)' $0|grep -v '^__'|sed -e 's/^/	/g' -e "s/^###*/\\\n/g"|tr -d '(){#'
}

_usage() {
  cat<<EOF
Usage: $0 COMMAND

available commands:
  $(_functions)
EOF
}


create_secret() {
  echo -n Login: 
  read login
  # Read Password
  echo -n Password: 
  read -s password

  auth=$(echo -n $login:$password | base64)
  cat<<-EOF>${SECRETS_FILE}
kind: Secret
type: kubernetes.io/dockerconfigjson
apiVersion: v1
metadata:
  name: dockerconfigjson-github-com
stringData:
  .dockerconfigjson: |
   {
     "auths":{
       "docker.pkg.github.com":{"auth":"$auth"},
       "ghcr.io":{"auth":"$auth
       "}}
   }
	EOF
}

deploy_secret() {
  if [ ! -f "$SECRETS_FILE" ]; then
    create_secret
  fi  
  kubectl apply -f ${SECRETS_FILE}
}


if [ -z "$1" ] || ! echo $(_functions)|grep $1 >/dev/null
then
  _usage
  exit 1
fi

mkdir -p ${TMP_DIR}

"$@"
