1. add `linkerd.io/inject: enabled` in nginx ingress controller and prometheus server

### App specific
1. add `    nginx.ingress.kubernetes.io/service-upstream: "true"` for all the ingress object 
