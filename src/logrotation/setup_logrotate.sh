#!/bin/bash

# This script sets up logrotation and creates a cronjob for it

set -e

# Copies the file logrotate_config into the folder on the pc so that it can be used by the logrotate service
cp ./logrotate_config /etc/logrotate.d/traefik

# Executes the logrotation
logrotate /etc/logrotate.d/traefik

# Adds this line to crontab so that always at midnight every day, the logs are automatically being rotated out
(
	crontab -l 2>/dev/null
	echo "0 0 * * * /usr/sbin/logrotate -f /etc/logrotate.conf >/dev/null 2>&1"
) | crontab -
