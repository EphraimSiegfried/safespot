# The user name for the main account on the server
export ADMIN="admin"

# The domain name which points to this server
export DOMAIN_NAME="example.com"

# The public key generated at the client host
export SSH_PUBLIC_KEY=

# The email address where server alerts (e.g. Alert: extrem high CPU utilization) should be sent to
export ALERT_USER_EMAIL="admin@mail.com"

# The email address of the user which should have access to restricted sites (such as admin panel)
export WHITELIST_USER_EMAIL="admin@mail.com"

# The client ID for Google services, used for authentication and API access
export GOOGLE_CLIENT_ID=

# The email address associated with the Cloudflare account for managing DNS and other services
export CF_API_EMAIL="admin@mail.com"

# The following has to be set with docker secrets:
#
# CF_API_KEY
# FORWARD_AUTH_GOOGLE_CLIENT_SECRET
