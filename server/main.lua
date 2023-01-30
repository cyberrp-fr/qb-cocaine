local QBCore = exports['qb-core']:GetCoreObject()

local buyerPed = nil
local buyerPedNetId = nil

local buyerVehicle = nil
local buyerVehicleNetId = nil

local bodyguard1 = nil
local bodyguard1NetId = nil

local bodyguard2 = nil
local bodyguard2NetId = nil

local bodyguardAnimDict = 'anim@move_m@security_guard'
local bodyguardAnim = 'idle_var_01'
local bodyguard2Anim = 'idle_var_02'

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


local function initBuyerPeds()
    local vehiclePos = Config.Buyer.vehiclePos
    buyerVehicle = CreateVehicleServerSetter(GetHashKey(Config.Buyer.vehicle), "automobile", vehiclePos.x, vehiclePos.y, vehiclePos.z - 0.6, vehiclePos.w)
    Wait(200)
    buyerVehicleNetId = NetworkGetNetworkIdFromEntity(buyerVehicle)
    if DoesEntityExist(buyerVehicle) then
        SetVehicleCustomPrimaryColour(buyerVehicle, 0, 0, 0)
        SetVehicleDoorsLocked(buyerVehicle, 2)
    end

    buyerPed = CreatePed(0, GetHashKey(Config.Buyer.ped), Config.Buyer.pos.xyz, Config.Buyer.pos.w, true)
    Wait(100)
    buyerPedNetId = NetworkGetNetworkIdFromEntity(buyerPed)
    FreezeEntityPosition(buyerPed, true)

    bodyguard1 = CreatePed(0, GetHashKey(Config.Buyer.bodyguard), Config.Buyer.pos.x + 1.5, Config.Buyer.pos.y, Config.Buyer.pos.z, Config.Buyer.pos.w, true)
    Wait(100)
    bodyguard1NetId = NetworkGetNetworkIdFromEntity(bodyguard1)
    FreezeEntityPosition(bodyguard1, true)
    TaskPlayAnim(bodyguard1, bodyguardAnimDict, bodyguardAnim, 8.0, 8.0, -1, 1)

    bodyguard2 = CreatePed(0, GetHashKey(Config.Buyer.bodyguard), Config.Buyer.pos.x, Config.Buyer.pos.y + 1.5, Config.Buyer.pos.z, Config.Buyer.pos.w + 15.0, true)
    Wait(100)
    bodyguard2NetId = NetworkGetNetworkIdFromEntity(bodyguard2)
    FreezeEntityPosition(bodyguard2, true)
    TaskPlayAnim(bodyguard2, bodyguardAnimDict, bodyguard2Anim, 8.0, 8.0, -1, 1)

end

-- CALLBACKS
QBCore.Functions.CreateCallback("qb-cocaine:server:getBuyerData", function (source, cb)
    if buyerVehicleNetId == 0 or buyerVehicleNetId == nil then
        cb({
            buyerPed = nil,
            buyerVehicle = nil,
            bodyguard1 = nil,
            bodyguard2 = nil
        })
    else
        cb({
            buyerPed = buyerPedNetId,
            buyerVehicle = buyerVehicleNetId,
            bodyguard1 = bodyguard1NetId,
            bodyguard2 = bodyguard2NetId
        })
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    Wait(1000)
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
