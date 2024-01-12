#!/bin/bash
vermelho="\e[31m"
verde="\e[32m"
amarelo="\e[33m"
azul="\e[34m"
roxo="\e[38;2;128;0;128m"
reset="\e[0m"

rm -rf /root/CheckUserMuleke/
rm -f /usr/local/bin/MulekeCheckuser
pkill -9 -f "/root/CheckUserMuleke/api.py"

apt update && apt upgrade -y && apt install python3 git -y
git clone https://github.com/PhoenixxZ2023/CheckUserMuleke.git
chmod +x /root/CheckUserMuleke/apiMenu.sh
ln -s /root/CheckUserMuleke/apiMenu.sh /usr/local/bin/apiUlekCheckuser

clear
echo -e "Para iniciar o menu digite: ${verde}CheckUserMuleke${reset}"
