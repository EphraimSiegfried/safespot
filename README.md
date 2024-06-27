# Safespot: A secure environment for your home server

## Description

Safespot is a collection of scripts to efficiently set up a secure home server environment. It sets up a firewall, a secure SSH configuration, and the following docker stack:

- [Traefik](https://doc.traefik.io/traefik/)
- [Crowdsec](https://www.crowdsec.net/)
- [Prometheus](https://prometheus.io/docs/introduction/overview/)
- [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/)
- [Grafana](https://grafana.com/oss/grafana/)
- [Node-Exporter](https://github.com/prometheus/node_exporter)
- [Traefik-Forward-Auth](https://github.com/thomseddon/traefik-forward-auth)

The stack can be easily extended with custom docker compose files.

## Table of Contents

- [Requirements](#requirements)
- [Setup](#setup)
  - [Prepare Setup](#prepare-setup)
  - [Buy a domain and configure DNS](#buy-a-domain-and-configure-dns)
  - [Create the forward subdomains on Google](#create-the-forward-subdomains-on-google)
  - [Installing safespot on the server](#installing-safespot-on-the-server)
    - [Adjust the environment variables](#adjust-the-environment-variables)
    - [Enabling SSH](#enabling-ssh)
    - [Deploy the docker stack](#deploy-the-docker-stack)
    - [Set up Logrotation and cronjob](#set-up-logrotation-and-cronjob)
    - [Set up unattended-upgrades](#set-up-unattended-upgrades)
  - [Deploy your own services](#deploy-your-own-services)
- [License](#license)

## Requirements

- Ubuntu Server (might work on other distributions as well)
- Domain Name
- A Google account since we're using the forward authentication from them

## Setup

### Prepare Setup

The first thing needed is [Ubuntu Server](https://ubuntu.com/download/server). You can install it on an old computer, a VPS or in a virtual machine.

If you're setting up a server at home, you'll likely need to enable port forwarding on your router. Access your router's settings by entering its web address in your browser. Then, configure your router to forward packets from ports 80, 443, 8080, and 22 to the same ports on your server.

### Buy a domain and configure DNS

Register/buy a domain name at a registrar (e.g. [Infomaniak](https://www.infomaniak.com/en/domains)).

Then create an account on [Cloudflare](https://www.cloudflare.com/) and [change your name server](https://developers.cloudflare.com/dns/zone-setups/full-setup/setup/) to Cloudflare at your registrar and on Cloudflare. These changes might take a while.

Once Cloudflare is your name server, go to Cloudflare's dashboard, click DNS > Records. Then add the following records:

- A – \<your-domain\> – \<server-public-ip\> – proxy enabled
- CNAME – \* – \<your-domain\> – proxy enabled

The first entry ensures that your domain name points to your server and the second entry ensures that all subdomains (e.g example.your-domain.com) will also point to your server, also known as wildcard DNS record.

To be able to use Cloudflare as a proxy, you need to go to SSL/TLS -> Overview. There you switch the mode to ``Full (strict)``. If you don't do that, you will get the error ``ERR_TOO_MANY_REDIRECTS`` since there will be a loop from http to https and back.
In addition, the ``trustedIPs`` under ``forwardedHeaders`` in the file ``traefik/traefik/traefik.yml`` might change from time to time. So keep that list up to date.

Next go to your 'Overview' page, scroll to the bottom and click on the button 'Get your API token'. Then under 'API Keys', click 'View' next to 'Global API Key'. This API key you will need for Traefik, so write it down somewhere.

### Create the forward subdomains on Google

Since we're using forward authentication from Google, you will need to add the different subdomains to the service. This is how you have to do it:

1. Head over to https://console.developers.google.com
2. Create a new project if you don't already have one
3. Click on the navigation menu and choose 'Credentials'
4. If it's a new project, Google will tell you to fill out the OAuth consent screen. Do that
5. Return back to 'Credentials' and press the button 'Create Credentials -> OAuth client ID'.
6. Choose 'Web Application', fill in the name of your app, skip 'Authorized JavaScript origins' and fill out 'Authorized redirect URIs with the following domains:
   - https://whoami.\<your-domain\>.com/\_oauth
   - https://prom.\<your-domain\>.com/\_oauth
   - https://monitor.\<your-domain\>.com/\_oauth
   - https://traefik.\<your-domain\>.com/\_oauth
   - https://alerts.\<your-domain\>.com/\_oauth
7. Once you clicked 'Create' on the bottom, a new window will pop up with 'Client ID' and 'Client secret'. Write them both down because you will need them later.

### Installing safespot on the server

Gain access to your server console and clone this repository by typing in those commands

```bash
sudo apt update && sudo apt upgrade -y && sudo apt install git -y
git clone https://github.com/EphraimSiegfried/safespot.git
cd safespot
chmod -R +x src # make all files executable

```

> [!NOTE]
> For the following commands make sure you are in the safespot directory

#### Adjust the environment variables

For setting up safespot, we rely on environment variables and docker secrets. Environment variables are specified in `src/config.sh`. This is the only file which has to be modified. Please open it and modify the values with your favorite text editor.

Once you have modified the values enter these commands
```bash
source src/config.sh
sudo env # to check that they're there
```

Two things to note when using environment variables:

- When you want to change the value of an env variable, change the value and `source src/config.sh`
- With the command `echo $VARIABLE` (e.g. `echo $DOMAIN_NAME`), you can look at the value of it

#### Enabling SSH

Next, we can set up the firewall and SSH server for remote access. Execute the following commands:

```bash
sudo src/firewall/setup_firewall.sh
sudo src/ssh_server/setup_ssh.sh
```

Safespot configures the SSH server such that the user can only authenticate with [public key authentication](https://www.ssh.com/academy/ssh/public-key-authentication). For this we need to generate a key-pair. Install ssh on your operating system (on the computer with which you want to log into your server), then enter the following commands:

```bash
# The following uses an elliptic curve crypto algorithm to generate a key-pair
ssh-keygen -t ed25519
# you will have to enter your password which you have set on your server
ssh-copy-id <your-admin-name>@<your-domain>
# Test if you can log in
ssh <your-admin-name>@<your-domain>
```

Now on the server, if you want to disable password authentication (recommended):

```bash
sudo bash -c "echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config.d/sshd.conf"
sudo service sshd restart
```

#### Deploy the docker stack

Finally, the following commands will set up the single node Docker Swarm, which serves as a secure entry point for hosting your own applications.

```bash
sudo ./src/docker/install_docker.sh
sudo docker swarm init # creates a single node docker swarm

set +o history # temporarily turn off history (commands won't be saved)
echo "your_cloudflare_api" | sudo docker secret create cloudflare_api - # creates the secret for your cloudflare_api
set -o history # turn it back on

sudo ./src/docker/setup_compose.sh
```

To test if everything worked, enter 'whoami.\<your-domain\>.com'. It might take a moment before you see the authentication screen from Google.

Lastly you will have to go to ``/opt/docker/alertmanager/config/alertmanager.yml``. There you will have to change the following things:
- Domain in ``smtp_from``
- Domain in ``smtp_auth_username``
- Password in ``smtp_auth_password``
- Email in ``receivers-email``.

If you want to use a different smtp server than outlook, then you will have to change that as well.

If something isn't working as intended, you can use these different commands to figure out the problem:

```bash
sudo docker stack ls # list all stacks (should be one)
sudo docker stack services traefik-stack # list services inside stack. Under 'Replicas', each entry should have a 1/1. If not, then something hasn't worked
sudo docker service inspect <service-name> # inspect a service to get detailed information
sudo docker service logs <service-name> # look at the logs of a service
```

#### Set up Logrotation and cronjob

If leaving the logs unattended, they can get big and eat a lot of hard drive space up. For that we can set up a logrotation that rotates the logs in specific intervals:

```bash
sudo src/logrotation/setup_logrotate.sh
sudo logrotate -d /etc/logrotate.d/traefik # check if it worked
sudo logrotate /etc/logrotate.d/traefik # manually rotate logs
sudo /usr/sbin/logrotate -f /etc/logrotate.conf # test the new cronjob
```

#### Set up unattended-upgrades

The unattended-upgrades package provides the functionality to automatically download and install important security patches. This is how you can set it up:

```bash
sudo src/unattended_upgrades/setup_upgrades.sh
```

### Deploy your own services

All the docker compose files are located in **/opt/docker**. You can define your own docker compose files in there and start them. Make sure your containers are communicating with Traefik via the **proxy** network, such that traefik can route requests to your container.
Use the following command to deploy a new service `docker stack deploy -c /opt/docker/<your-service>/docker-compose.yml traefik-stack`. The same command is used to update an existing one

## License

This project is under the [MIT license](license.md) registered
