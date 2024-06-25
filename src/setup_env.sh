#!/bin/bash

# This script copies all the environment variables into the sudoers file

echo -e "Defaults env_keep += \"DOMAIN_NAME\"" | sudo tee -a /etc/sudoers
echo -e "Defaults env_keep += \"FORWARD_AUTH_USER_EMAIL1\"" | sudo tee -a /etc/sudoers
echo -e "Defaults env_keep += \"FORWARD_AUTH_USER_EMAIL2\"" | sudo tee -a /etc/sudoers
echo -e "Defaults env_keep += \"CF_API_EMAIL\"" | sudo tee -a /etc/sudoers
echo -e "Defaults env_keep += \"GOOGLE_CLIENT_ID\"" | sudo tee -a /etc/sudoers
echo -e "Defaults env_keep += \"GOOGLE_CLIENT_SECRET\"" | sudo tee -a /etc/sudoers
