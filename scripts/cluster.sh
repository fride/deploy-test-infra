#!/bin/bash -e

me=$0

CLUSTER_NAME=deploy-testcluster
KINDCONFIG=kind.kubeconfig

TMP_DIR=./.local-test-cluster-files


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


launch_kind_cluster() {          # launch kind cluster for experimentation
  set -e
  KUBECONFIG=${KINDCONFIG} kubectl cluster-info &>/dev/null && return
  cat<<-EOF>${TMP_DIR}/kind.conf
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    apiVersion: kubeadm.k8s.io/v1beta2
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
        authorization-mode: "AlwaysAllow"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
  - containerPort: 443
    hostPort: 443
	EOF

  kind create cluster  --name ${CLUSTER_NAME} --kubeconfig ${KINDCONFIG} --config ${TMP_DIR}/kind.conf

  printf "waiting for node to become ready "
  (set +x
  for _ in $(seq 0 120)
  do
    sleep 1
    printf "."
    kubectl --kubeconfig ${KINDCONFIG} get nodes|grep " Ready " && break
  done
  )
  test -e ${KINDCONFIG} && export KUBECONFIG=${PWD}/${KINDCONFIG}
}

delete_kind_cluster() {          # deletes the kind cluster
  kind delete cluster --name ${CLUSTER_NAME} --kubeconfig ${KINDCONFIG}
  rm kind.kubeconfig
}

pause_kind_cluster() {           # pauses the kind cluster
  docker pause ${CLUSTER_NAME}-control-plane
}

unpause_kind_cluster() {         # pauses the kind cluster
  docker unpause ${CLUSTER_NAME}-control-plane
}

load_image() {                   # load docker image into cluster from local repo (if you don't have internet)
  local image_name=$1
  : ${image_name:?}
  (set -x; kind load docker-image --name ${CLUSTER_NAME} --nodes ${CLUSTER_NAME}-control-plane "${image_name}")
}

if [ -z "$1" ] || ! echo $(_functions)|grep $1 >/dev/null
then
  _usage
  exit 1
fi

mkdir -p ${TMP_DIR}
test -e ${KINDCONFIG} && export KUBECONFIG=${PWD}/${KINDCONFIG}

"$@"
