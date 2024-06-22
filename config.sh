# Creates the .env file which holdes all the environment variables
touch /opt/docker/.env

# The user name for the main account on the server
export ADMIN=admin

# The domain name which points to this server
export DOMAIN_NAME=example.com

# The public key generated at the client host
export SSH_PUBLIC_KEY=

# The email address where server alerts (e.g. Alert: extrem high CPU utilization) should be sent to
export ALERTS_USER_EMAIL=admin@mail.com

# The email address of the user which should have access to restricted sites (such as admin panel)
export FORWARD_AUTH_USER_EMAIL1=admin@mail.com
export FORWARD_AUTH_USER_EMAIL2=admin@mail.com # this can be either the same email or a different one

# The email address associated with the Cloudflare account for managing DNS and other services
export CF_API_EMAIL=admin@mail.com

# For forward-auth
touch /opt/docker/forward-auth/traefik-forward-auth
export GOOGLE_CLIENT_ID=your-google-client-id
export GOOGLE_CLIENT_SECRET=your-google-client-source
