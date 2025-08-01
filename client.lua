local QBCore = exports['qb-core']:GetCoreObject()
local postals, nearest, blip = {}, { code = "N/A", x = 0.0, y = 0.0, dist = 99999 }, nil

-- HUD GİZLEME DEĞİŞKENİ (HERKES BURADAN OKUYACAK)
local hudKompleKapali = false

-- HUD KAPAT
RegisterCommand('hudkapat', function()
    hudKompleKapali = true
    exports['jordqn_hud']:hudVisibility(false)
    DisplayRadar(false)
    QBCore.Functions.Notify("HUD ve Minimap kapatıldı.", "error")
end, false)

-- HUD AÇ
RegisterCommand('hudaç', function()
    hudKompleKapali = false
    exports['jordqn_hud']:hudVisibility(true)
    if IsPedInAnyVehicle(PlayerPedId(), false) or not Config.radarOnlyInCar then
        DisplayRadar(true)
    end
    QBCore.Functions.Notify("HUD ve Minimap açıldı.", "success")
end, false)

-- HER FRAME'DE HUD ZORLA KAPALI TUT (DİĞER SCRIPTLER MÜDAHALE EDEMEZ)
Citizen.CreateThread(function()
    while true do
        if hudKompleKapali then
            exports['jordqn_hud']:hudVisibility(false)
            DisplayRadar(false)
        end
        Citizen.Wait(0)
    end
end)

-- POSTALLARI YÜKLE
Citizen.CreateThread(function()
    local file = LoadResourceFile(GetCurrentResourceName(), Config.PostalFile)
    if file then
        for _, data in ipairs(json.decode(file)) do
            postals[#postals+1] = { x = data.x, y = data.y, code = tostring(data.code) }
        end
    else
        print("postal json yok, ananı avradını!")
    end
end)

-- EN YAKIN POSTALI BUL
local function getNearestPostal(pos)
    local minDist, code, px, py = 99999, "N/A"
    for i = 1, #postals do
        local dist = ((postals[i].x - pos.x)^2 + (postals[i].y - pos.y)^2) ^ 0.5
        if dist < minDist then
            minDist, code, px, py = dist, postals[i].code, postals[i].x, postals[i].y
        end
    end
    nearest.code, nearest.dist, nearest.x, nearest.y = code, minDist, px, py
end

-- ANA POSTAL DÖNGÜSÜ (EN YAKIN POSTALI GÜNCELLE)
Citizen.CreateThread(function()
    while #postals == 0 do Citizen.Wait(200) end
    while true do
        local ped = PlayerPedId()
        if ped ~= 0 then
            local coords = GetEntityCoords(ped)
            getNearestPostal({ x = coords.x, y = coords.y })
        end
        Citizen.Wait(Config.Refresh)
    end
end)

-- POSTAL YAZISINI SADECE HUD AÇIKSA GÖSTER!
Citizen.CreateThread(function()
    while true do
        if nearest.code ~= "N/A" and not hudKompleKapali then
            drawText(string.format(Config.Text.Format, nearest.code, nearest.dist), Config.Text.PosX, Config.Text.PosY)
        end
        Citizen.Wait(0)
    end
end)

function drawText(text, x, y)
    SetTextFont(Config.Text.Font or 4)
    SetTextScale(Config.Text.Scale or 0.42, Config.Text.Scale or 0.42)
    SetTextColour(
        (Config.Text.Colour and Config.Text.Colour[1]) or 255,
        (Config.Text.Colour and Config.Text.Colour[2]) or 255,
        (Config.Text.Colour and Config.Text.Colour[3]) or 255,
        Config.Text.Alpha or 255
    )
    if Config.Text.Outline then SetTextOutline() end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- /postal [kod] komutu ile blip/waypoint ekle
RegisterCommand("postal", function(_, args)
    if not args[1] then
        if nearest and nearest.code ~= "N/A" then
            setPostalBlip(nearest.x, nearest.y, nearest.code)
        end
        return
    end
    local userPostal = tostring(args[1])
    for i, v in ipairs(postals) do
        if tostring(v.code) == userPostal then
            setPostalBlip(v.x, v.y, v.code)
            return
        end
    end
    TriggerEvent("chat:addMessage", {
        color = { 255, 0, 0 },
        args = { "Postal", "Böyle bir postal yok!" }
    })
end)

function setPostalBlip(x, y, code)
    if blip then
        RemoveBlip(blip)
        blip = nil
    end
    blip = AddBlipForCoord(x, y, 0.0)
    SetBlipRoute(blip, true)
    SetBlipSprite(blip, Config.Blip.Sprite)
    SetBlipColour(blip, Config.Blip.Color)
    SetBlipRouteColour(blip, Config.Blip.Color)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("Postal: " .. code)
    EndTextCommandSetBlipName(blip)
    SetNewWaypoint(x, y)
    TriggerEvent("chat:addMessage", {
        color = { 0, 255, 0 },
        args = { "Postal", code .. " için rota ayarlandı." }
    })
end

Citizen.CreateThread(function()
    while true do
        if blip and nearest and nearest.dist < Config.Blip.DistToDelete then
            RemoveBlip(blip)
            blip = nil
            TriggerEvent("chat:addMessage", {
                color = { 255, 255, 0 },
                args = { "Postal", "Postala vardın." }
            })
        end
        Citizen.Wait(500)
    end
end)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/postal', 'GPS rota/waypoint ayarla', {
        { name = 'Kod', help = 'Gideceğin postal kodu (örn: 4020)' }
    })
end)

exports('getPostal', function()
    return nearest and nearest.code or nil
end)
