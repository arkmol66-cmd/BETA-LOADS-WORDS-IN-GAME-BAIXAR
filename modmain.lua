-- ===================================================================
-- DST Distributed World Server Mod - VERSÃO COMPLETA COM UI
-- Sistema que divide o mundo em servidores diferentes para melhor performance
-- ===================================================================

local MOD_NAME = "DistributedWorldServer"
local MOD_VERSION = "1.0.0"

-- Importa os módulos do sistema
local DistributedWorldManager = require("scripts/distributed_world_manager")
local LoadBalancer = require("scripts/load_balancer")
local NetworkManager = require("scripts/network_manager")
local DistributedUI = require("scripts/distributed_ui")

-- Configurações do mod
local AUTO_DETECT_WORLD = GetModConfigData("auto_detect_world")
local PLATFORM_PRIORITY = GetModConfigData("platform_priority") or "auto"
local LOAD_BALANCING = GetModConfigData("load_balancing")
local RUN_ONLY_ACTIVE_WORLD = GetModConfigData("run_only_active_world")
local DEBUG_MODE = GetModConfigData("debug_mode")

-- Instâncias dos sistemas
local world_manager = DistributedWorldManager()
local load_balancer = LoadBalancer()
local network_manager = NetworkManager()
local distributed_ui = nil

-- Função de debug
local function DebugPrint(message)
    if DEBUG_MODE then
        print("[" .. MOD_NAME .. " DEBUG] " .. tostring(message))
    end
end

-- Função de log normal
local function ModPrint(message)
    print("[" .. MOD_NAME .. "] " .. tostring(message))
end

-- ===================================================================
-- Inicialização do Sistema
-- ===================================================================

local function InitializeDistributedSystem()
    ModPrint("=== Inicializando Sistema Distribuído ===")
    ModPrint("Versão: " .. MOD_VERSION)
    
    -- Inicializa os componentes
    network_manager:Initialize()
    load_balancer:Initialize(world_manager)
    
    -- Conecta os sistemas
    network_manager:SetWorldManager(world_manager)
    network_manager:SetLoadBalancer(load_balancer)
    
    -- Detecta mundo inicial
    if AUTO_DETECT_WORLD then
        world_manager:DetectWorldType()
        ModPrint("Mundo detectado: " .. world_manager.current_world_type)
    end
    
    ModPrint("Sistema distribuído inicializado com sucesso!")
end

-- ===================================================================
-- Sistema de Interface do Usuário
-- ===================================================================

local function InitializeUI()
    -- Cria a interface apenas para o jogador local
    if ThePlayer then
        distributed_ui = DistributedUI(world_manager, load_balancer, network_manager)
        ThePlayer.HUD:AddChild(distributed_ui)
        
        DebugPrint("Interface do usuário inicializada")
    end
end

local function SetupKeyHandler()
    -- Configura o handler para a tecla "/"
    if TheInput then
        local old_OnRawKey = TheInput.OnRawKey
        TheInput.OnRawKey = function(self, key, down)
            -- Chama o handler original primeiro
            if old_OnRawKey then
                old_OnRawKey(self, key, down)
            end
            
            -- Verifica se é a tecla "/" sendo pressionada
            if key == KEY_SLASH and down and distributed_ui then
                -- Só abre se não estiver em chat ou console
                if not TheFrontEnd:GetActiveScreen() or TheFrontEnd:GetActiveScreen().name == "HUD" then
                    distributed_ui:Toggle()
                    DebugPrint("Interface toggled via / key")
                end
            end
        end
    end
end

-- ===================================================================
-- Hooks e Eventos do Jogo
-- ===================================================================

-- Hook para quando jogador spawna
local function OnPlayerSpawned(player)
    if not player then return end
    
    ModPrint("Jogador spawnou: " .. (player:GetDisplayName() or player.name or "unknown"))
    
    -- Adiciona jogador ao sistema
    world_manager:AddPlayer(player)
    
    -- Detecta mundo atual
    if AUTO_DETECT_WORLD then
        world_manager:DetectWorldType()
    end
    
    -- Notifica outros servidores
    local player_data = {
        player_id = player.userid or tostring(player.GUID),
        player_name = player:GetDisplayName() or player.name or "unknown",
        world_type = world_manager.current_world_type,
        platform = PLATFORM_PRIORITY,
        timestamp = os.time()
    }
    
    network_manager:BroadcastPlayerJoin(player_data)
    
    -- Inicializa UI se for o jogador local
    if player == ThePlayer and not distributed_ui then
        InitializeUI()
        SetupKeyHandler()
    end
    
    DebugPrint("Jogador adicionado ao sistema distribuído")
end

-- Hook para quando jogador entra no servidor
local function OnPlayerJoined(player)
    if not player then return end
    
    ModPrint("Jogador entrou no servidor: " .. (player:GetDisplayName() or player.name or "unknown"))
    
    -- Processa entrada do jogador
    OnPlayerSpawned(player)
    
    -- Solicita balanceamento se necessário
    if LOAD_BALANCING and load_balancer:ShouldBalance() then
        load_balancer:PerformBalancing()
        network_manager:RequestLoadBalance()
    end
end

-- Hook para quando jogador sai
local function OnPlayerLeft(player)
    if not player then return end
    
    ModPrint("Jogador saiu: " .. (player:GetDisplayName() or player.name or "unknown"))
    
    -- Remove jogador do sistema
    world_manager:RemovePlayer(player)
    
    -- Notifica outros servidores
    local player_data = {
        player_id = player.userid or tostring(player.GUID),
        player_name = player:GetDisplayName() or player.name or "unknown",
        timestamp = os.time()
    }
    
    network_manager:BroadcastPlayerLeave(player_data)
    
    -- Rebalanceia se necessário
    if LOAD_BALANCING then
        load_balancer:PerformBalancing()
    end
end

-- ===================================================================
-- Sistema de Monitoramento
-- ===================================================================

local function MonitoringTask()
    DebugPrint("Executando tarefa de monitoramento")
    
    -- Detecta mundo atual
    if AUTO_DETECT_WORLD then
        world_manager:DetectWorldType()
    end
    
    -- Envia heartbeat
    network_manager:SendHeartbeat()
    
    -- Limpa conexões expiradas
    network_manager:CleanupConnections()
    load_balancer:CleanupOfflineServers()
    
    -- Balanceamento automático
    if LOAD_BALANCING and load_balancer:ShouldBalance() then
        DebugPrint("Executando balanceamento automático")
        load_balancer:PerformBalancing()
    end
end

-- ===================================================================
-- Detecção de Transições de Mundo
-- ===================================================================

local function DetectWorldTransitions()
    if not ThePlayer or not world_manager then
        return
    end
    
    local current_world = world_manager:DetectWorldType()
    local last_world = world_manager.last_detected_world or current_world
    
    if current_world ~= last_world then
        ModPrint("Transição detectada: " .. last_world .. " -> " .. current_world)
        
        -- Notifica transição
        local transition_data = {
            player_id = ThePlayer.userid or tostring(ThePlayer.GUID),
            player_name = ThePlayer:GetDisplayName() or ThePlayer.name or "unknown",
            from_world = last_world,
            to_world = current_world,
            timestamp = os.time()
        }
        
        network_manager:BroadcastWorldTransition(transition_data)
        
        -- Atualiza UI se estiver visível
        if distributed_ui and distributed_ui:IsVisible() then
            distributed_ui:UpdateInfo()
        end
    end
    
    world_manager.last_detected_world = current_world
end

-- ===================================================================
-- Inicialização e Hooks
-- ===================================================================

-- Registra hooks para jogadores
AddPlayerPostInit(OnPlayerSpawned)

-- Hook para entrada/saída de jogadores
if TheNet then
    local old_OnPlayerJoin = TheNet.OnPlayerJoin
    if old_OnPlayerJoin then
        TheNet.OnPlayerJoin = function(self, player)
            old_OnPlayerJoin(self, player)
            OnPlayerJoined(player)
        end
    end
    
    local old_OnPlayerLeave = TheNet.OnPlayerLeave
    if old_OnPlayerLeave then
        TheNet.OnPlayerLeave = function(self, player)
            old_OnPlayerLeave(self, player)
            OnPlayerLeft(player)
        end
    end
end

-- Inicia sistema de monitoramento
local monitoring_timer = nil
local transition_timer = nil

if TheWorld and TheWorld.ismastersim then
    ModPrint("Iniciando sistema de monitoramento avançado (intervalo: 30s)")
    monitoring_timer = TheWorld:DoPeriodicTask(30, MonitoringTask)
    
    -- Timer para detectar transições de mundo
    transition_timer = TheWorld:DoPeriodicTask(2, DetectWorldTransitions)
end

-- Inicializa o sistema distribuído
InitializeDistributedSystem()

-- ===================================================================
-- Finalização
-- ===================================================================

ModPrint("=== Mod Sistema Distribuído Carregado! ===")
ModPrint("Pressione '/' para ver o status da distribuição")
ModPrint("Sistema pronto para distribuição de carga!")