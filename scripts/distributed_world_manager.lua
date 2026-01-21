-- Sistema de gerenciamento de mundo distribuído
local DistributedWorldManager = Class(function(self)
    self.current_world_type = "unknown"
    self.connected_players = {}
    self.world_partitions = {}
    self.load_balancer_active = false
end)

function DistributedWorldManager:DetectWorldType()
    if TheWorld then
        if TheWorld:HasTag("cave") then
            self.current_world_type = "caves"
        elseif TheWorld:HasTag("forest") then
            self.current_world_type = "overworld"
        else
            -- Detecção alternativa
            if TheWorld.topology and TheWorld.topology.level_type then
                if TheWorld.topology.level_type == "cave" then
                    self.current_world_type = "caves"
                else
                    self.current_world_type = "overworld"
                end
            else
                self.current_world_type = "overworld"
            end
        end
    end
    return self.current_world_type
end

function DistributedWorldManager:AddPlayer(player)
    if not player then return end
    
    local player_data = {
        id = player.userid or tostring(player.GUID),
        name = player:GetDisplayName() or player.name or "Unknown",
        platform = self:DetectPlayerPlatform(player),
        world_type = self.current_world_type,
        position = self:GetPlayerPosition(player),
        connected_time = os.time()
    }
    
    self.connected_players[player_data.id] = player_data
    self:UpdateWorldPartitions()
end

function DistributedWorldManager:RemovePlayer(player)
    if not player then return end
    
    local player_id = player.userid or tostring(player.GUID)
    self.connected_players[player_id] = nil
    self:UpdateWorldPartitions()
end

function DistributedWorldManager:DetectPlayerPlatform(player)
    -- Detecção básica de plataforma (limitada no DST)
    -- Por padrão assume Windows
    return "windows"
end

function DistributedWorldManager:GetPlayerPosition(player)
    if player and player.Transform then
        local x, y, z = player.Transform:GetWorldPosition()
        return {x = x, y = y, z = z}
    end
    return {x = 0, y = 0, z = 0}
end

function DistributedWorldManager:UpdateWorldPartitions()
    local player_count = 0
    for _ in pairs(self.connected_players) do
        player_count = player_count + 1
    end
    
    if player_count <= 1 then
        -- Um jogador ou menos - roda tudo em uma máquina
        self.world_partitions = {
            {
                type = "full",
                platform = "windows",
                load_weight = 1.0,
                players = self.connected_players
            }
        }
    else
        -- Múltiplos jogadores - divide por mundo
        self:CreateDistributedPartitions()
    end
end

function DistributedWorldManager:CreateDistributedPartitions()
    local windows_players = {}
    local other_players = {}
    
    for id, player in pairs(self.connected_players) do
        if player.platform == "windows" then
            windows_players[id] = player
        else
            other_players[id] = player
        end
    end
    
    self.world_partitions = {}
    
    -- Windows pega mundo superior (mais pesado)
    if next(windows_players) then
        table.insert(self.world_partitions, {
            type = "overworld",
            platform = "windows",
            load_weight = 0.7,
            players = windows_players
        })
    end
    
    -- Outras plataformas pegam cavernas (mais leve)
    if next(other_players) then
        table.insert(self.world_partitions, {
            type = "caves",
            platform = "other",
            load_weight = 0.3,
            players = other_players
        })
    end
end

function DistributedWorldManager:ShouldRunWorld(world_type)
    -- Determina se este servidor deve processar este tipo de mundo
    local current_partition = self:GetCurrentPartition()
    
    if not current_partition then
        return true -- Se não há partição, roda tudo
    end
    
    if current_partition.type == "full" then
        return true -- Roda tudo
    end
    
    return current_partition.type == world_type
end

function DistributedWorldManager:GetCurrentPartition()
    -- Retorna a partição que este servidor deve gerenciar
    for _, partition in ipairs(self.world_partitions) do
        -- Lógica para determinar qual partição este servidor gerencia
        -- Por simplicidade, assume que é a primeira
        return partition
    end
    return nil
end

function DistributedWorldManager:GetLoadInfo()
    return {
        world_type = self.current_world_type,
        player_count = self:GetPlayerCount(),
        partitions = #self.world_partitions,
        load_balanced = self.load_balancer_active
    }
end

function DistributedWorldManager:GetPlayerCount()
    local count = 0
    for _ in pairs(self.connected_players) do
        count = count + 1
    end
    return count
end

return DistributedWorldManager