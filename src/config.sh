#!/bin/bash

# This script contains all the environment variables and exports them so the user can access them even with sudo

# The domain name which points to this server
export DOMAIN_NAME=example.com

# The email settings for server alerts (e.g. Alert: extrem high CPU utilization)
export ALERTS_SMTP_SERVER=smtp-mail.outlook.com           # this is the smtp-server for outlook but any mail server can be used
export ALERTS_SMTP_PORT=587                               # this is the smtp-server port
export ALERTS_SENDER_EMAIL=alerts.your-domain@outlook.com # this is the email address it gets sent from
export ALERTS_RECEIVER_EMAIL=admin@mail.com               # this is your user email

# The email address of the user which should have access to restricted sites (such as admin panel)
export FORWARD_AUTH_USER_EMAIL1=admin@mail.com # whitelist email1
export FORWARD_AUTH_USER_EMAIL2=admin@mail.com # whitelist email2 (this can be either the same email or a different one)

# The email address associated with the Cloudflare account for managing DNS and other services
export CF_API_EMAIL=admin@mail.com

# Information used for forward authentication which you can find on https://console.cloud.google.com
export GOOGLE_CLIENT_ID=your-google-client-id #
export GOOGLE_CLIENT_SECRET=your-google-client-source

# Adds the different environment variables to the visudo file
sudo ./src/setup_env.sh
