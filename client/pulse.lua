local pulse = 65.0
local targetPulse = 65.0

CreateThread(function()
    while true do
        Wait(500)
        local ped = PlayerPedId()
        local hunger = Needs and Needs.hunger or 100
        local thirst = Needs and Needs.thirst or 100
        local stress = Needs and Needs.stress or 0

        if IsEntityDead(ped) then
            targetPulse = 0.0
        else
            local basePulse = 65.0

            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 then
                local speed = GetEntitySpeed(veh) * 3.6
                if speed > 160.0 then
                    basePulse = basePulse + 25.0
                elseif speed > 100.0 then
                    basePulse = basePulse + 15.0
                elseif speed > 50.0 then
                    basePulse = basePulse + 5.0
                end
            else
                if IsPedSprinting(ped) then
                    basePulse = basePulse + 25.0
                elseif IsPedRunning(ped) then
                    basePulse = basePulse + 15.0
                elseif IsPedWalking(ped) then
                    basePulse = basePulse + 5.0
                end
            end

            if IsPedShooting(ped) then
                basePulse = basePulse + 20.0
            elseif IsPedInMeleeCombat(ped) then
                basePulse = basePulse + 15.0
            end

            local coords = GetEntityCoords(ped)
            local vehicles = GetGamePool('CVehicle')
            for _, v in ipairs(vehicles) do
                if IsVehicleSirenOn(v) then
                    local vCoords = GetEntityCoords(v)
                    if #(coords - vCoords) < 50.0 then
                        basePulse = basePulse + 10.0
                        break
                    end
                end
            end

            if hunger < 20 then basePulse = basePulse + 10.0 end
            if thirst < 20 then basePulse = basePulse + 10.0 end
            basePulse = basePulse + (stress / 5.0)

            targetPulse = basePulse
        end

        if pulse < targetPulse then
            pulse = pulse + math.random(1, 3)
            if pulse > targetPulse then pulse = targetPulse end
        elseif pulse > targetPulse then
            pulse = pulse - math.random(1, 3)
            if pulse < targetPulse then pulse = targetPulse end
        end

        if pulse >= 130.0 and not IsEntityDead(ped) then
            DoScreenFadeOut(1000)
            Wait(1000)
            SetPedToRagdoll(ped, 6000, 6000, 0, false, false, false)
            pulse = 90.0
            targetPulse = 90.0
            Wait(4000)
            DoScreenFadeIn(2000)
        end

        if not IsPauseMenuActive() then
            SendNUIMessage({
                action = 'updatePulse',
                pulse = pulse
            })
        else
            SendNUIMessage({ action = 'hidePulse' })
        end
    end
end)
