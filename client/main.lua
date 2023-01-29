local QBCore = exports['qb-core']:GetCoreObject()
local busy = false -- check if player already either picking or processing

local cocaPickingZone = nil -- coca leaves picking polyzone (boxzone)
local cocaProcessingZone = nil -- coca processing polyzone (boxzone)

local isInsideZone = false -- is player inside picking zone
local isInsideProcessingZone = false -- is player inside processing zone

local animLoaded = false -- picking anim loaded 
local processAnimLoaded = false -- processing anim loaded
local ped = PlayerPedId()

local loadAnimDict = function(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(50)
    end
end

local loadModel = function(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

-- function that handles picking coca leaves
local pickCoca = function()
    if busy then
        return
    end
    busy = true

    local animDict = 'amb@medic@standing@kneel@idle_a'

    if not animLoaded then
        loadAnimDict(animDict)
        animLoaded = true
    end

    local animDuration = 3000
    local anim = 'idle_a'
    TaskPlayAnim(ped, animDict, anim, 8.0, 8.0, animDuration, 0)
    Wait(animDuration)

    TriggerServerEvent('qb-cocaine:server:rewardCocaLeaves')
    busy = false
end

-- function that handles coca processing
local processCocaIntoCocaine = function ()
    if busy then
        return
    end

    local requiredItem = Config['Reward']['coca_leaves']['item']
    local requiredAmount = Config['Reward']['cocaine_bag']['amountOfLeaves']
    if not QBCore.Functions.HasItem(requiredItem, requiredAmount) then
        QBCore.Functions.Notify(Lang:t("error.not_enough_coca_leaves"), "error", 100)
        return
    end

    busy = true

    local animDict = 'anim@amb@business@coc@coc_unpack_cut@'
    local anim = 'fullcut_cycle_cokecutter'

    if not processAnimLoaded then
        loadAnimDict(animDict)
        processAnimLoaded = true
    end

    local animDuration = 3000
    TaskPlayAnim(ped, animDict, anim, 8.0, 8.0, animDuration, 0)
    Wait(animDuration)

    TriggerServerEvent('qb-cocaine:server:processCocaine')

    busy = false
end

-- coca picking zone loop
-- this loop is only run when inside zone
local cocaPickingZoneLoop = function()
    Citizen.CreateThread(function ()
        while isInsideZone do
            if IsControlJustPressed(0, 51) then
                pickCoca()
            end
            Citizen.Wait(1)
        end
    end)
end

-- coca processing zone loop
-- this loop is only run when inside zone
local cocaProcessingZoneLoop = function ()
    Citizen.CreateThread(function ()
        while isInsideProcessingZone do
            if IsControlJustPressed(0, 51) then
                processCocaIntoCocaine()
            end
            Citizen.Wait(1)
        end
    end)
end

-- function that creates coca picking zone
-- this is done for optimization, to create when near and destroy when far away
local initCocaPickingZone = function ()
    -- coca leaves picking zone 
    cocaPickingZone = BoxZone:Create(Config.PickingZone, 25.0, 35.0, {
        name = 'Champ Coca',
        useZ = true,
        heading = Config.PickingZoneHeading,
        debugPoly = true,
    })

    cocaPickingZone:onPlayerInOut(function(isPointInside)
        isInsideZone = isPointInside
        -- if player inside zone
        if isPointInside then
            exports['qb-core']:DrawText(Lang:t("info.pick_coca_leaves"), 'left')
            cocaPickingZoneLoop()
        else
            exports['qb-core']:HideText()
        end
    end)
end

-- function that destroys coca picking zone
local destroyCocaPickingZone = function ()
    if cocaPickingZone ~= nil then
        cocaPickingZone:destroy()
        cocaPickingZone = nil
    end
end

-- function that creates coca processing zone
-- this is done for optimization, to create when near and destroy when far away
local initCocaProcessingZone = function ()
    -- coca leaves processing into cocaine zone
    cocaProcessingZone = BoxZone:Create(Config.ProcessingZone, 2.0, 8.0, {
        name = 'Traitement Coca',
        useZ = true,
        heading = Config.ProcessingZoneHeading,
        debugPoly = true,
    })

    cocaProcessingZone:onPlayerInOut(function (isPointInside)
        isInsideProcessingZone = isPointInside

        if isPointInside then
            exports['qb-core']:DrawText(Lang:t("info.process_coca"), 'left')
            cocaProcessingZoneLoop()
        else
            exports['qb-core']:HideText()
        end
    end)
end

-- function that destroys coca processing zone
local destroyCocaProcessingZone = function ()
    if cocaProcessingZone ~= nil then
        cocaProcessingZone:destroy()
        cocaProcessingZone = nil
    end
end


-- Buyer Globals
local buyerLoaded = false
local buyerAnimLoaded = false
local buyerAnimDict = 'mp_ped_interaction'
local buyerAnim = 'handshake_guy_a'

local buyerDataSynced = false
local buyerVehicle = nil
local buyerPed = nil
local bodyguard1 = nil
local bodyguard2 = nil
local buyerZone = nil
local buyerZoneIsInside = false

-- sell cocaine to buyer function
local sellCocaineToBuyer = function ()
    local requiredItem = Config.Reward['cocaine_bag']['item']

    local i = 0
    local amount = 10
    while i < 10 do
        if QBCore.Functions.HasItem(requiredItem, amount) then
            break
        end

        amount = amount-1
        i = i+1
    end

    if amount == 0 then
        QBCore.Functions.Notify(Lang:t("error.has_no_cocaine"), "error", 100)
        return
    end

    if not buyerAnimLoaded then
        loadAnimDict(buyerAnimDict)
        buyerAnimLoaded = true
    end

    local animDuration = 1600
    TaskPlayAnim(ped, buyerAnimDict, buyerAnim, 8.0, 8.0, animDuration, 0)
    TaskPlayAnim(buyerPed, buyerAnimDict, buyerAnim, 8.0, 8.0, animDuration, 0)
    Wait(animDuration)

    TriggerServerEvent('qb-cocaine:server:sellCocaine', amount)
end

-- buyer zone loop
local function buyerZoneLoop()
    Citizen.CreateThread(function ()
        while buyerZoneIsInside do
            QBCore.Functions.DrawText3D(Config.Buyer.pos.x, Config.Buyer.pos.y, Config.Buyer.pos.z + 0.3, Lang:t("info.press_sell_cocaine"))

            -- detect click
            if IsControlJustPressed(0, 51) then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local dist = #(playerCoords - Config.Buyer['pos'].xyz)
                if dist <= 1.5 and not busy then
                    busy = true
                    sellCocaineToBuyer() -- trigger sell cocaine function
                    busy = false
                end
            end

            Citizen.Wait(1)
        end
    end)
end

-- function that syncs buyer ped
local function syncBuyerPeds()
    local bodyguardAnimDict = 'anim@move_m@security_guard'
    local bodyguardAnim = 'idle_var_01'
    local bodyguard2Anim = 'idle_var_02'

    loadAnimDict(bodyguardAnimDict)
    loadModel(Config.Buyer.vehicle)

    Wait(200)

    -- [start] sync vehicle
    FreezeEntityPosition(buyerVehicle, true)
    SetEntityInvincible(buyerVehicle, true)
    SetVehicleEngineOn(buyerVehicle, true)
    SetVehicleLights(buyerVehicle, 2)
    SetVehicleDoorsLocked(buyerVehicle, 2)
    -- [end] sync vehicle


    -- [start] sync peds
    FreezeEntityPosition(buyerPed, true)
    SetEntityInvincible(buyerPed, true)
    SetBlockingOfNonTemporaryEvents(buyerPed, true)

    FreezeEntityPosition(bodyguard1, true)
    SetEntityInvincible(bodyguard1, true)
    SetBlockingOfNonTemporaryEvents(bodyguard1, true)

    FreezeEntityPosition(bodyguard2, true)
    SetEntityInvincible(bodyguard2, true)
    SetBlockingOfNonTemporaryEvents(bodyguard2, true)
    -- [end] sync peds
end

-- retrieving peds and vehicle IDs from server
local function syncBuyerData()
    QBCore.Functions.TriggerCallback("qb-cocaine:server:getBuyerData", function (data)
        if data.buyerPed == 0 or data.buyerPed == nil then
            return
        end

        buyerPed = NetworkGetEntityFromNetworkId(data.buyerPed)
        buyerVehicle = NetworkGetEntityFromNetworkId(data.buyerVehicle)
        bodyguard1 = NetworkGetEntityFromNetworkId(data.bodyguard1)
        bodyguard2 = NetworkGetEntityFromNetworkId(data.bodyguard2)
    end)
end

local function createBuyerZone()
    -- boxzone
    buyerZone = BoxZone:Create(vector3(Config.Buyer['pos'].xy - 0.25, Config.Buyer['pos'].z), 2.0, 1.0, {
        name = 'Acheteur Cocaine',
        useZ = true,
        heading = 315.0,
        debugPoly = false,
    })

    buyerZone:onPlayerInOut(function (isInside)
        buyerZoneIsInside = isInside
        if isInside then
            buyerZoneLoop()
        end
    end)
end

local function destroyBuyerZone()
    buyerZone:destroy()
end

-- =========
-- MAIN LOOP
-- =========
Citizen.CreateThread(function ()

    Citizen.Wait(2000)
    if not buyerDataSynced then
        syncBuyerData()
        Citizen.Wait(1000)
        if buyerPed ~= nil and buyerVehicle ~= nil then
            buyerDataSynced = true
            syncBuyerPeds()
        end
    end

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local cocaFieldCoords = Config.PickingZone
        local cocaProcessingCoords = Config.ProcessingZone

        -- picking zone
        local dist = #(playerCoords - cocaFieldCoords)

        -- create coca picking zone if distance between player and field less than 30m
        if dist <= 30.0 then
            if cocaPickingZone == nil then
                initCocaPickingZone()
            end
        else -- if not then destroy the zone as the player is far away
            if cocaPickingZone ~= nil then
                destroyCocaPickingZone()
            end
        end

        -- processing zone
        dist = #(playerCoords - cocaProcessingCoords)

        -- create coca processing zone if distance between player and processing table less than 10m
        if dist <= 10.0 then
            if cocaProcessingZone == nil then
                initCocaProcessingZone()
            end
        else -- else destroy the zone as player is far away
            if cocaProcessingZone ~= nil then
                destroyCocaProcessingZone()
            end
        end

        -- buyer zone
        dist = #(playerCoords - Config['Buyer']['pos'].xyz)
        if dist <= 30.0 then
            if not buyerLoaded then
                createBuyerZone()
                buyerLoaded = true
            end
        else
            if buyerLoaded then
                destroyBuyerZone()
                buyerLoaded = false
            end
        end

        -- wait 2 seconds
        Citizen.Wait(2000)
    end
end)
