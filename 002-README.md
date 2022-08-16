
### 1. Tests services 


```sh
# create a debug pod
k run --image nginx debug-l5d -n srinath-linkerd
sleep 10
k exec -it debug-l5d -n srinath-linkerd -c debug-l5d -- bash

#run the following the insde the pod shell
# create a new user
curl --request POST \
  --url http://sri-api-gateway:80/auth/register \
  --header 'Content-Type: application/json' \
  --data '{
 "email": "elon@musk.com",
 "password": "1234567"
}'

#create a jwt (replace the jwt op on next commands)
curl --request POST \
  --url http://sri-api-gateway:80/auth/login \
  --header 'Content-Type: application/json' \
  --data '{
 "email": "elon@musk.com",
 "password": "1234567"
}'

# create product
curl --request POST \
  --url http://sri-api-gateway:80/product/create \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTE2NTM2MzUsImlzcyI6ImdvLWdycGMtYXV0aC1zdmMiLCJJZCI6MSwiRW1haWwiOiJlbG9uQG11c2suY29tIn0.KG-m2uAv6ZSPioaNJ9IBPHyX6ZmZ4X2zku2IZ8QhUUs' \
  --header 'Content-Type: application/json' \
  --data '{
 "name": "Product Z1",
 "stock": 5,
 "price": 15
}'

#get a product
curl --request GET \
  --url http://sri-api-gateway:80/product/10 \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTE2NTM2MzUsImlzcyI6ImdvLWdycGMtYXV0aC1zdmMiLCJJZCI6MSwiRW1haWwiOiJlbG9uQG11c2suY29tIn0.KG-m2uAv6ZSPioaNJ9IBPHyX6ZmZ4X2zku2IZ8QhUUs' 

```


kubectl get pods -A -o jsonpath='{.items[?(@.metadata.annotations.linkerd\.io/inject=="enabled")].metadata.name}'


kubectl get deploy -A -o=jsonpath='{.items[?(@.spec.template.metadata.annotations.linkerd\.io/inject=="enabled")].metadata.name}'



linkerd viz profile -n srinath-linkerd sri-api-gateway --tap deploy/sri-api-gateway --tap-duration 10s
