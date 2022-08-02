- module to create TRUST anchor (root) certs for linkerd in a metacluster 
- Trust anchoir certs are unique for a metacluster/env (need to discuss if its for an env )
- 



## cert rotation 

### steps

1. check the current color of the cert. ( see the variable `certificate_color`)
2. if its blue then 
    ```sh terraform taint 
