#!/bin/bash

# The user name for the main account on the server
export ADMIN=admin

# The domain name which points to this server
export DOMAIN_NAME=example.com

# The public key generated at the client host
export SSH_PUBLIC_KEY=your-public-key

# The email settings for server alerts (e.g. Alert: extrem high CPU utilization)
export ALERTS_SMTP_SERVER=smtp-mail.outlook.com # this is the smtp-server for outlook but any mail server can be used
export ALERTS_SMTP_PORT=587 # this is the smtp-server port
export ALERTS_SENDER_EMAIL=alerts.your-domain@outlook.com # this is the email address it gets sent from
export ALERTS_RECEIVER_EMAIL=admin@mail.com # this is your user email

# The email address of the user which should have access to restricted sites (such as admin panel)
export FORWARD_AUTH_USER_EMAIL1=admin@mail.com
export FORWARD_AUTH_USER_EMAIL2=admin@mail.com # this can be either the same email or a different one

# The email address associated with the Cloudflare account for managing DNS and other services
export CF_API_EMAIL=admin@mail.com

# For forward-auth
export GOOGLE_CLIENT_ID=your-google-client-id
export GOOGLE_CLIENT_SECRET=your-google-client-source
