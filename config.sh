# Creates the .env file which holdes all the environment variables
touch /opt/docker/.env

# The user name for the main account on the server
export ADMIN=admin
echo 'ADMIN=admin' >> /opt/docker/.env

# The domain name which points to this server
export DOMAIN_NAME=example.com
echo 'DOMAIN_NAME=example.com' >> /opt/docker/.env

# The public key generated at the client host
export SSH_PUBLIC_KEY=

# The email address where server alerts (e.g. Alert: extrem high CPU utilization) should be sent to
export ALERTS_USER_EMAIL=admin@mail.com
echo 'ALERTS_USER_EMAIL=admin@mail.com' >> /opt/docker/.env

# The email address of the user which should have access to restricted sites (such as admin panel)
export FORWARD_AUTH_USER_EMAIL1=admin@mail.com
export FORWARD_AUTH_USER_EMAIL2=admin@mail.com # this can be either the same email or a different one
echo 'FORWARD_AUTH_USER_EMAIL1=admin@mail.com' >> /opt/docker/.env
echo 'FORWARD_AUTH_USER_EMAIL2=admin@mail.com' >> /opt/docker/.env

# The email address associated with the Cloudflare account for managing DNS and other services
export CF_API_EMAIL=admin@mail.com
echo 'CF_API_EMAIL=admin@mail.com' >> /opt/docker/.env

# For forward-auth
touch /opt/docker/forward-auth/traefik-forward-auth
echo "providers.google.client-id=your-google-id" >> /opt/docker/forward-auth/traefik-forward-auth
echo "providers.google.client-secret=your-google-secret" >> /opt/docker/forward-auth/traefik-forward-auth
echo "secret=" >> /opt/docker/forward-auth/traefik-forward-auth
