name = "Distributed World Server (.NET)"
description = "Sistema em .NET que divide o mundo DST em servidores diferentes - mundo superior e cavernas em máquinas separadas para melhor performance multiplataforma (Windows, Mac, Linux)"
author = "Arthur"
version = "1.0.0"

forumthread = ""

api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

all_clients_require_mod = true
client_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {"distributed", "performance", "multiplataforma", "dotnet", "loadbalancing"}

configuration_options = {
    {
        name = "auto_detect_world",
        label = "Detecção Automática de Mundo",
        hover = "Detecta automaticamente se está no mundo superior ou cavernas",
        options = {
            {description = "Ativado", data = true},
            {description = "Desativado", data = false}
        },
        default = true
    },
    {
        name = "platform_priority",
        label = "Prioridade de Plataforma",
        hover = "Define qual plataforma pega cargas mais pesadas",
        options = {
            {description = "Windows (Mais Pesado)", data = "windows"},
            {description = "Linux (Médio)", data = "linux"},
            {description = "Mac (Mais Leve)", data = "mac"},
            {description = "Auto-Detectar", data = "auto"}
        },
        default = "auto"
    },
    {
        name = "load_balancing",
        label = "Balanceamento de Carga",
        hover = "Ativa balanceamento automático quando há muitos jogadores",
        options = {
            {description = "Ativado", data = true},
            {description = "Desativado", data = false}
        },
        default = true
    },
    {
        name = "run_only_active_world",
        label = "Rodar Apenas Mundo Ativo",
        hover = "Só processa o mundo onde o jogador está (economiza recursos)",
        options = {
            {description = "Ativado", data = true},
            {description = "Desativado", data = false}
        },
        default = true
    },
    {
        name = "debug_mode",
        label = "Modo Debug",
        hover = "Mostra mensagens detalhadas no console",
        options = {
            {description = "Ativado", data = true},
            {description = "Desativado", data = false}
        },
        default = false
    }
}