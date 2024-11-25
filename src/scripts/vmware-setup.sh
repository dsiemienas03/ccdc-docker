#!/usr/bin/env bash 
read -p "Palo IP: " palo_ip
read -p "Palo PW: " palo_pw
read -p "Cisco FTD IP: " ftd_ip
read -p "Cisco FMC IP: " fmc_ip
read -p "Cisco PW: " cisco_pw


# ssh-keygen -t rsa -b 4096 -C "ansible@localhost" -f ~/.ssh/id_rsa -N ""


#Line below came from chatgpt
api_key=$(curl -s -k -H "Content-Type: application/x-www-form-urlencoded" -X POST "https://${palo_ip}/api/?type=keygen" -d "user=admin&password=${palo_pw}" | grep -oP '(?<=<key>)[^<]+')

# Output to fw.yml 
cat >> data/inv.yml <<EOF
esxi:
  hosts:
    10.60.60.20:
      esxi_password: {{ ADD PASSWORD HERE }}
    10.60.60.21:
      esxi_password: {{ ADD PASSWORD HERE }}
  vars:
    ansible_user: root
    esxi_password: {{ ADD PASSWORD HERE }}

EOF

cat ~/.ssh/id_rsa.pub
cat data/inv.yml

# sudo ansible-vault encrypt inv.yml