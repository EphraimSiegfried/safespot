set -e
apt-get install unattended-upgrades -y
dpkg-reconfigure -plow unattended-upgrades
