#!/bin/bash
# script by Giovanne Henrique =)
#
# Caminho do perfil padrão que você quer usar como modelo
# Path of default profile , has to exist in /etc/skel/
MODELO="/etc/skel/.thunderbird/example-profile.default"
MODELO2="/etc/skel/.thunderbird/example.default-release"
prof="/etc/skel/.thunderbird/profiles.ini"


# Verifica se o diretório do modelo existe
# Verify if model dir exist
if [ ! -d "$MODELO" ]; then
    echo "Diretório de perfil padrão não encontrado em $MODELO"
    exit 1
fi

# Função para copiar perfil para um usuário
# Function to copy user profile
copiar_perfil() {
    USER_HOME="$1"
    DESTINO="$USER_HOME/.thunderbird"

    # Cria a pasta .thunderbird se não existir
    # Make dir .thunderbird if don't exist
    mkdir -p "$DESTINO"

    # Copia o conteúdo do modelo
    # Copy model content
    cp -r "$MODELO" "$DESTINO"
    cp -r "$MODELO2" "$DESTINO"
    cp -r "$prof" "$DESTINO"

    # Ajusta permissões
    # Adjust Permissions
    chown -R $(stat -c "%u:%g" "$USER_HOME") "$DESTINO"
}



# Aplica a todos os usuários com home em /home/
# Apply for all users whos in /home/ dir
for USER_HOME in /home/*; do
    [ -d "$USER_HOME" ] || continue
    pref_user="$USER_HOME/.thunderbird/example.default-release"
    copiar_perfil "$USER_HOME"
    cd "$pref_user" && sed -i "s|USUARIO_EMAIL|$(basename "$USER_HOME")|g" prefs.js
done

# Aplica ao /etc/skel para novos usuários
# Apply to /etc/skel for new users
mkdir -p /etc/skel/.thunderbird
cp -rT "$MODELO" /etc/skel/.thunderbird
cp -rT "$prof" /etc/skel/.thunderbird
