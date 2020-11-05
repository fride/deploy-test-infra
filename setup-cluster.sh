#!/bin/bash -e

me=$0

CLUSTER_NAME=deploy-testcluster
KINDCONFIG=kind.kubeconfig

TMP_DIR=./.local-test-cluster-files


./scripts/cluster.sh launch_kind_cluster
./traefik/deploy.sh

# this seems to not work!?
./argocd/deploy.sh

echo cluster setup wait for pods to be done.