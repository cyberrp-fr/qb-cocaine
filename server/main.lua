local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('qb-cocaine:server:rewardCocaLeaves')
AddEventHandler('qb-cocaine:server:rewardCocaLeaves', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local rewardItem = Config['Reward']['coca_leaves']['item']
    local min = Config['Reward']['coca_leaves']['minAmount']
    local max = Config['Reward']['coca_leaves']['maxAmount']
    local randomAmount = math.random(min, max)
    Player.Functions.AddItem(rewardItem, randomAmount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[rewardItem], 'add')
end)

RegisterServerEvent('qb-cocaine:server:processCocaine')
AddEventHandler('qb-cocaine:server:processCocaine', function ()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local item = Config['Reward']['coca_leaves']['item']
    local minAmount = Config['Reward']['cocaine_bag']['amountOfLeaves']
    if not QBCore.Functions.HasItem(src, item, minAmount) then
        QBCore.Functions.Notify(src, Lang:t("error.not_enough_coca_leaves"), "error")
        return
    end

    Player.Functions.RemoveItem(item, minAmount)

    local rewardItem = Config['Reward']['cocaine_bag']['item']
    local rewardAmount = math.random(1, 2)
    Player.Functions.AddItem(rewardItem, rewardAmount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[rewardItem], 'add')
end)

RegisterServerEvent('qb-cocaine:server:sellCocaine')
AddEventHandler('qb-cocaine:server:sellCocaine', function (amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not QBCore.Functions.HasItem(src, Config.Reward['cocaine_bag']['item'], amount) then
        QBCore.Functions.Notify(src, Lang:t("error.not_enough_cocaine"), "error", 200)
        return
    end

    Player.Functions.RemoveItem(Config.Reward['cocaine_bag']['item'], amount)

    local rewardMoneyType = Config.RewardMoneyType
    local rewardAmount = amount * Config.SellPrice
    Player.Functions.AddMoney(rewardMoneyType, rewardAmount)

    QBCore.Functions.Notify(src, Lang:t("success.sold_amount", { amount = amount, reward = rewardAmount}), "success", 1000)
end)

local buyerPed = nil
local buyerVehicle = nil
local bodyguard1 = nil
local bodyguard2 = nil
local bodyguardAnimDict = 'anim@move_m@security_guard'
local bodyguardAnim = 'idle_var_01'
local bodyguard2Anim = 'idle_var_02'

local function initBuyerPeds()
    local vehiclePos = Config.Buyer.vehiclePos
    buyerVehicle = CreateVehicle(GetHashKey(Config.Buyer.vehicle), vector3(vehiclePos.xyz), vehiclePos.w, true)
    SetVehicleCustomPrimaryColour(buyerVehicle, 0, 0, 0)
    SetVehicleDoorsLocked(buyerVehicle, 2)

    -- SetVehicleEngineOn(buyerVehicle, true)
    -- SetVehicleLights(buyerVehicle, 2)

    buyerPed = CreatePed(0, GetHashKey(Config.Buyer.ped), Config.Buyer.pos.xyz, Config.Buyer.pos.w, true)
    FreezeEntityPosition(buyerPed, true)

    bodyguard1 = CreatePed(0, GetHashKey(Config.Buyer.bodyguard), Config.Buyer.pos.x + 1.5, Config.Buyer.pos.y, Config.Buyer.pos.z, Config.Buyer.pos.w, true)
    FreezeEntityPosition(bodyguard1, true)
    TaskPlayAnim(bodyguard1, bodyguardAnimDict, bodyguardAnim, 8.0, 8.0, -1, 1)

    bodyguard2 = CreatePed(0, GetHashKey(Config.Buyer.bodyguard), Config.Buyer.pos.x, Config.Buyer.pos.y + 1.5, Config.Buyer.pos.z, Config.Buyer.pos.w + 15.0, true)
    FreezeEntityPosition(bodyguard2, true)
    TaskPlayAnim(bodyguard2, bodyguardAnimDict, bodyguard2Anim, 8.0, 8.0, -1, 1)

end

-- CALLBACKS
QBCore.Functions.CreateCallback("qb-cocaine:server:getBuyerData", function (source, cb)
    cb({
        buyerPed = NetworkGetNetworkIdFromEntity(buyerPed),
        buyerVehicle = NetworkGetNetworkIdFromEntity(buyerVehicle),
        bodyguard1 = NetworkGetNetworkIdFromEntity(bodyguard1),
        bodyguard2 = NetworkGetNetworkIdFromEntity(bodyguard2)
    })
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    Wait(500)

    initBuyerPeds()
end)

AddEventHandler("onResourceStop", function (resourceName)
    if resourceName == GetCurrentResourceName() then
        DeleteEntity(buyerPed)
        DeleteEntity(bodyguard1)
        DeleteEntity(bodyguard2)
        DeleteEntity(buyerVehicle)
    end
end)
