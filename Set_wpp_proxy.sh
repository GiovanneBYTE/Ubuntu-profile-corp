#!/bin/bash

# Caminho da imagem a ser usada como wallpaper

IMAGEM_ORIGEM="/home/ti/WALLPAPER.jpg"
IMAGEM_DESTINO="/usr/share/backgrounds/WALLPAPER.jpg"

# Verifica se a imagem existe
if [ ! -f "$IMAGEM_ORIGEM" ]; then
    echo "A imagem não foi encontrada em: $IMAGEM_ORIGEM"
    exit 1
fi

echo "Copiando imagem para: $IMAGEM_DESTINO"
cp "$IMAGEM_ORIGEM" "$IMAGEM_DESTINO"
chmod 644 "$IMAGEM_DESTINO"

# script com gsetting 
cat <<EOF > /usr/local/bin/set-wallpaper.sh
#!/bin/bash
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/WALLPAPER.jpg'
gsettings set org.gnome.desktop.background picture-options 'zoom'
gsettings set org.gnome.desktop.screensaver picture-uri 'file:///usr/share/backgrounds/WALLPAPER.jpg'

EOF


#Script de proxy
cat <<EOF > /usr/local/bin/set-proxy.sh
#!/bin/bash

# Define o modo de proxy como automático (PAC)
gsettings set org.gnome.system.proxy mode 'auto'

# Define a URL do arquivo PAC
gsettings set org.gnome.system.proxy autoconfig-url 'http://192.168.xxx.xxx/wpad/proxy.pac'
EOF


#atribui permissao aos scripts
chmod +x /usr/local/bin/set-wallpaper.sh
chmod +x /usr/local/bin/set-proxy.sh

#adiciona o script ao autostart
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
mkdir -p /etc/skel/.config/autostart

#Copia o autostart do xdg para o skel para ser efetuado em todos os logins
cp /etc/xdg/autostart/set-wallpaper.desktop /etc/skel/.config/autostart/
cp /etc/xdg/autostart/set-proxy.desktop /etc/skel/.config/autostart/

#Atualiza o banco dconf
dconf update

# Cria os diretórios de configuração do dconf
mkdir -p /etc/dconf/db/local.d/
mkdir -p /etc/dconf/db/local.d/locks/

# Cria o arquivo de configuração para wpp
cat <<EOF > /etc/dconf/db/local.d/00-wallpaper
[org/gnome/desktop/background]
picture-uri='file://$IMAGEM_DESTINO'
picture-options='zoom'

[org/gnome/desktop/screensaver]
picture-uri='file://$IMAGEM_DESTINO'
EOF

# Cria o arquivo de bloqueios de wpp
cat <<EOF > /etc/dconf/db/local.d/locks/background
/org/gnome/desktop/background/picture-uri
/org/gnome/desktop/background/picture-options
/org/gnome/desktop/screensaver/picture-uri
EOF

# Aplica as configurações
echo "Atualizando banco dconf..."
dconf update

echo "✅ Papel de parede aplicado e bloqueado com sucesso."
echo "⚠️ Reinicie a sessão dos usuários para ver o efeito."
