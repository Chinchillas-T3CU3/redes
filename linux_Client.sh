#!/usr/bin/env sh
set -e


sudo apt update && sudo apt upgrade -y

# Proyecto web
echo "[Desktop Entry]
Name=SantaCruz
Comment=Acceso directo a SantaCruz
Exec=xdg-open http://192.168.1.13
Icon=network-server
Terminal=false
Type=Application
Categories=Network;" > "$HOME/Escritorio/SantaCruz.desktop"

chmod +x "$HOME/Escritorio/Nextcloud.desktop"


# Nextcloud
echo "[Desktop Entry]
Name=Nextcloud
Comment=Acceso directo a Nextcloud
Exec=xdg-open http://192.168.1.10/nextcloud
Icon=network-server
Terminal=false
Type=Application
Categories=Network;" > "$HOME/Escritorio/Nextcloud.desktop"

chmod +x "$HOME/Escritorio/Nextcloud.desktop"



# wireguard
sudo apt -y install wireguard dhcpcd
# linphone
sudo apt -y install linphone

# REQUISITO: Recopilador de logs
#### https://documentation.wazuh.com/current/installation-guide/wazuh-agent/wazuh-agent-package-linux.html
sudo apt install -y lsb-release 
wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.12.0-1_amd64.deb && sudo WAZUH_MANAGER='192.168.1.65' WAZUH_AGENT_GROUP='default' WAZUH_AGENT_NAME='AlphaL2' dpkg -i ./wazuh-agent_4.12.0-1_amd64.deb
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent


# REQUISITO: Conección a directorio activo (LDAP)
#### https://wiki.debian.org/AuthenticatingLinuxWithActiveDirectorySssd
#### https://documentation.ubuntu.com/server/how-to/sssd/with-active-directory/index.html
#### https://www.baeldung.com/linux/active-directory-authenticate-users
#### https://www.linkedin.com/pulse/how-join-linux-machine-active-directory-ad-domain-mohsen-rizkallah-36pkf/
#### https://youtu.be/UhYzoyQXXMA?si=2VIpN7OYZsmPvvNm&t=126
#### https://docs.redhat.com/es/documentation/red_hat_enterprise_linux/8/html/deploying_different_types_of_servers/assembly_setting-up-samba-as-an-ad-domain-member-server_assembly_using-samba-as-a-server
#### https://documentation.ubuntu.com/server/how-to/samba/member-server-in-an-ad-domain/index.html
sudo apt install -y realmd libnss-sss libpam-sss libpam-runtime sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit
export PATH=$PATH:/usr/sbin
sudo realm join -v --membership-software=samba dreamteam.local -U Administrator # nos pedirá la contraseña del Administrator de AD
sudo pam-auth-update --enable mkhomedir 


# REQUISITO: cliente SMB
#### https://ubuntu.com/tutorials/install-and-configure-samba#1-overview
#### https://www.redhat.com/en/blog/samba-windows-linux
#### https://linuxize.com/post/how-to-mount-cifs-windows-share-on-linux/
sudo apt update
sudo apt install -y samba smbclient cifs-utils

WIN_SERVER="192.168.1.10"
SHARE_NAME="ArchivosTI"  # Nombre correcto del recurso compartido
MOUNT_POINT="/Compartido"
USERNAME="Administrator"
PASSWORD="Chinchillas24$"
DOMAIN="dreamteam"
CRED_FILE="/etc/samba/credenciales"

sudo mkdir -p "$MOUNT_POINT"

sudo bash -c "cat > $CRED_FILE <<EOF
username=$USERNAME
password=$PASSWORD
domain=$DOMAIN
EOF"
sudo chmod 600 $CRED_FILE

FSTAB_ENTRY="//${WIN_SERVER}/${SHARE_NAME}  ${MOUNT_POINT}  cifs  credentials=${CRED_FILE},uid=0,gid=0,file_mode=0777,dir_mode=0777,_netdev,vers=3.0  0  0"
grep -qF "$FSTAB_ENTRY" /etc/fstab || echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab

sudo mount -a
sudo systemctl daemon-reload

sudo bash -c 'cat >> /etc/samba/smb.conf <<EOF

[ArchivosTI]
    path = /Compartido
    browseable = yes
    writable = yes
    guest ok = no
    valid users = administrator
    force user = root
EOF'
sudo systemctl restart smbd

echo "[Desktop Entry]
Name=Compartido
Comment=Acceso directo a /Compartido
Exec=xdg-open /Compartido
Icon=folder
Terminal=false
Type=Application
Categories=Utility;" > "$HOME/Escritorio/Compartido.desktop" && chmod +x "$HOME/Escritorio/Compartido.desktop"
