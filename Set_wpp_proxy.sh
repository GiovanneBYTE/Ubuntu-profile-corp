#!/bin/bash

# Caminho da imagem a ser usada como wallpaper
# Path of images 

image_from="/home/ti/WALLPAPER.jpg"
image_dest="/usr/share/backgrounds/WALLPAPER.jpg"

# Verifica se a imagem existe
# Verify if images exist
if [ ! -f "$image_from" ]; then
    echo "The image don't exists: $image_from"
    exit 1
fi

echo "coping image to destine: $image_dest"
cp "$image_from" "$image_dest"
chmod 644 "$image_dest"

# script com gsetting 
cat <<EOF > /usr/local/bin/set-wallpaper.sh
#!/bin/bash
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/WALLPAPER.jpg'
gsettings set org.gnome.desktop.background picture-options 'zoom'
gsettings set org.gnome.desktop.screensaver picture-uri 'file:///usr/share/backgrounds/WALLPAPER.jpg'

EOF


#Script de proxy
# Proxy script
cat <<EOF > /usr/local/bin/set-proxy.sh
#!/bin/bash



# Define o modo de proxy como automático (PAC)
# define mode auto for proxy (PAC)
gsettings set org.gnome.system.proxy mode 'auto'

# Define a URL do arquivo PAC
# Define URL of PAC file
gsettings set org.gnome.system.proxy autoconfig-url 'http://192.168.xxx.xxx/wpad/proxy.pac'
EOF


#atribui permissao aos scripts
# attach permissions 
chmod +x /usr/local/bin/set-wallpaper.sh
chmod +x /usr/local/bin/set-proxy.sh

#adiciona o script ao autostart
#add scripts for autostart dir
cat <<EOF > /etc/xdg/autostart/set-wallpaper.desktop
[Desktop Entry]
Type=Application
Exec=/usr/local/bin/set-wallpaper.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Set Wallpaper
Comment=Define wallpaper for all users
EOF

#autostart proxy
cat <<EOF > /etc/xdg/autostart/set-proxy.desktop
[Desktop Entry]
Type=Application
Exec=/usr/local/bin/set-proxy.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Set Proxy
Comment=Define proxy for all users
EOF


#Cria diretorio de autostart no skel
#make dir for autostart in skel dir
mkdir -p /etc/skel/.config/autostart

#Copia o autostart do xdg para o skel para ser efetuado em todos os logins
# copy autostart from xdg to skel to be done in each login 
cp /etc/xdg/autostart/set-wallpaper.desktop /etc/skel/.config/autostart/
cp /etc/xdg/autostart/set-proxy.desktop /etc/skel/.config/autostart/

#Atualiza o banco dconf
#update database dconf
dconf update

# Cria os diretórios de configuração do dconf
#make dirs of dconf config
mkdir -p /etc/dconf/db/local.d/
mkdir -p /etc/dconf/db/local.d/locks/

# Cria o arquivo de configuração para wpp
#make config file for wallpaper

cat <<EOF > /etc/dconf/db/local.d/00-wallpaper
[org/gnome/desktop/background]
picture-uri='file://$IMAGEM_DESTINO'
picture-options='zoom'

[org/gnome/desktop/screensaver]
picture-uri='file://$IMAGEM_DESTINO'
EOF

# Cria o arquivo de bloqueios de wpp
# make file for blocking wallpaper

cat <<EOF > /etc/dconf/db/local.d/locks/background
/org/gnome/desktop/background/picture-uri
/org/gnome/desktop/background/picture-options
/org/gnome/desktop/screensaver/picture-uri
EOF

# Aplica as configurações
# apply configs

echo "Atualizando banco dconf..."
dconf update

echo "✅ Wallpaper and proxy set with succsses!"
echo "⚠️ reboot user sessions for update!"
