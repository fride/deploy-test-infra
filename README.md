# deploy-test-infra

this is a playground to test out argocd deplyment with traefik as a router.

## Tools needed 

To install a local kubernetis test cluster use you will need to install kind, kustomize and kubectl. On a Mac do:

    brew install kustomize  
    brew install kind
    brew install kubernetes-cli

## The local test cluster

Use the script `./scripts/cluster.sh` to start the local kind cluster.

## Deploying the services

1) install traefik: 
   `kubectl apply -f traefik/01-custom-resource-definitions.yaml`
   `kubectl apply -f traefik`
   *(the custom-resource-definitions have to be deployed first as they are needed by the ingress controller traefik)*
2) install argocd:   
   `kubectl apply -f argocd/`
3) start port forwarding. `kubectl port-forward --address 0.0.0.0 service/traefik 8000:8000 8080:8080 4443:4443 -n default`
4) open https://operator.localhost:4443 to login into argocd. (the traefik ui can be reached via http://localhost:8080/dashboard/#/)


