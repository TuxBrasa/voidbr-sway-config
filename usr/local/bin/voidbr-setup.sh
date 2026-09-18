#!/usr/bin/env bash

# ----------------------------------------------------------------------------------------
#
# Autor: 
#          Fernando Souza - https://www.youtube.com/@fernandosuporte/
#
# Nome: 
#           
# Descrição:
#
# VoidBR Setup
#
# Ferramenta de configuração do VoidBR para Void Linux + Sway
#
# Mantendo-o leve e sem criar dependências pesadas.   
#
# Atualização em:  https://gitlab.com/slackvoid/voidbr-sway
#                  https://github.com/VoidLinuxBR/voidbr-sway-config
# Script:          
# Versão:          1.0.0 (09/09/2026)
# License:         MIT
#
# ----------------------------------------------------------------------------------------


# https://www.vivaolinux.com.br/script/pos-instalacao-kubuntush/




set -u

VERSION="1.0.0"

# Cores
RESET='\033[0m'
BOLD='\033[1m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BLUE='\033[34m'
WHITE='\033[97m'

clear_screen() {
    clear
}

pause() {
    echo
    read -rp "$(gettext "Pressione Enter para continuar...")"
}

header() {

    clear_screen

    echo -e "${CYAN}${BOLD}"
    echo "╭────────────────────────────────────────────╮"
    echo "│                                            │"
    echo "│                 VoidBR                     │"
    echo "│                                            │"
    echo "│          $(gettext "Configuração do sistema")           │"
    echo "│                                            │"
    echo "│                                            │"
    echo "│ https://www.voidbr.org/                    │"
    echo "│                                            │"
    echo "╰────────────────────────────────────────────╯"
    echo -e "${RESET}"
}

is_root() {
    [ "$(id -u)" -eq 0 ]
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

run_root() {
    if is_root; then
        "$@"
    elif command_exists sudo; then
        sudo "$@"
    elif command_exists doas; then
        doas "$@"
    else
        echo -e "${RED}$(gettext "Erro"):${RESET} $(gettext "sudo ou doas não encontrado.")"
        return 1
    fi
}

# ─────────────────────────────────────────────
# Informações
# ─────────────────────────────────────────────

system_info() {

    header

    echo -e "${BOLD}$(gettext "Informações do sistema")${RESET}"
    echo

    echo -e "$(gettext "Distribuição"):  ${GREEN}Void Linux${RESET}"

    if [ -f /etc/void-release ]; then
        echo "$(gettext "Versão"):        $(cat /etc/void-release)"
    fi

    echo "$(gettext "Arquitetura"):   $(uname -m)"
    echo "$(gettext "Kernel"):        $(uname -r)"

    if command_exists sway; then
        echo "$(gettext "Sway"):          $(sway --version 2>/dev/null | head -n1)"
    else
        echo -e "$(gettext "Sway"):          ${YELLOW}$(gettext "não instalado")${RESET}"
    fi

    if command_exists pipewire; then
        echo -e "$(gettext "PipeWire"):      ${GREEN}$(gettext "instalado")${RESET}"
    else
        echo -e "$(gettext "PipeWire"):      ${YELLOW}$(gettext "não instalado")${RESET}"
    fi

    if command_exists waybar; then
        echo -e "$(gettext "Waybar"):        ${GREEN}$(gettext "instalado")${RESET}"
    else
        echo -e "$(gettext "Waybar"):        ${YELLOW}$(gettext "não instalado")${RESET}"
    fi

    if command_exists NetworkManager; then
        echo -e "$(gettext "NetworkManager"): ${GREEN}$(gettext "instalado")${RESET}"
    else
        echo -e "$(gettext "NetworkManager"): ${YELLOW}$(gettext "não instalado")${RESET}"
    fi

    echo

    if [ -n "${XDG_SESSION_TYPE:-}" ]; then
        echo "$(gettext "Sessão"):        $XDG_SESSION_TYPE"
    fi

    if [ -n "${WAYLAND_DISPLAY:-}" ]; then
        echo "$(gettext "Wayland"):       $WAYLAND_DISPLAY"
    fi

    pause
}

# ─────────────────────────────────────────────
# Idioma
# ─────────────────────────────────────────────

language_menu() {

    header

    echo -e "${BOLD}$(gettext "Idioma e teclado")${RESET}"
    echo
    echo "1) $(gettext "Português do Brasil")"
    echo "2) $(gettext "Inglês")"
    echo "3) $(gettext "Espanhol")"
    echo "4) $(gettext "Voltar")"
    echo

    read -rp "$(gettext "Escolha"): " choice

    case "$choice" in
        1)
            run_root localectl set-locale LANG=pt_BR.UTF-8 2>/dev/null || {
                echo "LANG=pt_BR.UTF-8" | run_root tee /etc/locale.conf >/dev/null
            }

            echo -e "${GREEN}$(gettext "Português do Brasil configurado.")${RESET}"
            ;;
        2)
            run_root localectl set-locale LANG=en_US.UTF-8 2>/dev/null || {
                echo "LANG=en_US.UTF-8" | run_root tee /etc/locale.conf >/dev/null
            }

            echo -e "${GREEN}$(gettext "Inglês configurado.")${RESET}"
            ;;
        3)
            run_root localectl set-locale LANG=es_ES.UTF-8 2>/dev/null || {
                echo "LANG=es_ES.UTF-8" | run_root tee /etc/locale.conf >/dev/null
            }

            echo -e "${GREEN}$(gettext "Espanhol configurado.")${RESET}"
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}$(gettext "Opção inválida.")${RESET}"
            ;;
    esac

    pause
}

# ─────────────────────────────────────────────
# Rede
# ─────────────────────────────────────────────

network_menu() {

    header

    echo -e "${BOLD}$(gettext "Rede")${RESET}"
    echo

    if command_exists nmcli; then

        echo "$(gettext "Interfaces"):"
        nmcli device status
        echo

        echo "$(gettext "Redes Wi-Fi"):"
        nmcli device wifi list 2>/dev/null || true

        echo
        read -rp "$(gettext "SSID para conectar (Enter para voltar)"): " ssid

        [ -z "$ssid" ] && return

        read -rsp "$(gettext "Senha"): " password
        echo

        echo -e "${CYAN}$(gettext "Conectando...")${RESET}"

        if nmcli device wifi connect "$ssid" password "$password"; then
            echo -e "${GREEN}$(gettext "Conectado com sucesso.")${RESET}"
        else
            echo -e "${RED}$(gettext "Não foi possível conectar.")${RESET}"
        fi

    else

        echo -e "${YELLOW}$(gettext "NetworkManager não está instalado.")${RESET}"
        echo
        echo "$(gettext "Instale com:")"
        echo
        echo "  sudo xbps-install -S NetworkManager"

    fi

    pause
}

# ─────────────────────────────────────────────
# Áudio
# ─────────────────────────────────────────────

audio_menu() {

    header

    echo -e "${BOLD}$(gettext "Áudio")${RESET}"
    echo

    if command_exists wpctl; then

        echo "$(gettext "Dispositivos"):"
        wpctl status

        echo
        echo "$(gettext "Volume atual"):"
        wpctl get-volume @DEFAULT_AUDIO_SINK@

        echo
        echo "1) $(gettext "Aumentar volume")"
        echo "2) $(gettext "Diminuir volume")"
        echo "3) $(gettext "Silenciar")"
        echo "4) $(gettext "Abrir mixer")"
        echo "5) $(gettext "Voltar")"
        echo

        read -rp "$(gettext "Escolha"): " choice

        case "$choice" in
            1)
                wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
                ;;
            2)
                wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
                ;;
            3)
                wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
                ;;
            4)
                if command_exists pavucontrol; then
                    pavucontrol &
                else
                    echo "$(gettext "pavucontrol não está instalado.")"
                fi
                ;;
            5)
                return
                ;;
        esac

    else
        echo -e "${YELLOW}$(gettext "wpctl não encontrado.")${RESET}"
        echo "$(gettext "Verifique se PipeWire/WirePlumber está instalado.")"
    fi

    pause
}

# ─────────────────────────────────────────────
# Bluetooth
# ─────────────────────────────────────────────

bluetooth_menu() {

    header

    echo -e "${BOLD}$(gettext "Bluetooth")${RESET}"
    echo

    if ! command_exists bluetoothctl; then
        echo -e "${YELLOW}$(gettext "bluetoothctl não está instalado.")${RESET}"
        echo
        echo "$(gettext "Instale o pacote bluez.")"
        pause
        return
    fi

    echo "$(gettext "Dispositivos"):"

    bluetoothctl devices

    echo
    echo "1) $(gettext "Ligar Bluetooth")"
    echo "2) $(gettext "Desligar Bluetooth")"
    echo "3) $(gettext "Procurar dispositivos")"
    echo "4) $(gettext "Voltar")"
    echo

    read -rp "$(gettext "Escolha"): " choice

    case "$choice" in
        1)
            bluetoothctl power on
            ;;
        2)
            bluetoothctl power off
            ;;
        3)
            bluetoothctl scan on
            sleep 5
            bluetoothctl scan off
            ;;
        4)
            return
            ;;
    esac

    pause
}

# ─────────────────────────────────────────────
# Atualização
# ─────────────────────────────────────────────

update_system() {

    header

    echo -e "${BOLD}$(gettext "Atualização do sistema")${RESET}"
    echo

    echo -e "${CYAN}$(gettext "Sincronizando repositórios...")${RESET}"

    if ! run_root xbps-install -S; then
        echo -e "${RED}$(gettext "Falha ao sincronizar os repositórios.")${RESET}"
        pause
        return
    fi

    echo
    echo -e "${CYAN}$(gettext "Verificando atualizações...")${RESET}"

    xbps-install -Mun

    echo
    read -rp "$(gettext "Deseja atualizar o sistema? [s/N]") " answer

    case "$answer" in
        s|S|sim|SIM)
            run_root xbps-install -Su
            ;;
        *)
            echo "$(gettext "Atualização cancelada.")"
            ;;
    esac

    pause
}

# ─────────────────────────────────────────────
# Aparência
# ─────────────────────────────────────────────

appearance_menu() {

    header

    echo -e "${BOLD}$(gettext "Aparência VoidBR")${RESET}"
    echo

    echo "1) $(gettext "Restaurar configuração Sway (Gerenciador de Janelas)")"
    echo "2) $(gettext "Restaurar Waybar (Painel)")"
    echo "3) $(gettext "Restaurar Firefox")"
    echo "4) $(gettext "Restaurar Thunar (Gerenciador de arquivos)")"
    echo "5) $(gettext "Restaurar Mako (Gerenciador de Notificações)")"
    echo "6) $(gettext "Restaurar Foot (Terminal)")"
    echo "7) $(gettext "Restaurar Wofi (lançador de programas)")"
    echo "8) $(gettext "Restaurar nwggrid (lançador de programas)")"
    echo "9) $(gettext "Restaurar nwg-bar (menu para desligar, reiniciar...)")"
    echo "10) $(gettext "Restaurar configurações de programas padrão")"
    echo "11) $(gettext "Restaurar o arquivo .bashrc")"
    echo "12) $(gettext "Restaurar TODO o padrão")"
    echo "13) $(gettext "Restaurar LibreOffice")"
    echo "0) $(gettext "Voltar")"
    echo

    read -rp "$(gettext "Escolha"): " choice

    case "$choice" in

        1)
            if [ -f /etc/skel/.config/sway/config ]; then

                mkdir -p "$HOME/.config/sway"

                cp /etc/skel/.config/sway/config "$HOME/.config/sway/config"

                echo -e "${GREEN}$(gettext "Configuração do Sway restaurada.")${RESET}"

            else

                echo -e "${YELLOW}$(gettext "Configuração VoidBR do Sway não encontrada.")${RESET}"

            fi

            ;;

        2)
            if [ -d /etc/skel/.config/waybar ]; then

                mkdir -p "$HOME/.config/waybar"

                cp -a /etc/skel/.config/waybar/* "$HOME/.config/waybar/"

                echo -e "${GREEN}$(gettext "Configuração da Waybar restaurada.")${RESET}"

            else

                echo -e "${YELLOW}$(gettext "Configuração VoidBR da Waybar não encontrada.")${RESET}"

            fi

            ;;

        3)
            if [ -d /etc/skel/.config/mozilla ]; then

                rm -Rf "$HOME/.config/mozilla"

                cp -a /etc/skel/.config/mozilla "$HOME/.config/"

                echo -e "${GREEN}$(gettext "Configuração do Firefox restaurada.")${RESET}"

            else

                echo -e "${YELLOW}$(gettext "Configuração VoidBR para o Firefox não encontrada.")${RESET}"

            fi

            ;;

        4)
            if [ -d /etc/skel/.config/Thunar ]; then

                rm -Rf "$HOME/.config/Thunar"

                cp -a /etc/skel/.config/Thunar "$HOME/.config/"

                echo -e "${GREEN}$(gettext "Configuração do Thunar restaurada.")${RESET}"

                thunar -q

            else

                echo -e "${YELLOW}$(gettext "Configuração VoidBR para o Thunar não encontrada.")${RESET}"

            fi

            ;;

        5)
            if [ -d /etc/skel/.config/mako/ ]; then

                rm -Rf "$HOME/.config/mako"

                cp -a /etc/skel/.config/mako "$HOME/.config/"

                echo -e "${GREEN}$(gettext "Configuração do Mako restaurada.")${RESET}"

                pkill -f mako

                sleep 1

                mako &

notify-send -u low   -t 200000 "VoidBR - teste de notificação" "Esta é uma mensagem de baixa urgência"

notify-send -u normal -t 200000 "VoidBR - teste de notificação" "Esta é uma mensagem normal"

notify-send -u critical \
-t 200000 \
"Esta é uma mensagem crítica!" \
"OK, isso foi apenas uma demonstração ;)"


            else

                echo -e "${YELLOW}$(gettext "Configuração VoidBR para o Mako não encontrada.")${RESET}"

            fi

            ;;

        6)

            # Configuração do Terminal (Foot)
            # Configuração de transparência.

            if [ -d /etc/skel/.config/foot/ ]; then

                rm -Rf "$HOME/.config/foot"

                cp -a /etc/skel/.config/foot "$HOME/.config/"

                echo -e "${GREEN}$(gettext "Configuração do Foot restaurada.")${RESET}"

                pkill -f foot

            else

                echo -e "${YELLOW}$(gettext "Configuração VoidBR para o Foot não encontrada.")${RESET}"
            fi

            ;;

        7)
            # Configuração para Wofi

            if [ -d /etc/skel/.config/wofi/ ]; then

                rm -Rf "$HOME/.config/wofi"

                cp -a /etc/skel/.config/wofi "$HOME/.config/"

                echo -e "${GREEN}$(gettext "Configuração do Wofi restaurada.")${RESET}"

                pkill -f wofi


            else

                echo -e "${YELLOW}$(gettext "Configuração VoidBR para o Wofi não encontrada.")${RESET}"
            fi

            ;;


        8)
            # Configuração para nwggrid

            if [ -d /etc/skel/.config/nwg-launchers/nwggrid/ ]; then

                rm -Rf "$HOME/.config/nwg-launchers/nwggrid"

                mkdir -p $HOME/.config/nwg-launchers/

                cp -a /etc/skel/.config/nwg-launchers/nwggrid  "$HOME/.config/nwg-launchers/"

                echo -e "${GREEN}$(gettext "Configuração do nwggrid restaurada.")${RESET}"

                pkill -f nwggrid

            else

                echo -e "${YELLOW}$(gettext "Configuração VoidBR para o nwggrid não encontrada.")${RESET}"
            fi

            ;;


        9)
            # Configuração para nwg-bar

            if [ -d /etc/skel/.config/nwg-bar/ ]; then

                rm -Rf "$HOME/.config/nwg-bar"

                cp -a /etc/skel/.config/nwg-bar "$HOME/.config/"

                echo -e "${GREEN}$(gettext "Configuração do nwg-bar restaurada.")${RESET}"

                pkill -f nwg-bar

            else

                echo -e "${YELLOW}$(gettext "Configuração VoidBR para o nwg-bar não encontrada.")${RESET}"
            fi

            ;;


        10)
            # Arquivo /etc/skel/.config/mimeapps.list

            if [ -e /etc/skel/.config/mimeapps.list ]; then

                rm -f "$HOME/.config/mimeapps.list"

                cp -a /etc/skel/.config/mimeapps.list "$HOME/.config/"

                echo -e "${GREEN}$(gettext "Configurações de programas padrão restaurada.")${RESET}"


            else

                echo -e "${YELLOW}$(gettext "Configuração VoidBR para programas padrão não encontrada.")${RESET}"
            fi

            ;;


        11)
            # Arquivo /etc/skel/.bashrc

            if [ -e /etc/skel/.bashrc ]; then

                rm -f "$HOME/.bashrc"

                cp -a /etc/skel/.bashrc "$HOME/"

                echo -e "${GREEN}$(gettext "Arquivo .bashrc restaurado.")${RESET}"


            else

                echo -e "${YELLOW}$(gettext "Arquivo .bashrc não encontrado.")${RESET}"
            fi

            ;;


        12)
            # Restaura tudo

            if [ -d /etc/skel/ ]; then

                rm -f "$HOME/.*"

                cp -a /etc/skel/*  "$HOME/"
                cp -a /etc/skel/.* "$HOME/"

                echo -e "${GREEN}$(gettext "Restaurado.")${RESET}"


            else

                echo -e "${YELLOW}$(gettext "Não foi possível restaura tudo.")${RESET}"
            fi

            ;;



        13)
            # Restaura LibreOffice

            clear

            if [ -d /etc/skel/.config/libreoffice ]; then

                echo -e "\n$(gettext "Pasta em /etc/skel:")\n"
                ls -l /etc/skel/.config/libreoffice

                rm -Rf "$HOME/.config/libreoffice"

                cp -r /etc/skel/.config/libreoffice  "$HOME/.config/"

                echo -e "\n$(gettext "Pasta em $HOME:")\n"

                ls -l $HOME/.config/libreoffice

                echo -e "\n${GREEN}$(gettext "Restaurado o LibreOffice.")${RESET}\n"


            else

                echo -e "${YELLOW}$(gettext "Não foi possível restaura as configurações padrão do LibreOffice.")${RESET}"
            fi

            ;;






        0)
            return
            ;;
    esac

    pause
}

# ─────────────────────────────────────────────
# Sway
# ─────────────────────────────────────────────

sway_menu() {

    header

    echo -e "${BOLD}$(gettext "Sway")${RESET}"
    echo

    echo "$(gettext "Atalhos principais"):"
    echo
    echo -e "${CYAN}Super + Enter${RESET}       $(gettext "Terminal")"
    echo -e "${CYAN}Super + D${RESET}           $(gettext "Menu de Programas")"
    echo -e "${CYAN}Super + E${RESET}           $(gettext "Arquivos")"
    echo -e "${CYAN}Super + B${RESET}           $(gettext "Navegador")"
    echo -e "${CYAN}Super + I${RESET}           $(gettext "Instalador")"
    echo -e "${CYAN}Super + Q${RESET}           $(gettext "Fechar janela")"
    echo -e "${CYAN}Super + Shift + Q${RESET}   $(gettext "Sair do Sway")"
    echo -e "${CYAN}Print${RESET}               $(gettext "Screenshot")"

    echo
    echo "1) $(gettext "Restaurar configuração")"
    echo "2) $(gettext "Recarregar Sway")"
    echo "3) $(gettext "Voltar")"
    echo

    read -rp "$(gettext "Escolha"): " choice

    case "$choice" in
        1)
            appearance_menu
            ;;
        2)
            if command_exists swaymsg; then
                swaymsg reload
                echo -e "${GREEN}$(gettext "Sway recarregado.")${RESET}"
            fi
            pause
            ;;
        3)
            return
            ;;
    esac
}

# ─────────────────────────────────────────────
# Relatório
# ─────────────────────────────────────────────

system_report() {

    header

    echo -e "${BOLD}$(gettext "Relatório VoidBR")${RESET}"
    echo

    echo "$(gettext "VoidBR System Report")"
    echo "===================="
    echo
    echo "$(gettext "Kernel"):      $(uname -r)"
    echo "$(gettext "Arquitetura"): $(uname -m)"

    if [ -f /etc/void-release ]; then
        echo "$(gettext "Void Linux"):  $(cat /etc/void-release)"
    fi

    echo "$(gettext "Sessão"):      ${XDG_SESSION_TYPE:-desconhecida}"
    echo "$(gettext "Desktop"):     ${XDG_CURRENT_DESKTOP:-desconhecido}"

    echo
    echo "$(gettext "Sway"):"
    if command_exists sway; then
        sway --version 2>/dev/null | head -n1
    else
        echo "$(gettext "não instalado")"
    fi

    echo
    echo "$(gettext "Áudio"):"
    if command_exists pipewire; then
        echo "$(gettext "PipeWire instalado")"
    else
        echo "$(gettext "PipeWire não encontrado")"
    fi

    echo
    echo "$(gettext "Rede"):"
    if command_exists nmcli; then
        nmcli device status
    else
        echo "$(gettext "NetworkManager não encontrado")"
    fi

    echo
    pause
}


# ─────────────────────────────────────────────
# Cria novos usuários
# ─────────────────────────────────────────────

cria_usuario() {

    clear

    header

    echo -e "${BOLD}$(gettext "Criar usuário")${RESET}"
    echo
    echo "$(gettext "Nome do usuário")"
    read usuario

    if [ -z "$usuario" ]; then

    clear

    exit

    fi

    # Verificar

    teste=$(grep "$usuario" /etc/passwd | cut -d: -f1)


    if [ "$teste" != "$usuario" ]; then

# No useradd, a opção -m significa criar o diretório home caso ele não exista. Ao criar o 
# home, o useradd copia o conteúdo de /etc/skel para ele.

    sudo useradd -m "$usuario"
    sudo passwd "$usuario"

    # A pasta /home/$usuario é criada, mas as pastas padrão (Desktop, Documents, Downloads, Music, Pictures, Videos) não são criadas.

    # sudo xbps-install -Suvy xdg-user-dirs

    sudo -u "$usuario" xdg-user-dirs-update

# Melhor criar as pastas em /etc/skel assim todo usuário novo já venha com Documentos, 
# Downloads, Música, Imagens, Vídeos, Público, Desktop e Projetos.

# sudo mkdir -p /etc/skel/Desktop
# sudo mkdir -p /etc/skel/Downloads
# sudo mkdir -p /etc/skel/Documentos
# sudo mkdir -p /etc/skel/Músicas
# sudo mkdir -p /etc/skel/Imagens
# sudo mkdir -p /etc/skel/Vídeos
# sudo mkdir -p /etc/skel/Público
# sudo mkdir -p /etc/skel/Projetos



    # Arquivo gerando problema com usuários novos

    sudo rm -f /etc/skel/.config/gtk-3.0/bookmarks


    # if [ -f /home/$usuario/.config/gtk-3.0/bookmarks ]; then

    #    echo "$(gettext "Corrigindo o arquivo /home/$usuario/.config/gtk-3.0/bookmarks para $usuario")"

    #    sed "s/anon/$usuario/g" /home/$usuario/.config/gtk-3.0/bookmarks

    # fi


    else

    clear

    echo "$(gettext "Usuário $usuario já existe no sistema.")"

    fi

    pause
}



# ─────────────────────────────────────────────
# Lista usuários
# ─────────────────────────────────────────────

list() {

    clear

    header

    echo -e "${BOLD}$(gettext "Lista de usuários:")${RESET}"
    echo

    teste=$(grep -Ev 'nologin|false' /etc/passwd | cut -d: -f1)

    echo -e "$(gettext "\n$teste")"

    pause
}



# ─────────────────────────────────────────────
# Lista usuários
# ─────────────────────────────────────────────

remove_usuario() {

    clear

    header

    echo -e "${BOLD}$(gettext "Remove usuário")${RESET}"
    echo


    echo -e "${BOLD}$(gettext "Lista de usuários:")${RESET}"
    echo

    teste=$(grep -Ev 'nologin|false' /etc/passwd | cut -d: -f1)

    echo "$teste"

    echo -e "\n$(gettext "Qual o nome do usuário?")"
    read usuario

    if [ -z "$usuario" ]; then

       clear

       exit

    fi
    

    atual="$(whoami)"

    if [ "$atual" == "$usuario" ]; then

       clear

       exit

    fi


    # 10 primeiros Processos do usuário

    # ps -aux | grep -i  $usuario | head  -n 10


    # Se estiver em uma sessão gráfica e quiser encerrar uma sessão específica:

    # sudo loginctl terminate-user "$usuario"

    # Funciona tanto via TTY quanto via cron, desde que o processo tenha as permissões necessárias.


    # Primeiro encerre os processos dele:

    sudo pkill -TERM -u "$usuario"

    sleep 5

    sudo pkill -KILL -u "$usuario"


    # O -r remover o diretório home do usuário

    sudo userdel -r "$usuario"

    pause


}



# ─────────────────────────────────────────────
# Instalar programas - Void Linux
# ─────────────────────────────────────────────

# Instalar Clamav no Void Linux

# https://www.vivaolinux.com.br/dica/Instalar-Clamav-no-Void-Linux/


# ─────────────────────────────────────────────
# Instalar programas - Void Linux
# ─────────────────────────────────────────────

instalar_pacote() {

    local pacote="$1"

    # Verifica se o pacote já está instalado
    if xbps-query -l "$pacote" 2>/dev/null | grep -q "^ii $pacote-"; then
        echo
        echo -e "${YELLOW}$(gettext "Já instalado"):${RESET} $pacote"
        return 0
    fi

    echo
    echo -e "${BOLD}$(gettext "Instalando"):${RESET} $pacote"

    # Instala o pacote
    if sudo xbps-install -S "$pacote"; then
        echo
        echo -e "${GREEN}✓ $(gettext "Instalação concluída"):${RESET} $pacote"
    else
        echo
        echo -e "${RED}✗ $(gettext "Erro ao instalar"):${RESET} $pacote"
        return 1
    fi
}


# ─────────────────────────────────────────────
# Instalar programas
# ─────────────────────────────────────────────

instalar_programas() {

    while true; do

        clear

        echo -e "${BOLD}$(gettext "Instalar programas")${RESET}"
        echo
        echo "1) ClamAV"
        echo "2) Firefox ESR"
        echo "3) Foot"
        echo "4) Thunar"
        echo "5) Waybar"
        echo "6) Wofi"
        echo "7) Mako"
        echo "8) Sway"
        echo "9) Ferramentas de desenvolvimento"
        echo "10) Pacote multimídia"
        echo "11) Instalar vários programas"
        echo "12) Firefox"
        echo "13) Instalar ferramentas de descompactação"
        echo "14) Instalar codecs multimídia"
        echo "15) Instalar fontes da Microsoft (Não testado)"
        echo "16) Configurar Flatpak"
        echo "17) Instalação da Steam (Não testado)"
        echo "18) Instalar utilitários de sistema"
        echo "19) Instalar galculator"
        echo "20) Instalar audacity"
        echo "21) Instalar vlc"
        echo "22) Instalar gimp"
        echo "23) Instalar gparted"
        echo "24) Instalar inkscape"
        echo "25) Instalar qdiskinfo"
        echo "26) Instalar Thunderbird"
        echo "27) Instalar qbittorrent"
        echo "28) Instalar LibreOffice"
        echo "29) Instalar suporte a impressora "
        echo "30) Instalar Bluetooth"
        echo "31) Instalar Scribus"
        echo "32) Instalar "
        echo "33) Instalar "
        echo "100) Limpando pacotes órfãos e arquivos de pacotes desnecessários"
        echo "0) Voltar"
        echo

        read -rp "$(gettext "Escolha"): " choice

        clear

        case "$choice" in

            1)
                instalar_pacote clamav
                ;;

            2)
                instalar_pacote firefox-esr firefox-esr-i18n-pt-BR
                ;;

            3)
                instalar_pacote foot
                ;;

            4)
                instalar_pacote thunar
                ;;

            5)
                instalar_pacote Waybar
                ;;

            6)
                instalar_pacote wofi
                ;;

            7)
                instalar_pacote mako
                ;;

            8)
                instalar_pacote sway
                ;;

            9)
                for pacote in \
                    base-devel \
                    git \
                    gcc \
                    make \
                    pkg-config \
                    meson \
                    ninja
                do
                    instalar_pacote "$pacote"
                done
                ;;

            10)
                for pacote in \
                    ffmpeg \
                    mpv \
                    pavucontrol \
                    playerctl
                do
                    instalar_pacote "$pacote"
                done
                ;;

            11)
                echo
                read -rp "$(gettext "Digite os pacotes separados por espaço"): " packages

                if [ -z "$packages" ]; then
                    echo
                    echo -e "${YELLOW}$(gettext "Nenhum pacote informado.")${RESET}"
                else
                    for pacote in $packages; do
                        instalar_pacote "$pacote"
                    done
                fi
                ;;

            12)
                instalar_pacote firefox firefox-i18n-pt-BR
                ;;

            13) # rar arc arj  lhasa  unace

                instalar_pacote p7zip p7zip-full lzma lzop unrar zip unzip cabextract xz

                ;;

            14)

echo "-> Instalando pacotes de mídia..."

sudo xbps-install -S \
    ffmpeg \
    gstreamer1 \
    gst-plugins-base1 \
    gst-plugins-good1 \
    gst-plugins-bad1 \
    gst-plugins-ugly1 \
    gst-libav1 \
    gst-plugins-vaapi1 \
    libdvdread \
    libdvdnav \
    libbluray \
    lame \
    opus \
    libvorbis \
    libtheora \
    x264 \
    x265


# faad ffmpeg gstreamer1.0-fdkaac gstreamer1.0-libav gstreamer1.0-vaapi  lame libavcodec-extra libavcodec-extra61 libavdevice61 libgstreamer1.0-0 sox twolame vorbis-tools

echo "-> Codecs e plugins de mídia instalados!"

                ;;

            15)
                # fc-list | grep -Ei "Arial|Times New Roman|Courier New|Verdana|Georgia"


echo 'sudo xbps-install -S git xtools

cd ~
git clone https://github.com/void-linux/void-packages.git

cd ~/void-packages
./xbps-src binary-bootstrap

echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf

./xbps-src pkg msttcorefonts

sudo xbps-install --repository=hostdir/binpkgs/nonfree msttcorefonts

fc-cache -fv' |
yad \
    --title="Instalar fontes Microsoft no Void Linux" \
    --width=900 \
    --height=650 \
    --center \
    --text-info \
    --fontname="Monospace 11" \
    --button="Fechar:0"

                # echo "Atualizar o cache de fontes"
                # fc-cache -fv


                ;;

            16) # Flatpak

echo "-> Configurando Flatpak..."

sudo xbps-install -Sy flatpak

if flatpak remotes --columns=name 2>/dev/null | grep -qx "flathub"; then
    echo "-> Repositório Flathub já está configurado."
else
    echo "-> Repositório Flathub não encontrado."
    echo "-> Adicionando Flathub..."

    flatpak remote-add --if-not-exists \
        flathub \
        https://flathub.org/repo/flathub.flatpakrepo

    if flatpak remotes --columns=name 2>/dev/null | grep -qx "flathub"; then
        echo "-> Flathub adicionado com sucesso."
    else
        echo "ERRO: não foi possível adicionar o Flathub."
        exit 1
    fi
fi
                ;;



            17) # Para instalação da Steam

ARCH=$(uname -m)

if command -v ldd >/dev/null 2>&1; then
    LDD_INFO=$(ldd --version 2>&1 | head -n1)

    if printf '%s\n' "$LDD_INFO" | grep -qi 'musl'; then
        LIBC="musl"
    elif printf '%s\n' "$LDD_INFO" | grep -qi 'glibc'; then
        LIBC="glibc"
    else
        LIBC="desconhecida"
    fi
else
    LIBC="desconhecida"
fi

echo "-> Arquitetura: $ARCH"
echo "-> Libc: $LIBC"

if [ "$ARCH" = "x86_64" ] && [ "$LIBC" = "glibc" ]; then

    echo "-> Sistema x86_64 + glibc detectado."
    echo "-> Steam nativa disponível."
    echo "-> Verificando repositório nonfree..."

    if ! xbps-query -Rs '^void-repo-nonfree$' >/dev/null 2>&1; then
        echo "-> Instalando repositório nonfree..."
        sudo xbps-install -S void-repo-nonfree
    else
        echo "-> Repositório nonfree já está disponível."
    fi

    sudo xbps-install -S steam

elif [ "$LIBC" = "musl" ]; then

    echo "-> Sistema musl detectado."
    echo "-> A Steam nativa possui limitações nesse ambiente."
    echo "-> Recomenda-se utilizar Steam via Flatpak."

    flatpak install -y flathub com.valvesoftware.Steam

else

    echo "ERRO: não foi possível determinar a libc."
    exit 1
fi

                ;;

            18) # Instalar utilitários de sistema...

echo "-> Instalando utilitários de sistema (UFW, Timeshift, wget,ca-certificates)..."

sudo xbps-install -S ufw timeshift wget ca-certificates

if command -v ufw >/dev/null 2>&1; then
    echo "-> UFW instalado."

    echo "-> Verificando status do UFW..."

    sudo ufw status

    echo
    echo "-> Habilitando UFW..."

    sudo ufw --force enable

    echo "-> Status final do UFW:"
    sudo ufw status verbose
else
    echo "ERRO: UFW não foi instalado."
fi

if command -v timeshift >/dev/null 2>&1; then
    echo "-> Timeshift instalado."
else
    echo "ERRO: Timeshift não foi instalado."
fi


                ;;


            19)
                instalar_pacote galculator
                ;;

            20)
                instalar_pacote audacity
                ;;


            21)
                instalar_pacote vlc
                ;;

            22)
                instalar_pacote gimp
                ;;

            23)
                instalar_pacote gparted
                ;;


            24)
                instalar_pacote inkscape
                ;;

            25)
                clear

                echo "O QDiskInfo não estar disponível como pacote oficial do Void Linux"

                sleep 10

                # instalar_pacote qdiskinfo

                instalar_pacote smartmontools gsmartcontrol




                ;;


            26)
                instalar_pacote thunderbird thunderbird-i18n-pt-BR
                ;;

            27)
                instalar_pacote qbittorrent
                ;;

            28)
                instalar_pacote libreoffice libreoffice-i18n-pt-BR
                ;;

            29)
                instalar_pacote cups system-config-printer system-config-printer-udev cups-pdf epson-inkjet-printer-escpr foomatic-db foomatic-db-engine gutenprint

# Ativar o CUPS

sudo ln -s /etc/sv/cupsd /var/service/

                ;;

            30)
                #  Bluetooth

                 instalar_pacote  blueman blueprint-compiler bluez bluez-alsa bluez-obex libbluetooth libspa-bluetooth bluez-cups

# Ativar o Bluetooth

sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/bluetoothd /var/service/


sv status dbus
sv status bluetoothd


                ;;



            31) # Scribus

                instalar_pacote scribus
                ;;





            100) # Limpando pacotes órfãos e arquivos de pacotes desnecessários...

                sudo xbps-remove -Ooy
                ;;


            0)
                return
                ;;

            *)
                echo
                echo -e "${RED}$(gettext "Opção inválida.")${RESET}"
                ;;

        esac

        echo
        read -rp "$(gettext "Pressione ENTER para continuar...")"

    done
}





# ─────────────────────────────────────────────
# Menu principal
# ─────────────────────────────────────────────

main_menu() {

    while true; do

        header

        echo -e "${BOLD}$(gettext "O que você deseja configurar?")${RESET}"
        echo

        echo "1) $(gettext "Idioma e teclado")"
        echo "2) $(gettext "Rede")"
        echo "3) $(gettext "Áudio")"
        echo "4) $(gettext "Bluetooth")"
        echo "5) $(gettext "Aparência")"
        echo "6) $(gettext "Sway")"
        echo "7) $(gettext "Atualizar sistema")"
        echo "8) $(gettext "Informações do sistema")"
        echo "9) $(gettext "Relatório para suporte")"
        echo "10) $(gettext "Cria usuário")"
        echo "11) $(gettext "Lista usuários")"
        echo "12) $(gettext "Remove usuário")"
        echo "13) $(gettext "Instalar programas")"
        echo "0) $(gettext "Sair")"

        echo

        read -rp "$(gettext "Escolha"): " choice

        case "$choice" in
            1) language_menu ;;
            2) network_menu ;;
            3) audio_menu ;;
            4) bluetooth_menu ;;
            5) appearance_menu ;;
            6) sway_menu ;;
            7) update_system ;;
            8) system_info ;;
            9) system_report ;;
            10) cria_usuario ;;
            11) list ;;
            12) remove_usuario ;;
            13) instalar_programas ;;
            0)
                clear
                exit 0
                ;;
            *)
                echo -e "${RED}$(gettext "Opção inválida.")${RESET}"
                sleep 1
                ;;
        esac

    done
}

# ─────────────────────────────────────────────
# Argumentos
# ─────────────────────────────────────────────

case "${1:-}" in

    --version|-v)
        echo "voidbr-setup $VERSION"
        ;;

    --report)
        system_report
        ;;

    --info)
        system_info
        ;;

    --update)
        update_system
        ;;

    --help|-h)
        echo "$(gettext "VoidBR Setup") $VERSION"
        echo
        echo "$(gettext "Uso"):"
        echo "  voidbr-setup             $(gettext "Abrir configuração")"
        echo "  voidbr-setup --info      $(gettext "Informações do sistema")"
        echo "  voidbr-setup --report    $(gettext "Relatório para suporte")"
        echo "  voidbr-setup --update    $(gettext "Atualizar sistema")"
        echo "  voidbr-setup --version   $(gettext "Mostrar versão")"
        echo "  voidbr-setup --help      $(gettext "Mostrar ajuda")"
        ;;

    *)
        main_menu

        ;;

esac


