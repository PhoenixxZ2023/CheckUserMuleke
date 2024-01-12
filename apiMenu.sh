#!/bin/bash

cor_vermelha='\033[91m'
cor_verde='\033[92m'
cor_amarela='\033[93m'
cor_azul='\033[94m'
cor_reset='\033[0m'

adicionar_ao_cache() {
    chave=$1
    valor=$2
    cache=$(carregar_cache)
    cache["$chave"]=$valor
    salvar_cache "$cache"
}

remover_do_cache() {
    chave=$1
    cache=$(carregar_cache)
    if [[ -n "${cache[$chave]}" ]]; then
        unset "cache[$chave]"
        salvar_cache "$cache"
    fi
}

obter_do_cache() {
    chave=$1
    cache=$(carregar_cache)
    echo "${cache[$chave]}"
}

carregar_cache() {
    arquivo='/root/ApiUlekCheckuser/cache.json'
    if [[ -e "$arquivo" ]]; then
        cat "$arquivo" 2>/dev/null || echo "{}"
    else
        echo "{}"
    fi
}

salvar_cache() {
    cache=$1
    arquivo='/root/ApiUlekCheckuser/cache.json'
    echo "$cache" >"$arquivo"
}

get_public_ip() {
    url="https://ipinfo.io"
    response=$(curl -s "$url")
    if [[ $? -eq 0 ]]; then
        ip=$(echo "$response" | jq -r .ip)
        if [[ -n "$ip" ]]; then
            echo "$ip"
        else
            echo "Endereço IP público não encontrado na resposta."
        fi
    else
        echo "Falha na solicitação ao servidor."
    fi
}

verificar_processo() {
    nome_processo=$1
    resultado=$(ps aux)
    if echo "$resultado" | grep -q "$nome_processo" && echo "$resultado" | grep -q "python"; then
        return 0
    else
        return 1
    fi
}

nome_do_script="/root/ApiUlekCheckuser/api.py"

while true; do
    clear

    echo -e "🅲 🅷 🅴 🅲 🅺 🆄 🆂 🅴 🆁 🅰 🅿 🅸"

    if verificar_processo "$nome_do_script"; then
        status="${cor_verde}ativo${cor_reset}"
        acao="Parar"
        link_sinc="Link de sincronização: http://$(get_public_ip):$(obter_do_cache 'porta')"
    else
        status="${cor_vermelha}parado${cor_reset}"
        acao="Iniciar"
        link_sinc=""
    fi

    echo -e "Status: $status"

    if [[ -n "$link_sinc" ]]; then
        echo -e "\n$link_sinc"
    fi

    echo -e "\nSelecione uma opção:"
    echo -e " 1 - $acao api"
    echo -e " 2 - Sobre"
    echo -e " 0 - Sair do menu"

    read -p "Digite a opção: " option

    case $option in
    "1")
        if verificar_processo "$nome_do_script"; then
            { pkill -9 -f "$nome_do_script" > /dev/null 2>&1 && remover_do_cache "porta"; } 
        else
            adicionar_ao_cache 'porta' "$(read -p $'\nDigite a porta que deseja usar !: ' porta && echo $porta)"
            clear
            echo -e "Porta escolhida: $(obter_do_cache 'porta')"
            { nohup python3 "$nome_do_script" --port "$(obter_do_cache 'porta')" >/dev/null 2>&1 & }
        fi
        read -p "Pressione a tecla enter para voltar ao menu"
        ;;
    "2")
        clear
        echo -e "Olá, esse é uma api para o multi-checkuser criado por @UlekBR"
        read -p "Pressione a tecla enter para voltar ao menu"
        ;;
    "0")
        exit 0
        ;;
    *)
        clear
        echo -e "Selecionado uma opção invalida, tente novamente !"
        read -p "Pressione a tecla enter para voltar ao menu"
        ;;
    esac
done
