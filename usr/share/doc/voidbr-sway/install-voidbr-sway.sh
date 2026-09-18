#!/usr/bin/env bash

# ----------------------------------------------------------------------------------------
#
# Autor: Fernando Souza - https://www.youtube.com/@fernandosuporte/
#
#             
# Descrição:       Script para instalar novas configurações do Sway no VoidBR.
#
# Atualização em:  https://gitlab.com/slackvoid/voidbr-sway
# Script:          install-voidbr-sway.sh
# Versão:          1.0 (09/09/2026)
# License:         MIT
#
# ----------------------------------------------------------------------------------------


# Testes realizados em modo live.

clear

log="/tmp/voidbr-sway.log"


# Zerando o log.

: > "$log"


set -o pipefail

# ----------------------------------------------------------------------------------------

export TEXTDOMAIN="voidbr-sway"
export TEXTDOMAINDIR=/usr/share/locale

# ----------------------------------------------------------------------------------------

# Detectar idioma do sistema e definir mensagens (i18n)

case "$LANG" in

    pt_BR* )
        msg="O programa gettext não está instalado. Por favor, instale para continuar."
        ;;

    pt_PT* | pt* )
        msg="O programa gettext não está instalado. Por favor, instale-o para continuar."
        ;;

    es* )
        msg="El programa gettext no está instalado. Por favor, instálelo para continuar."
        ;;

    fr* )
        msg="Le programme gettext n'est pas installé. Veuillez l'installer pour continuer."
        ;;

    de* )
        msg="Das Programm gettext ist nicht installiert. Bitte installieren Sie es, um fortzufahren."
        ;;

    it* )
        msg="Il programma gettext non è installato. Per favore, installalo per continuare."
        ;;

    ja* )
        msg="gettext プログラムがインストールされていません。続行するにはインストールしてください。"
        ;;

    ru* )
        msg="Программа gettext не установлена. Пожалуйста, установите её, чтобы продолжить."
        ;;

    zh* )
        msg="未安装 gettext 程序。请安装后再继续。"
        ;;

    en* | * )
        msg="The gettext program is not installed. Please install it to continue."
        ;;
esac


# ----------------------------------------------------------------------------------------

# Verifica se o gettext está instalado

if ! command -v gettext &> /dev/null; then

    echo -e "\n$msg \n"

    exit 1

fi

# ----------------------------------------------------------------------------------------


# Verificar se o sistema possui o xbps-install, uma forma prática de confirmar que está 
# em um sistema baseado no Void Linux.


if ! command -v xbps-install >/dev/null 2>&1; then

    echo "$(gettext "O gerenciador de pacotes XBPS não foi encontrado. Este script requer o Void Linux.")"

    exit 1
fi


# ----------------------------------------------------------------------------------------

cd "$HOME" || exit 1


echo -e "\n$(gettext "==================== Atualizador de configuração do VoidBR Sway") ====================\n"


# Verificar se o arquivo existe

if [ ! -f voidbr-sway.tar.gz ]; then

echo -e "\n$(gettext "Arquivo voidbr-sway.tar.gz não foi localizado na pasta atual...")\n"

exit

fi

# ----------------------------------------------------------------------------------------


sudo rm -Rf /tmp/voidbr-sway



echo -e "\n$(gettext "Descompactando o arquivo voidbr-sway.tar.gz...")\n"


if ! sudo tar -zxpvf voidbr-sway.tar.gz -C /tmp >>"$log" 2>&1; then

    echo "$(gettext "Não foi possível descompactar o arquivo voidbr-sway.tar.gz.")"

    exit 1

fi



# Verificação dos diretórios essenciais:

if [ ! -d /tmp/voidbr-sway/etc ] || [ ! -d /tmp/voidbr-sway/usr ]; then

    echo "$(gettext "A estrutura do pacote voidbr-sway.tar.gz é inválida.")"

    exit 1

fi




# Porque o cd pode falhar e fazer o restante do script operar no diretório errado.

cd /tmp/voidbr-sway || exit 1


# ----------------------------------------------------------------------------------------

echo -e "\n$(gettext "Removendo configurações padrão atuais...")\n"

sudo rm -Rf /etc/skel/.config/autostart/* 2>> "$log"

sudo rm -Rf \
/etc/skel/.config/wofi \
/etc/skel/.config/foot \
/etc/skel/.config/sway \
/etc/skel/.config/Thunar \
/etc/skel/.config/dconf \
/etc/skel/.config/waybar \
/etc/skel/.config/autostart \
/etc/skel/.config/gtk-3.0 \
/etc/skel/.config/gtk-4.0 \
/etc/skel/.config/nwg-bar \
/etc/skel/.config/nwg-launchers \
/etc/skel/.config/xsettingsd \
/etc/skel/.config/mimeapps.list \
/etc/skel/.config/user-dirs.dirs \
/etc/skel/.config/mozilla \
/etc/skel/.local/share/backgrounds \
/etc/skel/"Área de trabalho" \
/etc/skel/Desktop \
/etc/skel/.dircolors \
/etc/skel/.gtkrc-2.0 \
2>> "$log"

# Apaga a configuração antiga antes de ter certeza de que a nova configuração será instalada.


# Vamos rezar para São Tux para o cp não FALHA :)

# ----------------------------------------------------------------------------------------


echo -e "\n$(gettext "Atualizando configurações padrão...")\n"

# Importante: "cp -a" preserva o proprietário dos arquivos de origem. 


if ! sudo cp -a etc / >>"$log" 2>&1; then

    echo "$(gettext "Não foi possível atualizar os arquivos de /etc.")"

    exit 1
fi

if ! sudo cp -a usr / >>"$log" 2>&1; then

    echo "$(gettext "Não foi possível atualizar os arquivos de /usr.")"

    exit 1
fi

# ----------------------------------------------------------------------------------------


cd "$HOME" || exit 1


msg="$(gettext "Removendo configurações atuais do usuário %s...")"

echo -e "\n$(printf "$msg" "$USER")\n"


# Se a intenção é substituir completamente (Firefox):

pkill -f firefox

if [ -d "$HOME/.config/mozilla" ]; then

msg="$(gettext "Fazendo backup das configurações do Firefox do usuário %s salvando como: %s...")"

echo -e "\n$(printf "$msg" "$USER" "mozilla-$(date +%d-%m-%Y-%H-%M)" )\n"


mv "$HOME/.config/mozilla"  "$HOME/.config/mozilla-$(date +%d-%m-%Y-%H-%M)" 

fi



rm -Rf \
"$HOME/.config/wofi" \
"$HOME/.config/foot" \
"$HOME/.config/sway" \
"$HOME/.config/Thunar" \
"$HOME/.config/dconf" \
"$HOME/.config/waybar" \
"$HOME/.local/share/backgrounds" \
"$HOME/.config/autostart" \
"$HOME/.config/gtk-3.0" \
"$HOME/.config/gtk-4.0" \
"$HOME/.config/nwg-bar" \
"$HOME/.config/nwg-launchers" \
"$HOME/.config/xsettingsd" \
"$HOME/.config/mimeapps.list" \
"$HOME/.config/user-dirs.dirs" \
"$HOME/.dircolors" \
"$HOME/.gtkrc-2.0" \
2>> "$log"





# cp: não foi possível abrir '/etc/skel/.config/Thunar/uca.xml' para leitura: Permissão negada

# ls -l /etc/skel/.config/Thunar/uca.xml
# -rw------- 1 root root 736 set  9 06:44 /etc/skel/.config/Thunar/uca.xml


sudo chmod 644    /etc/skel/.config/Thunar/uca.xml

# sudo chmod -R 755 /etc/skel/.config/mozilla

sudo chmod 644    /etc/skel/.config/mimeapps.list
sudo chmod 644    /etc/skel/.config/user-dirs.dirs
sudo chmod 755    /etc/skel/.config/gtk-3.0



msg="$(gettext "Definindo novas configurações para o usuário %s...")"

echo -e "\n$(printf "$msg" "$USER")\n"

mkdir -p "$HOME/.config/"

cp -a /etc/skel/.config/wofi            "$HOME/.config/"   2>> "$log"
cp -a /etc/skel/.config/foot            "$HOME/.config/"   2>> "$log"
cp -a /etc/skel/.config/sway            "$HOME/.config/"   2>> "$log"
cp -a /etc/skel/.config/Thunar          "$HOME/.config/"   2>> "$log"
cp -a /etc/skel/.config/dconf           "$HOME/.config/"   2>> "$log"
cp -a /etc/skel/.config/waybar          "$HOME/.config/"   2>> "$log"
cp -a /etc/skel/.config/autostart       "$HOME/.config/"   2>> "$log"
cp -a /etc/skel/.config/gtk-3.0         "$HOME/.config/"   2>> "$log"
cp -a /etc/skel/.config/gtk-4.0         "$HOME/.config/"   2>> "$log"

cp -a /etc/skel/.config/mozilla         "$HOME/.config/"   2>> "$log"

cp -a /etc/skel/.config/nwg-bar         "$HOME/.config/"   2>> "$log"
cp -a /etc/skel/.config/nwg-launchers   "$HOME/.config/"   2>> "$log"
cp -a /etc/skel/.config/xsettingsd      "$HOME/.config/"   2>> "$log"
cp -a /etc/skel/.config/mimeapps.list   "$HOME/.config/"   2>> "$log"
cp -a /etc/skel/.config/user-dirs.dirs  "$HOME/.config/"   2>> "$log"
cp -a /etc/skel/.dircolors              "$HOME/"           2>> "$log"
cp -a /etc/skel/.gtkrc-2.0              "$HOME/"           2>> "$log"
cp -r /etc/skel/Modelos                 "$HOME/"           2>> "$log"

# ----------------------------------------------------------------------------------------

echo "$(gettext "Configurando Área de trabalho para outros ambientes...")"


# Preservar os arquivos existentes do usuário
# Depois adicionar os novos atalhos padrão.


mkdir -p "$HOME/Desktop"


if [ -d "$HOME/Área de trabalho" ]; then

    msg="$(gettext "Movendo os arquivos de %s para %s...")"

    echo -e "\n$(printf "$msg" "$HOME/Área de trabalho" "$HOME/Desktop")\n"

    # Para mover arquivos ocultos, usando dotglob

    # dotglob é uma opção interna do Bash, usada com shopt.

    shopt -s dotglob nullglob

    mv "$HOME/Área de trabalho"/* "$HOME/Desktop/" 2>>"$log"

    shopt -u dotglob nullglob


    rm -rf "$HOME/Área de trabalho"

fi




echo "$(gettext "Atualizando a Área de trabalho com novos atalhos...")"

cp -a /etc/skel/Desktop/. "$HOME/Desktop/" 2>>"$log"



cp /usr/share/applications/void-install.desktop "$HOME/Desktop/"
cp /usr/share/applications/voidbr-setup.desktop "$HOME/Desktop/"
cp /usr/share/applications/voidbr.desktop       "$HOME/Desktop/"

# ----------------------------------------------------------------------------------------

echo "$(gettext "Atualizando o papel de parede padrão...")"

mkdir -p "$HOME/.local/share"

cp -a /etc/skel/.local/share/backgrounds  "$HOME/.local/share"   2>> "$log"

# ----------------------------------------------------------------------------------------

echo -e "\n$(gettext "Fechando o Thunar...")\n"

sleep 2

pkill -f thunar

thunar -q 2>>"$log"


sudo rm -Rf /tmp/voidbr-sway


# clear

# echo $?

# ----------------------------------------------------------------------------------------


if command -v swaymsg >/dev/null 2>&1; then


echo -e "\n$(gettext "Reiniciando o Sway...")\n"


# O swaymsg reload não substitui o logout

# Recarrega a configuração do Sway que já está em execução, mas não necessariamente faz 
# com que todas as configurações que foram copiadas sejam reaplicadas:

# GTK 3/4
# dconf
# Waybar
# autostart
# MIME associations
# user directories
# Xsettingsd
# configurações do Thunar

if swaymsg reload; then

    echo "$(gettext "Configurações do Sway recarregadas com sucesso.")"

else

    echo "$(gettext "Não foi possível recarregar as configurações do Sway.")"

fi



fi

# ----------------------------------------------------------------------------------------


# Arquivo gerando problema com usuários novos

sudo rm -f /etc/skel/.config/gtk-3.0/bookmarks



sudo chown -R root:root /etc/skel/

sudo chmod -R 755 /etc/skel/


sudo update-desktop-database /usr/share/applications/

update-desktop-database ~/.local/share/applications/


# ----------------------------------------------------------------------------------------


msg="$(gettext "Recomenda-se que o usuário %s efetue logout para que as novas configurações sejam aplicadas 
e validadas corretamente.


Arquivo de log: $log")"

echo -e "\n$(printf "$msg" "$USER")\n"


# cat  "$log"




exit 0

