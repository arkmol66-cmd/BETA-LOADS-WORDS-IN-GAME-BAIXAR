-- Gerenciador de rede para comunicação entre servidores
local NetworkManager = Class(function(self)
    self.connections = {}
    self.message_queue = {}
    self.heartbeat_interval = 30
    self.last_heartbeat = 0
end)

function NetworkManager:Initialize()
    self.server_id = self:GenerateServerId()
    self.is_master = TheWorld and TheWorld.ismastersim
end

function NetworkManager:GenerateServerId()
    -- Gera um ID único para este servidor
    return "server_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
end

function NetworkManager:SendMessage(target_server, message_type, data)
    -- Simula envio de mensagem para outro servidor
    local message = {
        from_server = self.server_id,
        to_server = target_server,
        message_type = message_type,
        data = data,
        timestamp = os.time()
    }
    
    table.insert(self.message_queue, message)
    
    -- Em uma implementação real, isso enviaria via HTTP/TCP
    self:ProcessMessage(message)
    
    return true
end

function NetworkManager:ProcessMessage(message)
    if not message or message.to_server ~= self.server_id then
        return
    end
    
    local handler = self:GetMessageHandler(message.message_type)
    if handler then
        handler(message.data, message.from_server)
    end
end

function NetworkManager:GetMessageHandler(message_type)
    local handlers = {
        ["player_join"] = function(data, from_server)
            self:HandlePlayerJoin(data, from_server)
        end,
        
        ["player_leave"] = function(data, from_server)
            self:HandlePlayerLeave(data, from_server)
        end,
        
        ["world_transition"] = function(data, from_server)
            self:HandleWorldTransition(data, from_server)
        end,
        
        ["load_balance_request"] = function(data, from_server)
            self:HandleLoadBalanceRequest(data, from_server)
        end,
        
        ["heartbeat"] = function(data, from_server)
            self:HandleHeartbeat(data, from_server)
        end,
        
        ["server_status"] = function(data, from_server)
            self:HandleServerStatus(data, from_server)
        end
    }
    
    return handlers[message_type]
end

function NetworkManager:HandlePlayerJoin(data, from_server)
    print(string.format("[Network] Jogador %s entrou no servidor %s", 
          data.player_name or "Unknown", from_server))
    
    -- Notifica o gerenciador de mundo distribuído
    if self.world_manager then
        self.world_manager:OnRemotePlayerJoin(data)
    end
end

function NetworkManager:HandlePlayerLeave(data, from_server)
    print(string.format("[Network] Jogador %s saiu do servidor %s", 
          data.player_name or "Unknown", from_server))
    
    if self.world_manager then
        self.world_manager:OnRemotePlayerLeave(data)
    end
end

function NetworkManager:HandleWorldTransition(data, from_server)
    print(string.format("[Network] Transição de mundo: %s -> %s (servidor %s)", 
          data.from_world, data.to_world, from_server))
    
    if self.world_manager then
        self.world_manager:OnRemoteWorldTransition(data)
    end
end

function NetworkManager:HandleLoadBalanceRequest(data, from_server)
    print(string.format("[Network] Solicitação de balanceamento do servidor %s", from_server))
    
    if self.load_balancer then
        self.load_balancer:ProcessRemoteBalanceRequest(data, from_server)
    end
end

function NetworkManager:HandleHeartbeat(data, from_server)
    -- Atualiza informações do servidor remoto
    self.connections[from_server] = {
        last_heartbeat = os.time(),
        server_info = data,
        is_online = true
    }
end

function NetworkManager:HandleServerStatus(data, from_server)
    if self.load_balancer then
        self.load_balancer:UpdateServerStatus(from_server, data)
    end
end

function NetworkManager:BroadcastPlayerJoin(player_data)
    for server_id in pairs(self.connections) do
        self:SendMessage(server_id, "player_join", player_data)
    end
end

function NetworkManager:BroadcastPlayerLeave(player_data)
    for server_id in pairs(self.connections) do
        self:SendMessage(server_id, "player_leave", player_data)
    end
end

function NetworkManager:BroadcastWorldTransition(transition_data)
    for server_id in pairs(self.connections) do
        self:SendMessage(server_id, "world_transition", transition_data)
    end
end

function NetworkManager:SendHeartbeat()
    local current_time = os.time()
    
    if current_time - self.last_heartbeat < self.heartbeat_interval then
        return
    end
    
    self.last_heartbeat = current_time
    
    local heartbeat_data = {
        server_id = self.server_id,
        world_type = self.world_manager and self.world_manager.current_world_type or "unknown",
        player_count = AllPlayers and #AllPlayers or 0,
        timestamp = current_time,
        is_master = self.is_master
    }
    
    for server_id in pairs(self.connections) do
        self:SendMessage(server_id, "heartbeat", heartbeat_data)
    end
end

function NetworkManager:RequestLoadBalance()
    local balance_request = {
        server_id = self.server_id,
        current_load = {
            player_count = AllPlayers and #AllPlayers or 0,
            world_type = self.world_manager and self.world_manager.current_world_type or "unknown"
        },
        timestamp = os.time()
    }
    
    for server_id in pairs(self.connections) do
        self:SendMessage(server_id, "load_balance_request", balance_request)
    end
end

function NetworkManager:RegisterConnection(server_id, server_info)
    self.connections[server_id] = {
        server_info = server_info,
        last_heartbeat = os.time(),
        is_online = true
    }
    
    print(string.format("[Network] Conexão registrada com servidor %s", server_id))
end

function NetworkManager:UnregisterConnection(server_id)
    if self.connections[server_id] then
        self.connections[server_id] = nil
        print(string.format("[Network] Conexão removida com servidor %s", server_id))
        return true
    end
    return false
end

function NetworkManager:GetConnectedServers()
    local servers = {}
    
    for server_id, connection in pairs(self.connections) do
        if connection.is_online then
            table.insert(servers, {
                id = server_id,
                info = connection.server_info,
                last_seen = connection.last_heartbeat
            })
        end
    end
    
    return servers
end

function NetworkManager:CleanupConnections()
    local current_time = os.time()
    local timeout = 90 -- 1.5 minutos
    
    for server_id, connection in pairs(self.connections) do
        if current_time - connection.last_heartbeat > timeout then
            connection.is_online = false
            print(string.format("[Network] Conexão com servidor %s expirou", server_id))
        end
    end
end

function NetworkManager:GetNetworkStats()
    local stats = {
        server_id = self.server_id,
        connected_servers = 0,
        online_servers = 0,
        messages_sent = #self.message_queue,
        last_heartbeat = self.last_heartbeat
    }
    
    for _, connection in pairs(self.connections) do
        stats.connected_servers = stats.connected_servers + 1
        if connection.is_online then
            stats.online_servers = stats.online_servers + 1
        end
    end
    
    return stats
end

function NetworkManager:SetWorldManager(world_manager)
    self.world_manager = world_manager
end

function NetworkManager:SetLoadBalancer(load_balancer)
    self.load_balancer = load_balancer
end

return NetworkManager