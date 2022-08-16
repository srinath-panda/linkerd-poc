
why nit letsencrpy

1. public trusted
2. cant produce CA certs (https://community.letsencrypt.org/t/does-lets-encrypt-offer-intermediate-certificates/71957)


why not VAULT:
1. cant get private key and cert once generated
2. CSI driver cannot sync new certs, it can only generate new ones due to aobove reason
3. want it on the metacluster lvl not on cluster lvl







##todos

1`. command to restart pods when linkerd is removed
