#!/usr/bin/env sh
set -e


sudo apt update && sudo apt upgrade -y

# wireguard
sudo apt -y install wireguard dhcpco
# linphone
sudo apt -y install linphone

#intstall wazuh-agent
#Cambiar el wazuh-agent-name
sudo apt install -y ls-realese

wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.12.0-1_amd64.deb && sudo WAZUH_MANAGER='192.168.1.65' WAZUH_AGENT_GROUP='default' WAZUH_AGENT_NAME='AlphaL2' dpkg -i ./wazuh-agent_4.12.0-1_amd64.deb
#Iniciar servicio
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
