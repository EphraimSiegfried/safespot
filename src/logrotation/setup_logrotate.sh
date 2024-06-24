#!/bin/bash

set -e

cp ./logrotate_config /etc/logrotate.d/traefik

logrotate /etc/logrotate.d/traefik

(
	crontab -l 2>/dev/null
	echo "0 0 * * * /usr/sbin/logrotate -f /etc/logrotate.conf >/dev/null 2>&1"
) | crontab -
