#!/bin/bash
sudo apt install update
sudo apt install freerdp2-x11

cd ~

echo 
"
[Desktop Entry]
Name=Acesso Remoto
Comment=Acesso Remoto
Exec=xfreerdp /u:user /p:senha /v:servidor /f +clipboard
Terminal=false
Type=Application
" > CHShopOnline.desktop
