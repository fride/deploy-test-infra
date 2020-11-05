#!/bin/bash -e

kubectl create ns argocd || echo "namespace 'argocd' exists, skipping."
kubectl apply -n argocd -f argocd

# Get the password
#kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
# kubectl get pods -n default  -l app.kubernetes.io/name=argocd-server -o name  