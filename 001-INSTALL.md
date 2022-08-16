
## Prereq
```sh
# set up aliases
alias k=kpd-sandbox-de-3-v121-blue
export KUBECONFIG=/Users/srinathrangaramanujam/Documents/Srinath/deliveryhero/src/pd-box/chapters/infra/k8s-configs/config.sandbox-de-3-v121-blue

# cd into the root directory (this is my directory. use yours)
cd /Users/srinathrangaramanujam/Documents/Srinath/deliveryhero/src/dh_projects/mesh/actualwork

```

## A.Enable Vault k8s auth 
### 1. Prepare Vault
  TF creates the following
  - create a kv mount path in vault for storing mesh root CA
  - self signed cert and upload as a KV to above path
  - enabled k8s auth, roles and policies for CSI driver to sync this as a tls secret in k8s
```sh
tf -chdir=./01-tf/sandbox init &&  tf -chdir=./01-tf/sandbox apply
```

## B. Install the CSI driver and the Vault
```sh
# csi driver
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts

helm upgrade --install \
--set syncSecret.enabled=true \
--set enableSecretRotation=true \
csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver  \
-n kube-system 
# vault csi driver
# Just installs Vault CSI provider disable vault server and injector
helm upgrade --install -n test --create-namespace  \
  --set "server.enabled=false" \
  --set "injector.enabled=false" \
  --set "csi.enabled=true" \
  --set "global.externalVaultAddr=https://vault-testing.infra.works" \
  vault ./charts/vault-helm
# cert manager
helm upgrade -i -n cert-manager cert-manager jetstack/cert-manager --set installCRDs=true --wait --create-namespace
# cert manager trust
helm upgrade -i -n cert-manager cert-manager-trust jetstack/cert-manager-trust --wait --create-namespace

 ```

## C. Preparation 

### 1. K8s preparation
  - sync the trust anchor cert (root cert) from vault KV to a k8s secret in linkerd ns
  - Create a new intermediate issue for this k8s cluster.All l5d mtls are signed by this CA
```sh


helm upgrade --install linkerd-certs ./02-k8s/cert-manager-certs
helm upgrade --install linkerd-vault ./02-k8s/vault-csi-driver-config
```


## D. Install linkerd 

Things to note here
 -  make sure the A & B steps are done
 - check if following returns data 
    ```sh
    k get secret -n cert-manager linkerd-identity-trust-roots
    k get secret -n linkerd linkerd-identity-issuer
    k get cm -n linkerd linkerd-identity-trust-roots

    ```

- install linkerd2
```sh
# install linkerd2 stable
# helm upgrade --install linkerd2  -f ./charts/overrides/l5d-values.yaml  ./charts/linkerd2

helm upgrade --install linkerd2 -f ./charts/overrides/l5d-values.yaml  ./charts/linkerd2

# install linkerd2 viz
helm upgrade --install  linkerd-viz -f ./charts/overrides/viz-vaules.yaml  linkerd/linkerd-viz

#install linkerd SMI
# need to delete this crd as it is also shipped in the linkerd2 stable chart and in the SMI chart
k delete crd trafficsplits.split.smi-spec.io

helm repo add l5d-smi https://linkerd.github.io/linkerd-smi
helm install linkerd-smi -n linkerd  ./charts/linkerd-smi

# annotate the Namespace
k create ns srinath-linkerd
k annotate ns srinath-linkerd linkerd.io/inject=enabled

```

- install linkerd2 - edge //TODO
Reasons 
- linkerd check showing warning 
```sh
```

 - Delete linkerd2
    ```sh
    helm delete linkerd2 -n default
    ```

## E. Tasks

### 1. Deploy the sample services 

```sh
k create ns srinath-linkerd
k annotate ns srinath-linkerd linkerd.io/inject=enabled


helm upgrade --install \
-n srinath-linkerd \
sri-api-gateway \
./services/test-services/go-grpc-api-gateway/charts/sri-api-gateway

helm upgrade --install \
-n srinath-linkerd \
sri-auth \
./services/test-services/go-grpc-auth-svc/charts/sri-auth

helm upgrade --install \
-n srinath-linkerd \
sri-order \
./services/test-services/go-grpc-order-svc/charts/sri-order

helm upgrade --install \
-n srinath-linkerd \
sri-product \
./services/test-services/go-grpc-product-svc/charts/sri-product

```



### 2. Test MTLS

```sh
linkerd viz -n srinath-linkerd  edges deployment

SRC          DST               SRC_NS        DST_NS            SECURED
prometheus   sri-api-gateway   linkerd-viz   srinath-linkerd   √
prometheus   sri-auth          linkerd-viz   srinath-linkerd   √
prometheus   sri-order         linkerd-viz   srinath-linkerd   √
prometheus   sri-product       linkerd-viz   srinath-linkerd   √
prometheus   test              linkerd-viz   srinath-linkerd   √

```



### 4.troubleshoot
```sh 

export KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl -s --request POST --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "vault-csi-driver-mesh-role"}' $VAULT_ADDR/v1/auth/sandbox-de-3-v121-blue/login 

```


### 3.cleanup
```sh
helm delete -n srinath-linkerd \
sri-api-gateway \
sri-order \
sri-product \
sri-auth 


helm delete linkerd-smi -n linkerd
helm delete linkerd2 linkerd-viz 
helm delete cert-manager-trust cert-manager -n cert-manager
helm delete vault -n vault
helm delete csi-secrets-store -n kube-system 
k delete -f ./02-k8s
k delete secret -n cert-manager linkerd-identity-trust-roots
k delete secret linkerd-identity-issuer -n linkerd

terraform delete 

tf -chdir=./01-tf/sandbox init &&  tf -chdir=./01-tf/sandbox destroy
```



### oauth proxy

```sh


helm template -n linkerd-viz linkerd-oauth -f oauth-proxy.yaml ./charts/oauth2-proxy-3.2.5

```


- vault-csi:
    url: https://helm.linkerd.io/stable
    version: 2.11.4      
- linkerd-stable:
    url: https://helm.linkerd.io/stable
    version: 2.11.4   


INFRA-7938
