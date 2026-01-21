-- Sistema de balanceamento de carga distribuído
local LoadBalancer = Class(function(self)
    self.servers = {}
    self.balancing_enabled = true
    self.last_balance_time = 0
    self.balance_interval = 30 -- segundos
end)

function LoadBalancer:Initialize(world_manager)
    self.world_manager = world_manager
    self.balancing_enabled = GetModConfigData("load_balancing") or true
end

function LoadBalancer:RegisterServer(server_info)
    if not server_info or not server_info.id then
        return false
    end
    
    self.servers[server_info.id] = {
        id = server_info.id,
        platform = server_info.platform or "windows",
        world_type = server_info.world_type or "overworld",
        player_count = server_info.player_count or 0,
        cpu_usage = server_info.cpu_usage or 0,
        memory_usage = server_info.memory_usage or 0,
        last_heartbeat = os.time(),
        is_online = true
    }
    
    return true
end

function LoadBalancer:UnregisterServer(server_id)
    if self.servers[server_id] then
        self.servers[server_id] = nil
        return true
    end
    return false
end

function LoadBalancer:UpdateServerStatus(server_id, status)
    if not self.servers[server_id] then
        return false
    end
    
    local server = self.servers[server_id]
    server.player_count = status.player_count or server.player_count
    server.cpu_usage = status.cpu_usage or server.cpu_usage
    server.memory_usage = status.memory_usage or server.memory_usage
    server.last_heartbeat = os.time()
    server.is_online = true
    
    return true
end

function LoadBalancer:ShouldBalance()
    if not self.balancing_enabled then
        return false
    end
    
    local current_time = os.time()
    if current_time - self.last_balance_time < self.balance_interval then
        return false
    end
    
    -- Verifica se há necessidade de balanceamento
    local total_players = 0
    local overloaded_servers = 0
    
    for _, server in pairs(self.servers) do
        if server.is_online then
            total_players = total_players + server.player_count
            
            if server.cpu_usage > 80 or server.memory_usage > 85 or server.player_count > 20 then
                overloaded_servers = overloaded_servers + 1
            end
        end
    end
    
    return total_players > 1 and overloaded_servers > 0
end

function LoadBalancer:PerformBalancing()
    if not self:ShouldBalance() then
        return false
    end
    
    self.last_balance_time = os.time()
    
    local recommendations = self:CalculateBalancingRecommendations()
    
    if #recommendations > 0 then
        self:ApplyBalancingRecommendations(recommendations)
        return true
    end
    
    return false
end

function LoadBalancer:CalculateBalancingRecommendations()
    local recommendations = {}
    local overloaded_servers = {}
    local underloaded_servers = {}
    
    -- Identifica servidores sobrecarregados e subcarregados
    for server_id, server in pairs(self.servers) do
        if server.is_online then
            if server.cpu_usage > 80 or server.player_count > 20 then
                table.insert(overloaded_servers, server)
            elseif server.cpu_usage < 50 and server.player_count < 10 then
                table.insert(underloaded_servers, server)
            end
        end
    end
    
    -- Cria recomendações de balanceamento
    for _, overloaded in ipairs(overloaded_servers) do
        for _, underloaded in ipairs(underloaded_servers) do
            if self:CanMigrateLoad(overloaded, underloaded) then
                table.insert(recommendations, {
                    action = "migrate_players",
                    from_server = overloaded.id,
                    to_server = underloaded.id,
                    player_count = math.min(5, math.floor(overloaded.player_count / 2))
                })
                break
            end
        end
    end
    
    return recommendations
end

function LoadBalancer:CanMigrateLoad(from_server, to_server)
    -- Verifica se é possível migrar carga entre servidores
    if from_server.world_type ~= to_server.world_type then
        return false -- Não migra entre tipos de mundo diferentes
    end
    
    if to_server.player_count + 5 > 15 then
        return false -- Servidor destino ficaria sobrecarregado
    end
    
    return true
end

function LoadBalancer:ApplyBalancingRecommendations(recommendations)
    for _, recommendation in ipairs(recommendations) do
        if recommendation.action == "migrate_players" then
            self:MigratePlayers(recommendation.from_server, recommendation.to_server, recommendation.player_count)
        end
    end
end

function LoadBalancer:MigratePlayers(from_server_id, to_server_id, player_count)
    -- Em uma implementação real, isso enviaria comandos para os servidores
    -- Por enquanto, apenas simula a migração
    
    local from_server = self.servers[from_server_id]
    local to_server = self.servers[to_server_id]
    
    if from_server and to_server then
        from_server.player_count = math.max(0, from_server.player_count - player_count)
        to_server.player_count = to_server.player_count + player_count
        
        print(string.format("[LoadBalancer] Migrados %d jogadores de %s para %s", 
              player_count, from_server_id, to_server_id))
    end
end

function LoadBalancer:GetOptimalServerForWorld(world_type, player_platform)
    local suitable_servers = {}
    
    for _, server in pairs(self.servers) do
        if server.is_online and server.world_type == world_type then
            -- Prioriza servidores da mesma plataforma ou Windows para cargas pesadas
            local priority = 0
            
            if world_type == "overworld" and server.platform == "windows" then
                priority = priority + 10
            elseif world_type == "caves" and server.platform ~= "windows" then
                priority = priority + 5
            end
            
            if server.platform == player_platform then
                priority = priority + 3
            end
            
            -- Penaliza servidores sobrecarregados
            if server.cpu_usage > 70 then
                priority = priority - 5
            end
            
            if server.player_count > 15 then
                priority = priority - 3
            end
            
            table.insert(suitable_servers, {
                server = server,
                priority = priority
            })
        end
    end
    
    -- Ordena por prioridade
    table.sort(suitable_servers, function(a, b)
        return a.priority > b.priority
    end)
    
    return suitable_servers[1] and suitable_servers[1].server or nil
end

function LoadBalancer:GetServerStats()
    local stats = {
        total_servers = 0,
        online_servers = 0,
        total_players = 0,
        overworld_servers = 0,
        caves_servers = 0
    }
    
    for _, server in pairs(self.servers) do
        stats.total_servers = stats.total_servers + 1
        
        if server.is_online then
            stats.online_servers = stats.online_servers + 1
            stats.total_players = stats.total_players + server.player_count
            
            if server.world_type == "overworld" then
                stats.overworld_servers = stats.overworld_servers + 1
            elseif server.world_type == "caves" then
                stats.caves_servers = stats.caves_servers + 1
            end
        end
    end
    
    return stats
end

function LoadBalancer:CleanupOfflineServers()
    local current_time = os.time()
    local timeout = 120 -- 2 minutos
    
    for server_id, server in pairs(self.servers) do
        if current_time - server.last_heartbeat > timeout then
            server.is_online = false
            print(string.format("[LoadBalancer] Servidor %s marcado como offline", server_id))
        end
    end
end

return LoadBalancer