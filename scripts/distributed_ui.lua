-- Interface visual para mostrar status da distribuição
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

local DistributedUI = Class(Widget, function(self, world_manager, load_balancer, network_manager)
    Widget._ctor(self, "DistributedUI")
    
    self.world_manager = world_manager
    self.load_balancer = load_balancer
    self.network_manager = network_manager
    
    self.is_visible = false
    
    self:CreateInterface()
    self:Hide()
end)

function DistributedUI:CreateInterface()
    -- Fundo escuro semi-transparente
    self.background = self:AddChild(Image("images/global_redux.xml", "bg_redux_dark.tex"))
    self.background:SetVRegPoint(ANCHOR_MIDDLE)
    self.background:SetHRegPoint(ANCHOR_MIDDLE)
    self.background:SetVAnchor(ANCHOR_MIDDLE)
    self.background:SetHAnchor(ANCHOR_MIDDLE)
    self.background:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.background:SetTint(0, 0, 0, 0.8)
    
    -- Painel principal
    self.panel = self:AddChild(Image("images/global_redux.xml", "panel_upsell.tex"))
    self.panel:SetPosition(0, 0, 0)
    self.panel:SetScale(1.2, 1.0, 1.0)
    
    -- Título
    self.title = self:AddChild(Text(CHATFONT, 40))
    self.title:SetPosition(0, 200, 0)
    self.title:SetString("Sistema de Distribuição Ativo")
    self.title:SetColour(1, 1, 0, 1) -- Amarelo
    
    -- Status do mundo atual
    self.world_status = self:AddChild(Text(CHATFONT, 28))
    self.world_status:SetPosition(0, 150, 0)
    self.world_status:SetString("Detectando mundo...")
    self.world_status:SetColour(0.8, 0.8, 1, 1) -- Azul claro
    
    -- Informações de jogadores
    self.player_info = self:AddChild(Text(CHATFONT, 24))
    self.player_info:SetPosition(0, 100, 0)
    self.player_info:SetString("Carregando informações...")
    self.player_info:SetColour(1, 1, 1, 1) -- Branco
    
    -- Status de balanceamento
    self.balance_status = self:AddChild(Text(CHATFONT, 24))
    self.balance_status:SetPosition(0, 50, 0)
    self.balance_status:SetString("Balanceamento: Verificando...")
    self.balance_status:SetColour(0.8, 1, 0.8, 1) -- Verde claro
    
    -- Distribuição de carga
    self.load_distribution = self:AddChild(Text(CHATFONT, 20))
    self.load_distribution:SetPosition(0, 0, 0)
    self.load_distribution:SetString("Analisando distribuição...")
    self.load_distribution:SetColour(1, 0.8, 0.6, 1) -- Laranja claro
    
    -- Servidores conectados
    self.server_list = self:AddChild(Text(CHATFONT, 18))
    self.server_list:SetPosition(0, -50, 0)
    self.server_list:SetString("Verificando servidores...")
    self.server_list:SetColour(0.9, 0.9, 0.9, 1) -- Cinza claro
    
    -- Performance atual
    self.performance_info = self:AddChild(Text(CHATFONT, 18))
    self.performance_info:SetPosition(0, -100, 0)
    self.performance_info:SetString("Performance: Calculando...")
    self.performance_info:SetColour(0.6, 1, 0.6, 1) -- Verde
    
    -- Botão para fechar
    self.close_button = self:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.close_button:SetPosition(0, -160, 0)
    self.close_button:SetText("Fechar")
    self.close_button:SetOnClick(function() self:Hide() end)
    
    -- Instrução
    self.instruction = self:AddChild(Text(CHATFONT, 16))
    self.instruction:SetPosition(0, -200, 0)
    self.instruction:SetString("Pressione '/' novamente para fechar")
    self.instruction:SetColour(0.7, 0.7, 0.7, 1) -- Cinza
end

function DistributedUI:UpdateInfo()
    if not self.is_visible then
        return
    end
    
    -- Atualiza status do mundo
    local world_type = self.world_manager:DetectWorldType()
    local world_name = world_type == "caves" and "Cavernas" or "Mundo Superior"
    local world_color = world_type == "caves" and "🕳️" or "🌍"
    self.world_status:SetString(world_color .. " Mundo Atual: " .. world_name)
    
    -- Atualiza informações de jogadores
    local player_count = self.world_manager:GetPlayerCount()
    local load_info = self.world_manager:GetLoadInfo()
    self.player_info:SetString("👥 Jogadores Conectados: " .. player_count .. " | Partições: " .. load_info.partitions)
    
    -- Atualiza status de balanceamento
    local balance_active = load_info.load_balanced and "Ativo ✅" or "Inativo ⏸️"
    self.balance_status:SetString("⚖️ Balanceamento: " .. balance_active)
    
    -- Atualiza distribuição de carga
    local distribution_text = self:GetLoadDistributionText()
    self.load_distribution:SetString("📊 " .. distribution_text)
    
    -- Atualiza lista de servidores
    local server_text = self:GetServerListText()
    self.server_list:SetString("🖥️ " .. server_text)
    
    -- Atualiza informações de performance
    local performance_text = self:GetPerformanceText()
    self.performance_info:SetString("⚡ " .. performance_text)
end

function DistributedUI:GetLoadDistributionText()
    local partitions = self.world_manager.world_partitions or {}
    
    if #partitions == 0 then
        return "Distribuição: Modo Único (100% local)"
    elseif #partitions == 1 then
        local partition = partitions[1]
        return "Distribuição: " .. partition.type .. " (" .. math.floor(partition.load_weight * 100) .. "%)"
    else
        local text = "Distribuição: "
        for i, partition in ipairs(partitions) do
            if i > 1 then text = text .. " | " end
            local world_name = partition.type == "overworld" and "Superior" or "Cavernas"
            text = text .. world_name .. " (" .. math.floor(partition.load_weight * 100) .. "%)"
        end
        return text
    end
end

function DistributedUI:GetServerListText()
    local network_stats = self.network_manager:GetNetworkStats()
    local connected = network_stats.connected_servers or 0
    local online = network_stats.online_servers or 0
    
    if connected == 0 then
        return "Servidores: Modo Local (sem rede)"
    else
        return "Servidores: " .. online .. "/" .. connected .. " online"
    end
end

function DistributedUI:GetPerformanceText()
    local server_stats = self.load_balancer:GetServerStats()
    local total_players = server_stats.total_players or 0
    local total_servers = server_stats.total_servers or 1
    
    local efficiency = total_servers > 0 and math.floor((total_players / total_servers) * 10) or 0
    local status = efficiency > 15 and "Sobrecarregado 🔴" or 
                   efficiency > 10 and "Balanceado 🟡" or 
                   "Otimizado 🟢"
    
    return "Performance: " .. status .. " (Eficiência: " .. efficiency .. "/10)"
end

function DistributedUI:Show()
    if self.is_visible then
        return
    end
    
    self.is_visible = true
    self:UpdateInfo()
    
    -- Animação de entrada
    self:SetScale(0.8)
    self:ScaleTo(1.0, 0.2)
    
    -- Atualiza informações periodicamente
    if self.update_task then
        self.update_task:Cancel()
    end
    
    self.update_task = self.inst:DoPeriodicTask(1, function()
        if self.is_visible then
            self:UpdateInfo()
        end
    end)
end

function DistributedUI:Hide()
    if not self.is_visible then
        return
    end
    
    self.is_visible = false
    
    -- Para atualizações
    if self.update_task then
        self.update_task:Cancel()
        self.update_task = nil
    end
    
    -- Animação de saída
    self:ScaleTo(0.8, 0.1, function()
        Widget.Hide(self)
    end)
end

function DistributedUI:Toggle()
    if self.is_visible then
        self:Hide()
    else
        self:Show()
    end
end

function DistributedUI:IsVisible()
    return self.is_visible
end

return DistributedUI