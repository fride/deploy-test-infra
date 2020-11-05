#!/bin/bash -e

kubectl apply -f argocd

# Get the password
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2