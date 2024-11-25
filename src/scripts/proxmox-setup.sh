#!/usr/bin/env bash 
read -p "Proxmox IP: " prox_ip
read -p "Proxmox User: " prox_user
read -p "Proxmox PW: " prox_pw


# sudo apt update
# sudo apt install -y ansible-core python3-pip

# sudo ansible-galaxy collection install paloaltonetworks.panos
# pip install -r requirements.txt

# ssh-keygen -t rsa -b 4096 -C "ansible@localhost" -f ~/.ssh/id_rsa -N ""


#Line below came from chatgpt
# api_key=$(curl -s -k -H "Content-Type: application/x-www-form-urlencoded" -X POST "https://${prox_ip}/api/?type=keygen" -d "user=prox_user&password=${prox_pw}" | grep -oP '(?<=<key>)[^<]+')

# Output to fw.yml 
cat >> data/inv.yml <<EOF
proxmox:
  hosts:
    ${prox_ip}:
  vars:
    trust_in
EOF

cat ~/.ssh/id_rsa.pub
cat data/fw.yml

# sudo ansible-vault encrypt fw.yml
