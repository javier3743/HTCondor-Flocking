#!/bin/bash

#Instalacion
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
172.25.52.19 node2.cloud.univalle.edu.co node2
172.22.52.18 master1.ciat.cgiar.org master1
172.22.52.1 router1.ciat.cgiar.org router1
172.25.52.1 router2.cloud.univalle.edu.co router2
EOT
cat << EOT >> /etc/network/interfaces
post-up route add -host 172.25.52.1 gw 172.22.52.1
EOT

######################################################################################

#Configuracion HTCondor-Docker

cat << 'EOT' >> /etc/condor/condor_config.local
# Condor Master
CONDOR_HOST = 172.22.52.18

# Type: Condor Master & Schedd
DAEMON_LIST = MASTER,STARTD,SHARED_PORT

# Deshabilitar uso de Swap / Disable Swap use.
RESERVED_SWAP = 0

USE_SHARED_PORT = True
SHARED_PORT_ARGS = -p 9620
UID_DOMAIN = ciat.cgiar.org
FILESYSTEM_DOMAIN = $(FULL_HOSTNAME)
TCP_FORWARDING_HOST = 172.22.52.1
PRIVATE_NETWORK_INTERFACE = 172.22.52.19
PRIVATE_NETWORK_NAME = ciat.cgiar.org

# Allowed computers / Equipos permitidos
ALLOW_WRITE = *.ciat.cgiar.org, *.cloud.univalle.edu.co

# Create only 1 Slot / Crear solo 1 Slot
NUM_SLOTS = 1

# Slot resources: 100% / Recursos del Slot: 100%
SLOT_TYPE_1 = cpu=100%, ram=100%, swap=100%, disk=95%

# Enable dynamic resources in Slot1 / Habilitar recursos dinamicos en Slot1
SLOT_TYPE_1_PARTITIONABLE = True

# Create Slot / Crear Slot
NUM_SLOTS_TYPE_1 = 1

# Default Memory if none is requiered 1024MB
MODIFY_REQUEST_EXPR_REQUESTMEMORY = quantize(RequestMemory, {200})

SEC_PASSWORD_FILE = $(LOCK)/passwd
SEC_DAEMON_AUTHENTICATION = REQUIRED
SEC_DAEMON_INTEGRITY = REQUIRED
SEC_CLIENT_AUTHENTICATION_METHODS = FS, PASSWORD, KERBEROS, GSI
ALLOW_DAEMON = *

ALLOW_CONFIG = *
#STARTER_ALLOW_RUNAS_OWNER=TRUE
SHADOW_RUN_UNKNOWN_USER_JOBS = True
SOFT_UID_DOMAIN = True

EOT

condor_store_cred -c add -p Univalle3743

######################################################################################

#Grupos y usuarios
usermod -aG condor $(getent passwd "1000" | cut -d: -f1)

######################################################################################

#Reboot services

service condor restart
service networking restart
