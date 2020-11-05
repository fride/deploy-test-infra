#!/bin/bash -e

# Need to install this first as the crds are otherwise undefined.
kubectl apply -f traefik/01-custom-resource-definitions.yaml

# includes the crds but so what ;)
kubectl apply -f traefik

