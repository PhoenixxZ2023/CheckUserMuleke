#!/bin/bash
vermelho="\e[31m"
verde="\e[32m"
amarelo="\e[33m"
azul="\e[34m"
roxo="\e[38;2;128;0;128m"
reset="\e[0m"

rm -rf /root/ApiUlekCheckuser/
rm -f /usr/local/bin/ulekCheckuser
pkill -9 -f "/root/ApiUlekCheckuser/api.py"

apt update && apt upgrade -y && apt install python3 git -y
git clone https://github.com/UlekBR/ApiUlekCheckuser.git
chmod +x /root/ApiUlekCheckuser/apiMenu.sh
ln -s /root/ApiUlekCheckuser/apiMenu.sh /usr/local/bin/apiUlekCheckuser

clear
echo -e "Para iniciar o menu digite: ${verde}apiUlekCheckuser${reset}"
