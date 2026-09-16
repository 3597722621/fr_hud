local function PushUiScale()
    local rx, ry = GetActiveScreenResolution()
    SendNUIMessage({
        action = 'setUiScale',
        resX = rx,
        resY = ry,
        safeZone = GetSafeZoneSize()
    })
end

CreateThread(function()
    Wait(500)
    PushUiScale()
    while true do
        Wait(2000)
        PushUiScale()
    end
end)

-- Shared cinematic flag for all HUD modules
RegisterNetEvent('hud:client:ToggleCinematic', function(state)
    LocalPlayer.state:set('hudCinematic', state == true, false)
end)
