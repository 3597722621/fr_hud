-- Emniyet Kemeri Ses Bankasi Yukleme
-- Load the seatbelt sound bank
CreateThread(function()
    RequestScriptAudioBank('audiodirectory/seatbelt_sounds', false)
end)

local seatbeltOn = false

RegisterCommand('toggleseatbelt', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        local class = GetVehicleClass(veh)
        if class ~= 8 and class ~= 13 and class ~= 14 then
            seatbeltOn = not seatbeltOn
            LocalPlayer.state:set('seatbelt', seatbeltOn, true)
            PlaySoundFrontend(-1, seatbeltOn and 'carbuckle' or 'carunbuckle', 'seatbelt_soundset', true)
        end
    end
end, false)

RegisterKeyMapping('toggleseatbelt', 'Toggle Seatbelt', 'keyboard', 'B')

local wasInVehicle = false
local cinematicMode = false

RegisterNetEvent('hud:client:ToggleCinematic', function(state)
    cinematicMode = state
end)

CreateThread(function()
    while true do
        Wait(50)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) and not IsPauseMenuActive() and not cinematicMode then
            wasInVehicle = true
            local veh = GetVehiclePedIsIn(ped, false)

            local speed = math.floor(GetEntitySpeed(veh) * 3.6)

            local rpm = GetVehicleCurrentRpm(veh)

            local gear = GetVehicleCurrentGear(veh)
            if speed == 0 and gear == 0 then
                gear = 'N'
            elseif gear == 0 then
                gear = 'R'
            end

            local fuel = GetVehicleFuelLevel(veh)

            local _, lightsOn, highbeamsOn = GetVehicleLightsState(veh)
            local isLightsOn = lightsOn == 1 or highbeamsOn == 1

            local seatbelt = LocalPlayer.state.seatbelt or false

            local lockStatus = GetVehicleDoorLockStatus(veh)
            local isLocked = lockStatus == 2 or lockStatus == 3

            local engineHealth = GetVehicleEngineHealth(veh)

            local maxGear = GetVehicleHighGear(veh)
            local class = GetVehicleClass(veh)
            local isElectric = false
            if maxGear == 1 and class ~= 8 and class ~= 13 and class ~= 14 then
                isElectric = true
            end

            SendNUIMessage({
                action = 'updateCarHud',
                speed = speed,
                rpm = rpm,
                gear = gear,
                fuel = fuel,
                lights = isLightsOn,
                seatbelt = seatbelt,
                locked = isLocked,
                engine = engineHealth,
                isElectric = isElectric
            })
        else
            if wasInVehicle then
                wasInVehicle = false
                if seatbeltOn then
                    seatbeltOn = false
                    LocalPlayer.state:set('seatbelt', false, true)
                end
            end
            SendNUIMessage({ action = 'hideCarHud' })
        end
    end
end)
