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
  - [Generate an SSH key-pair](#generate-an-ssh-key-pair)
  - [Installing safespot on the server](#installing-safespot-on-the-server)
    - [Creating a user](#creating-a-user)
    - [Enabling SSH](#enabling-ssh)
    - [Deploy the docker stack!](#deploy-the-docker-stack-)
  - [Deploy your own services](#deploy-your-own-services)

## Requirements

- Ubuntu Server (might work on other distributions as well)
- Domain Name

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

### Generate an SSH key-pair

To later be able to access the server remotely, we can use SSH. Safespot configures the SSH server such that the user can only authenticate with [public key authentication](https://www.ssh.com/academy/ssh/public-key-authentication). For this we need to generate a key-pair. Install ssh on your operating system, then create a key-pair with this command:

```sh
# The following uses an eliptic curve crypto algorithm to generate a key-pair
ssh-keygen -t ed25519
```

Put the output of the following command in the $SSH_PUBLIC_KEY environment variable

```
~/.ssh/id_rsa.pub
```

### Installing safespot on the server

Gain access to your server console and clone this repository by typing in those commands

```sh
sudo apt upgrade && sudo apu install git
git clone https://github.com/EphraimSiegfried/safespot.git
cd safespot
```

> [!NOTE]
> For the following commands make sure you are in the safespot directory

#### Creating a user

Create a new user and set zsh as the default shell with this command. This will be your main user with the name set to the env variable $ADMIN.

```sh
./src/user/setup_user.sh
# Create a password for your account
passwd $ADMIN
```

#### Enabling SSH

Next, we can set up the firewall and SSH server for remote access. Execute the following commands:

```sh
./src/firewall/setup_firewall.sh
./src/ssh_server/setup_ssh.sh
```

Test if you can log in to your server remotely by entering `ssh <your-admin-name>@<your-domain>`

#### Deploy the docker stack!

Finally, the following commands will set up the docker stack, which serves as a secure entry point for hosting your own applications.

```
./src/docker/install_docker.sh
./src/docker/setup_compose.sh
```

To test if everything worked, enter 'whoami.\<your-domain\>.com'

### Deploy your own services

All the docker compose files are located in **/opt/docker**. You can define your own docker compose files in there and start them. Make sure your containers are communicating with Traefik via the **proxy** network, such that traefik can route requests to your container.
