--[[
    Shared hunger / thirst / stress bridge
    Supports: ESX (esx_status), QBCore (metadata), Qbox (metadata + state bags)
]]

Needs = {
    hunger = 100,
    thirst = 100,
    stress = 0,
    framework = 'standalone'
}

local function clamp(value, fallback)
    local n = tonumber(value)
    if n == nil then return fallback end
    if n < 0 then n = 0 end
    if n > 100 then n = 100 end
    return math.floor(n + 0.5)
end

local function setNeeds(hunger, thirst, stress)
    if hunger ~= nil then Needs.hunger = clamp(hunger, Needs.hunger) end
    if thirst ~= nil then Needs.thirst = clamp(thirst, Needs.thirst) end
    if stress ~= nil then Needs.stress = clamp(stress, Needs.stress) end
end

local function detectFramework()
    local cfg = (Config and Config.Framework) or 'auto'
    if cfg and cfg ~= 'auto' then
        return cfg
    end

    if GetResourceState('qbx_core') == 'started' then
        return 'qbox'
    end
    if GetResourceState('qb-core') == 'started' then
        return 'qb'
    end
    if GetResourceState('es_extended') == 'started' then
        return 'esx'
    end
    return 'standalone'
end

local function getQbCore()
    if GetResourceState('qb-core') ~= 'started' then return nil end
    local ok, core = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)
    if ok then return core end
    return nil
end

local function getQbPlayerData()
    if Needs.framework == 'qbox' and GetResourceState('qbx_core') == 'started' then
        local ok, data = pcall(function()
            return exports.qbx_core:GetPlayerData()
        end)
        if ok and type(data) == 'table' then
            return data
        end
    end

    local core = getQbCore()
    if core and core.Functions and core.Functions.GetPlayerData then
        local data = core.Functions.GetPlayerData()
        if type(data) == 'table' then
            return data
        end
    end
    return nil
end

local function applyFromMetadata(playerData)
    if type(playerData) ~= 'table' then return end
    local md = playerData.metadata or playerData.MetaData
    if type(md) ~= 'table' then return end
    setNeeds(md.hunger, md.thirst, md.stress)
end

local function applyFromStateBags()
    local state = LocalPlayer and LocalPlayer.state
    if not state then return end
    if state.hunger ~= nil or state.thirst ~= nil or state.stress ~= nil then
        setNeeds(state.hunger, state.thirst, state.stress)
    end
end

function Needs.Refresh()
    if Needs.framework == 'esx' then
        if GetResourceState('esx_status') == 'started' then
            TriggerEvent('esx_status:getStatus', 'hunger', function(status)
                if status and status.val then
                    setNeeds((status.val / 1000000) * 100, nil, nil)
                elseif status and status.percent then
                    setNeeds(status.percent, nil, nil)
                end
            end)
            TriggerEvent('esx_status:getStatus', 'thirst', function(status)
                if status and status.val then
                    setNeeds(nil, (status.val / 1000000) * 100, nil)
                elseif status and status.percent then
                    setNeeds(nil, status.percent, nil)
                end
            end)
            TriggerEvent('esx_status:getStatus', 'stress', function(status)
                if status and status.val then
                    setNeeds(nil, nil, (status.val / 1000000) * 100)
                elseif status and status.percent then
                    setNeeds(nil, nil, status.percent)
                end
            end)
        end
        return
    end

    if Needs.framework == 'qb' or Needs.framework == 'qbox' then
        applyFromStateBags()
        applyFromMetadata(getQbPlayerData())
    end
end

CreateThread(function()
    Wait(100)
    Needs.framework = detectFramework()

    -- Universal HUD events (many QB hunger scripts / qb-hud / custom needs)
    RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
        setNeeds(newHunger, newThirst, nil)
    end)

    RegisterNetEvent('hud:client:UpdateStress', function(newStress)
        setNeeds(nil, nil, newStress)
    end)

    if Needs.framework == 'esx' then
        RegisterNetEvent('esx_status:onTick', function(data)
            if type(data) ~= 'table' then return end
            local h, t, s
            for i = 1, #data do
                local status = data[i]
                if status and status.name == 'hunger' then
                    h = status.percent
                elseif status and status.name == 'thirst' then
                    t = status.percent
                elseif status and status.name == 'stress' then
                    s = status.percent
                end
            end
            setNeeds(h, t, s)
        end)

        RegisterNetEvent('esx:playerLoaded', function()
            SetTimeout(1000, function()
                Needs.Refresh()
            end)
        end)

        AddEventHandler('esx:onPlayerSpawn', function()
            SetTimeout(1000, function()
                Needs.Refresh()
            end)
        end)
    end

    if Needs.framework == 'qb' or Needs.framework == 'qbox' then
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
            SetTimeout(500, function()
                Needs.Refresh()
            end)
        end)

        RegisterNetEvent('QBCore:Player:SetPlayerData', function(playerData)
            applyFromMetadata(playerData)
        end)

        RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
            setNeeds(100, 100, 0)
        end)

        -- Qbox / some QB builds expose needs on state bags
        local function onNeedState(_, _, value)
            -- refresh all from bags to keep in sync
            applyFromStateBags()
            if value == nil then
                applyFromMetadata(getQbPlayerData())
            end
        end

        AddStateBagChangeHandler('hunger', nil, onNeedState)
        AddStateBagChangeHandler('thirst', nil, onNeedState)
        AddStateBagChangeHandler('stress', nil, onNeedState)

        -- Periodic metadata poll (covers scripts that only update metadata)
        CreateThread(function()
            while true do
                Wait(2000)
                Needs.Refresh()
            end
        end)
    end

    -- Initial read
    Wait(1500)
    Needs.Refresh()
end)
