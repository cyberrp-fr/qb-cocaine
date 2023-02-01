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

