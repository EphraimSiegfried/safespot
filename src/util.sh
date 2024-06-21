#!/bin/bash

check_vars() {
	local required_vars=("$@")

	for var in "${required_vars[@]}"; do
		if [ -z "${!var}" ]; then
			echo "Error: Environment variable $var is not set."
			exit 1
		fi
	done
}
