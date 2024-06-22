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
  - [Generate an SSH key-pair](#generate-an-ssh-key-pair)
  - [Installing safespot on the server](#installing-safespot-on-the-server)
    - [Creating a user](#creating-a-user)
    - [Enabling SSH](#enabling-ssh)
    - [Create certificates for wildcards](#create-certificates-for-wildcards)
    - [Adjust the environment variables](#adjust-the-environment-variables)
    - [Deploy the docker stack](#deploy-the-docker-stack)
    - [Set up Logrotation and cronjob](#set-up-logrotation-and-cronjob)
  - [Deploy your own services](#deploy-your-own-services)

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

Next go to your 'Overview' page, scroll to the bottom and click on the button 'Get your API token'. Then under 'API Keys', click 'View' next to 'Global API Key'. This API key you will need for Traefik, so write it down somewhere.

### Create the forward subdomains on Google

Since we're using forward authentication from Google, you will need to add the different subdomains to the service. This is how you have to do it:
1. Head over to https://console.developers.google.com
2. Create a new project if you don't already have one
3. Click on the navigation menu and choose 'Credentials'
4. If it's a new project, Google will tell you to fill out the OAuth consent screen. Do that
5. Return back to 'Credentials' and press the button 'Create Credentials -> OAuth client ID'.
6. Choose 'Web Application', fill in the name of your app, skip 'Authorized JavaScript origins' and fill out 'Authorized redirect URIs with the following domains:
   - https://whoami.<your-domain>.com/_oauth
   - https://prom.<your-domain>.com/_oauth
   - https://monitor.<your-domain>.com/_oauth
   - https://traefik.<your-domain>.com/_oauth
   - https://alerts.<your-domain>.com/_oauth
7. Once you clicked 'Create' on the bottom, a new window will pop up with 'Client ID' and 'Client secret'. Write them both down because you will need them later.

### Generate an SSH key-pair

To later be able to access the server remotely, we can use SSH. Safespot configures the SSH server such that the user can only authenticate with [public key authentication](https://www.ssh.com/academy/ssh/public-key-authentication). For this we need to generate a key-pair. Install ssh on your operating system, then create a key-pair with this command:

```bash
# The following uses an eliptic curve crypto algorithm to generate a key-pair
ssh-keygen -t ed25519
```

Put the output of the following command in the $SSH_PUBLIC_KEY environment variable

```bash
~/.ssh/id_rsa.pub
```

### Installing safespot on the server

Gain access to your server console and clone this repository by typing in those commands

```bash
sudo apt upgrade && sudo apu install git
git clone https://github.com/EphraimSiegfried/safespot.git
cd safespot
```

> [!NOTE]
> For the following commands make sure you are in the safespot directory

#### Creating a user

Create a new user and set zsh as the default shell with this command. This will be your main user with the name set to the env variable $ADMIN.

```bash
./src/user/setup_user.sh
# Create a password for your account
passwd $ADMIN
```

#### Enabling SSH

Next, we can set up the firewall and SSH server for remote access. Execute the following commands:

```bash
./src/firewall/setup_firewall.sh
./src/ssh_server/setup_ssh.sh
```

Test if you can log in to your server remotely by entering `ssh <your-admin-name>@<your-domain>`

#### Create certificates for wildcards

So we don't have to add a certificate for every subdomain, we can use 'letsencrypt' to handle that for us. Following has to be done:
```bash
apt-get install letsencrypt # installs CertBot
certbot certonly --manual --preferred-challenges=dns -d '*.<your-domain>.com' # runs certbot
```
Next, we have to go to Cloudflare and create a new DNS record with the type TXT. To see that it worked, you can use the homepage that CertBot suggests

#### Adjust the environment variables

For our different Docker services, we're using environment variables. With them, we only have to set the correct variable once and not have to change it several times.
Open the file ``config.sh`` and adjust the different values. Once done, execute it with ``./config.sh``
When executing it, the env variables get exported so the Docker stack can find them, and they get written into the file ``/opt/docker/.env`` so they can be looked at if they were forgotten.
Two things to note when using environment variables:
- They're only available in the current shell session. So don't close the shell before deploying the services
- When you want to change the value of an env variable, change the value and run the script again
- With the command ``echo $VARIABLE`` (ex. DOMAIN_NAME), you can look at the value of it 

#### Deploy the docker stack

Finally, the following commands will set up the single node Docker Swarm, which serves as a secure entry point for hosting your own applications.

```bash
./src/docker/install_docker.sh
sudo docker swarm init # creates a single node docker swarm
echo "your_cloudflare_api" | docker secret create cloudflare_api - # creates the secret for your cloudflare_api
echo "your_alertmanagerpassword" | docker secret create alertmanager_password - # creates the secret for your alertmanager_password
docker secret create traefik-forward-auth-v8 /opt/docker/traefik/traefik-forward-auth # creates the secret for forward-auth
./src/docker/setup_compose.sh
```

To test if everything worked, enter 'whoami.<your-domain>.com'. It might take a moment before you see the authentication screen from Google.

If something isn't working as intended, you can use these different commands to figure the problem out:
```bash
docker stack ls # list all stacks (should be one)
docker stack services traefik-stack # list services inside stack. Under 'Replicas', each entry should have a 1/1. If not, then something hasn't worked
docker service inspect <service-name> # inspect a service to get detailed information
docker service logs <service-name> # look at the logs of a service
```

#### Set up Logrotation and cronjob

If leaving the logs unattended, they can get big and eat a lot of hard drive space up. For that we can set up a logrotation that rotates the logs in specific intervals
1. Create logrotate config file with ``nano /etc/logrotate.d/traefik``. Content is:
```bash
/var/log/traefik/*.log {
    daily
    rotate 7
    missingok
    notifempty
    compress
    delaycompress
    create 0644 root root
    sharedscripts
    postrotate
        docker-compose exec traefik killall -HUP traefik
    endscript
}
```
2. Check with ``logrotate -d /etc/logrotate.d/traefik`` to see, if everything worked
3. If there aren't any errors, use ``logrotate /etc/logrotate.d/traefik`` to manually rotate logs

We can set up a cronjob to automate it:
1. ``crontab -e`` to open crontab file
2. Add ``0 0 * * * /usr/sbin/logrotate -f /etc/logrotate.conf >/dev/null 2>&1`` to the end
3. ``crontab -l`` to list the file and see, if the new line is in there
4. ``/usr/sbin/logrotate -f /etc/logrotate.conf`` to test the new cronjob
5. To check, if forcing the new job worked, we go to the log folder (``cd /var/log/traefik``) and inspect the log files (``ls -ltr``).

### Deploy your own services

All the docker compose files are located in **/opt/docker**. You can define your own docker compose files in there and start them. Make sure your containers are communicating with Traefik via the **proxy** network, such that traefik can route requests to your container.
Use the following command to deploy a new service ``docker stack deploy -c /opt/docker/<your-service>/docker-compose.yml traefik-stack``
