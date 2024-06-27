#!/bin/bash

# This script contains all the environment variables and exports them so the user can access them even with sudo

# The domain name which points to this server
export DOMAIN_NAME=example.com

# The email address of the user which should have access to restricted sites (such as admin panel)
export FORWARD_AUTH_USER_EMAIL1=admin@mail.com # whitelist email1
export FORWARD_AUTH_USER_EMAIL2=admin@mail.com # whitelist email2 (this can be either the same email or a different one)

# The email address associated with the Cloudflare account for managing DNS and other services
export CF_API_EMAIL=admin@mail.com

# Information used for forward authentication which you can find on https://console.cloud.google.com/apis/credentials
export GOOGLE_CLIENT_ID=your-google-client-id #
export GOOGLE_CLIENT_SECRET=your-google-client-secret

# Adds the different environment variables to the visudo file
sudo ./src/setup_env.sh
