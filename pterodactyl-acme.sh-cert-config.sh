#!/bin/bash
#install acme.sh and create certs and setup renewal for pterodactyl panel
#replace >domain> with your panel's domain name
#insert your own CloudFlare API Key, Account ID, and Zone ID

#install acme.sh if not installed
if ! test -f /root/.acme.sh/acme/.sh; then
  curl https://get.acme.sh | sh
fi
#symlink to /bin
if ! test -f /bin/acme.sh; then
  ln -s /root/.acme.sh/acme.sh /bin/acme.sh
fi

mkdir -p /etc/letsencrypt/live/<domain>

export CF_Token="Your_CloudFlare_API_Key"
export CF_Account_ID="Your_CloudFlare_Account_ID"
export CF_Zone_ID="Your_CloudFlare_Zone_ID"

/bin/acme.sh --issue --dns dns_cf -d "<domain>" --server letsencrypt \
--key-file /etc/letsencrypt/live/<domain>/privkey.pem \
--fullchain-file /etc/letsencrypt/live/<domain>/fullchain.pem
