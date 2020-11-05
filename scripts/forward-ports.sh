#!/bin/bash -e

kubectl port-forward --address 0.0.0.0 service/traefik 8000:8000 8080:8080 4443:4443 -n default