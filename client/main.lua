local QBCore = exports['qb-core']:GetCoreObject()
local busy = false -- check if player already either picking or processing

local isInsideZone = false -- is player inside picking zone
local isInsideProcessingZone = false -- is player inside processing zone

local animLoaded = false -- picking anim loaded 
local processAnimLoaded = false -- processing anim loaded
local playerPed = nil

-- loops state
local cocaHarvestingLoopIsRunning = false
local cocaProcessingLoopIsRunning = false

-- help text (qb-core:drawtext)
local helpTextShowing = false

local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(50)
    end
end

local function loadModel(model)
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
local function pickCoca()
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
    TaskPlayAnim(playerPed, animDict, anim, 8.0, 8.0, animDuration, 0)
    Wait(animDuration)

    TriggerServerEvent('qb-cocaine:server:rewardCocaLeaves')
    busy = false
end

-- function that handles coca processing
local function processCocaIntoCocaine()
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
    TaskPlayAnim(playerPed, animDict, anim, 8.0, 8.0, animDuration, 0)
    Wait(animDuration)

    TriggerServerEvent('qb-cocaine:server:processCocaine')

    busy = false
end

-- coca picking zone loop
-- this loop is only run when inside zone
local function cocaPickingZoneLoop()
    if not cocaHarvestingLoopIsRunning then
        Citizen.CreateThread(function ()
            cocaHarvestingLoopIsRunning = true
            while isInsideZone do
                if IsControlJustPressed(0, 51) then
                    pickCoca()
                end
                Citizen.Wait(1)
            end
            cocaHarvestingLoopIsRunning = false
        end)
    end
end

-- coca processing zone loop
-- this loop is only run when inside zone
local function cocaProcessingZoneLoop()
    if not cocaProcessingLoopIsRunning then
        exports["qb-core"]:DrawText(Lang:t("info.process_coca"), "left")
        helpTextShowing = true

        Citizen.CreateThread(function ()
            cocaProcessingLoopIsRunning = true
            while isInsideProcessingZone do
                if IsControlJustPressed(0, 51) then
                    processCocaIntoCocaine()
                end
                Citizen.Wait(1)
            end
            cocaProcessingLoopIsRunning = false
        end)
    end
end


-- Buyer Globals
local buyerAnimLoaded = false
local buyerAnimDict = 'mp_ped_interaction'
local buyerAnim = 'handshake_guy_a'

local buyerDataSynced = false -- has buyer peds and vehicle data been retrieved from server
local buyerObjectsSynced = false -- has buyer peds and vehicle been configured

local buyerVehicle = nil
local buyerPed = nil
local bodyguard1 = nil
local bodyguard2 = nil
local buyerZoneIsInside = false
local buyerZoneLoopIsRunning = false

-- sell cocaine to buyer function
local function sellCocaineToBuyer()
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
    TaskPlayAnim(playerPed, buyerAnimDict, buyerAnim, 8.0, 8.0, animDuration, 0)
    TaskPlayAnim(buyerPed, buyerAnimDict, buyerAnim, 8.0, 8.0, animDuration, 0)
    Wait(animDuration)

    TriggerServerEvent('qb-cocaine:server:sellCocaine', amount)
end

-- buyer zone loop
local function buyerZoneLoop()
    if not buyerZoneLoopIsRunning then
        Citizen.CreateThread(function ()
            buyerZoneLoopIsRunning = true
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
            buyerZoneLoopIsRunning = false
        end)
    end
end

-- function that syncs buyer ped
local function syncBuyerPeds()
    local bodyguardAnimDict = 'anim@move_m@security_guard'
    loadAnimDict(bodyguardAnimDict)
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
        if data.buyerVehicle == nil or data.buyerPed == nil or data.bodyguard1 == nil or data.bodyguard2 == nil then
            return
        end

        buyerPed = NetToPed(data.buyerPed)
        buyerVehicle = NetToVeh(data.buyerVehicle)
        bodyguard1 = NetToPed(data.bodyguard1)
        bodyguard2 = NetToPed(data.bodyguard2)

        if buyerVehicle ~= nil and buyerVehicle ~= 0 then
            buyerDataSynced = true
        end
    end)
end

AddEventHandler("onClientResourceStart", function (resourceName)
    if resourceName == GetCurrentResourceName() then
        loadModel(Config.Buyer.vehicle)
        loadModel(Config.Buyer.ped)
        loadModel(Config.Buyer.bodyguard)
    end
end)

-- =========
-- MAIN LOOP
-- =========
CreateThread(function ()
    while not buyerDataSynced do
        Wait(100)
        syncBuyerData()
        if buyerVehicle ~= nil and buyerVehicle ~= 0 then
            buyerDataSynced = true
        end
    end

    while true do
        playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local playerHeading = GetEntityHeading(playerPed)
        local cocaFieldCoords = Config.PickingZone
        -- local cocaProcessingCoords = Config.ProcessingZone

        -- ==================
        -- === Harvesting ===
        -- ==================
        -- picking zone
        local dist = #(playerCoords - cocaFieldCoords)

        -- if is near coca field, then start loop and show help text
        if dist <= 17.0 then
            isInsideZone = true
            exports['qb-core']:DrawText(Lang:t("info.pick_coca_leaves"), 'left')
            helpTextShowing = true
            cocaPickingZoneLoop()
        else -- if not then stop showing help text as the player is far away
            isInsideZone = false
        end

        -- ==================
        -- === Processing ===
        -- ==================
        dist = #(playerCoords - Config.ProcessingZone)
        if dist <= 10.0 and (playerHeading <= 360.0 and playerHeading >= 305.0) then
            isInsideProcessingZone = true
            exports["qb-core"]:DrawText(Lang:t("info.process_coca"), "left")
            helpTextShowing = true
            cocaProcessingZoneLoop()
        else
            isInsideProcessingZone = false
        end

        if helpTextShowing and not isInsideZone and not isInsideProcessingZone then
            exports["qb-core"]:HideText()
            helpTextShowing = false
        end

        -- =============
        -- === Buyer ===
        -- =============

        dist = #(playerCoords - Config['Buyer']['pos'].xyz)

        if not buyerObjectsSynced and buyerDataSynced and dist <= 50.0 then
            if buyerPed ~= nil and buyerVehicle ~= nil then
                if GetIsVehicleEngineRunning(buyerVehicle) == false then
                    syncBuyerPeds()
                    buyerObjectsSynced = true
                end
            end
        end

        if dist <= 3.0 and (playerHeading <= 360.0 and playerHeading >= 260.0) then
            buyerZoneIsInside = true
            buyerZoneLoop()
        else
            buyerZoneIsInside = false
        end

        -- wait 1 seconds
        Wait(1000)
    end
end)
