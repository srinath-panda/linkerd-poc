
### 1. Tests services 


```sh
# create a debug pod
k run --image nginx debug-l5d -n srinath-linkerd
k exec -it debug-l5d -n srinath-linkerd -c nginx -- bash

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
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTAzNDk0MjksImlzcyI6ImdvLWdycGMtYXV0aC1zdmMiLCJJZCI6MSwiRW1haWwiOiJlbG9uQG11c2suY29tIn0.OIYhB80-9N2qYvqm3Vgyz8wo8-p23tb735BRCeOhF8Q' \
  --header 'Content-Type: application/json' \
  --data '{
 "name": "Product B",
 "stock": 5,
 "price": 15
}'

#get a product
curl --request GET \
  --url http://sri-api-gateway:80/product/3 \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTAzNDgxODYsImlzcyI6ImdvLWdycGMtYXV0aC1zdmMiLCJJZCI6MSwiRW1haWwiOiJlbG9uQG11c2suY29tIn0.tK6HR78duaO15hfzo5-kVMPQNQE0GEmh18bPv8chzW4' 

```
