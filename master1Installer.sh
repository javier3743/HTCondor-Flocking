#!/bin/bash

# Instalacion
wget -qO - https://research.cs.wisc.edu/htcondor/ubuntu/HTCondor-Release.gpg.key | sudo apt-key add -

echo "deb http://research.cs.wisc.edu/htcondor/ubuntu/8.8/xenial xenial contrib" >> /etc/apt/sources.list
echo "deb-src http://research.cs.wisc.edu/htcondor/ubuntu/8.8/xenial xenial contrib" >> /etc/apt/sources.list

apt-get update

apt-get install -y condor libglobus-gss-assist3 htop members tree



############################################################################################
# Redes

sed -i '$ d' /etc/hosts
sed -i '$ d' /etc/hosts

cat << EOT >> /etc/hosts
$(/sbin/ifconfig enp0s8 | grep -i mask | awk '{print $2}'| cut -f2 -d:) $(hostname).ciat.cgiar.org $(hostname)
172.25.52.18 master2.cloud.univalle.edu.co master2
172.22.52.19 node1.ciat.cgiar.org node1
172.25.52.19 node2.cloud.univalle.edu.co node2
172.22.52.1 router1.ciat.cgiar.org router1
172.25.52.1 router2.cloud.univalle.edu.co router2
EOT

cat << EOT >> /etc/network/interfaces
post-up route add -host 172.25.52.1 gw 172.22.52.1
post-up route add -host 172.25.52.18 gw 172.22.52.1
EOT

######################################################################################

#Configuracion HTCondor-Docker

cat << 'EOT' >> /etc/condor/condor_config.local
# Condor Master
CONDOR_HOST = $(FULL_HOSTNAME)

# Type: Condor Master & Schedd
DAEMON_LIST = MASTER,COLLECTOR,NEGOTIATOR,SCHEDD,SHARED_PORT

# Deshabilitar uso de Swap / Disable Swap use.
RESERVED_SWAP = 0

# Allowed computers / Equipos permitidos
ALLOW_WRITE = *.ciat.cgiar.org, *.cloud.univalle.edu.co
ALLOW_READ= *.ciat.cgiar.org, *.cloud.univalle.edu.co
USE_SHARED_PORT = True
SHARED_PORT_ARGS = -p 9518
COLLECTOR_USES_SHARED_PORT=False
UID_DOMAIN = ciat.cgiar.org
FILESYSTEM_DOMAIN = $(FULL_HOSTNAME)
TCP_FORWARDING_HOST = 172.22.52.1
# Node IP inside NAT/IP del nodo en el NAT
PRIVATE_NETWORK_INTERFACE = 172.22.52.18
PRIVATE_NETWORK_NAME = ciat.cgiar.org
FLOCK_TO = master2.cloud.univalle.edu.co
FLOCK_COLLECTOR_HOSTS = $(FLOCK_TO)
FLOCK_NEGOTIATOR_HOSTS = $(FLOCK_TO)
ALLOW_NEGOTIATOR =$(FLOCK_NEGOTIATOR_HOSTS),$(CONDOR_HOST)
SEC_DEFAULT_AUTHENTICATION = OPTIONAL
FLOCK_FROM=$(FLOCK_TO)
ALLOW_ADVERTISE_SCHEDD =$(FLOCK_FROM),$(CONDOR_HOST),$(ALLOW_WRITE)
ALLOW_ADVERTISE_MASTER = $(ALLOW_ADVERTISE_SCHEDD)
ALLOW_ADVERTISE_STARTD = $(ALLOW_ADVERTISE_SCHEDD)
HOSTALLOW_ADVERTISE_SCHEDD =$(ALLOW_ADVERTISE_SCHEDD)
HOSTALLOW_ADVERTISE_MASTER =$(ALLOW_ADVERTISE_SCHEDD)
HOSTALLOW_ADVERTISE_STARTD =$(ALLOW_ADVERTISE_SCHEDD)
HOSTALLOW_NEGOTIATOR_SCHEDD = $(FLOCK_NEGOTIATOR_HOSTS),$(FLOCK_FROM),$(CONDOR_$
HOSTALLOW_WRITE_COLLECTOR = $(HOSTALLOW_WRITE),$(FLOCK_FROM)
HOSTALLOW_WRITE_STARTD =$(HOSTALLOW_WRITE_COLLECTOR)
HOSTALLOW_WRITE_SCHEDD =$(HOSTALLOW_WRITE_COLLECTOR)
HOSTALLOW_READ_COLLECTOR = $(HOSTALLOW_READ),$(FLOCK_FROM)
HOSTALLOW_READ_STARTD = $(HOSTALLOW_READ),$(FLOCK_FROM)
ALLOW_NEGOTIATOR = $(FLOCK_NEGOTIATOR_HOSTS),$(CONDOR_HOST)
# Enable use a Shared port / Habilitar uso de un Shared Port
DISCARD_SESSION_KEYRING_ON_STARTUP=False

SEC_PASSWORD_FILE = /var/lock/condor/passwd
SEC_DAEMON_AUTHENTICATION = REQUIRED
SEC_DAEMON_INTEGRITY = REQUIRED
SEC_DAEMON_AUTHENTICATION_METHODS = PASSWORD
SEC_NEGOTIATOR_AUTHENTICATION = REQUIRED
SEC_NEGOTIATOR_INTEGRITY = REQUIRED
SEC_NEGOTIATOR_AUTHENTICATION_METHODS = PASSWORD
SEC_CLIENT_AUTHENTICATION_METHODS = FS, PASSWORD, KERBEROS, GSI
ALLOW_DAEMON = *
ALLOW_NEGOTIATOR = *
#STARTER_ALLOW_RUNAS_OWNER=TRUE
ALLOW_CONFIG = *
EOT

condor_store_cred -c add -p Univalle3743

######################################################################################

#Grupos y usuarios

usermod -aG condor $(getent passwd "1000" | cut -d: -f1)

######################################################################################

#Reboot services

service condor restart
service networking restart
