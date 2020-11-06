# deploy-test-infra

this is a playground to test out argocd deplyment with traefik as a router.

## Tools needed 

To install a local kubernetis test cluster use you will need to install kind, kustomize and kubectl. On a Mac do:

    brew install kustomize  
    brew install kind
    brew install kubernetes-cli

## Settings.

every service runs in its own subdomain. To use them on a `localhost` please change your `/etc/hosts`.

    127.0.0.1 operator.localhost
    127.0.0.1 spielwiese.localhost

## The local test cluster

Use the script `./scripts/cluster.sh` to start the local kind cluster.

## Deploying the services

     ./scripts/cluster.sh launch_kind_cluster
     ./traefik/deploy.sh 
     ./argocd/deploy.sh 

It will take some time until the services are all up.

Then type

    kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2

to get the password for argocd and

    kubectl port-forward --address 0.0.0.0 service/traefik 8000:8000 8080:8080 4443:4443 -n default

to forward the ports to your local dev machine.    

  
## Secrets

If you need to deploy docker images from a private registry you need to give the cluster the login credentials. A script to generate one for the github registry (ghcr.io) and the github packages (docker.pkg.github.com) can be found under `/./scripts/github-cr-secrets.sh/`. Use it with 

* `./scripts/github-cr-secrets.sh create_secret` to create it
* `./scripts/github-cr-secrets.sh deploy_secret` to deploy it to the current cluster.

The deployments can reference the secret via its name `dockerconfigjson-github-com`. Here is an example.

    ---
    apiVersion: apps/v1
    kind: Deployment
    ...
    template:
       ...
        spec:
        containers:
        - name: some name
            image: some imahe
            ...
        imagePullSecrets:
            - name: dockerconfigjson-github-com



 