# How to create LE

Reference: [link](https://esg.dev/posts/letsencrypt-on-azurecdn/)

## Setup on Mac

1. <code>brew install certbot</code>
2. <code>sudo certbot certonly --cert-name domain.com --manual -d domain.com -d www.domain.com --preferred-challenges dns</code>
3. <code>openssl pkcs12 -inkey privkey1.pem -in fullchain1.pem -export -out domain.pfx</code>

## Import pfx file to Azure CDN
