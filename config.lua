Config = {}

Config.SellPrice = 1000 -- price which the buyer will pay per cocaine bag unit

-- reward money type (cash|bank|crypto)
Config.RewardMoneyType = 'cash'

-- picking zone
Config.PickingZone = vector3(5345.71, -5183.45, 29.97)
Config.PickingZoneHeading = 311.3

-- processing zone
Config.ProcessingZone = vector3(5065.99, -4590.76, 2.86)
Config.ProcessingZoneHeading = 339.0

-- Rewards
Config.Reward = {
    ['coca_leaves'] = {
        item = 'coca_leaves',
        minAmount = 2,
        maxAmount = 4,
    },
    ['cocaine_bag'] = {
        item = 'cocaine_bag',
        amountOfLeaves = 12, -- amount of coca leaf items to make on cocaine_bag
    }
}

-- Buyer
Config.Buyer = {
    ped = 'ig_djsolmike', -- ped model of buyer
    bodyguard = 'u_m_m_jewelsec_01', -- ped model of bodyguards of the buyer
    pos = vector4(2487.59, 4960.33, 43.84, 127.95),

    bodyguard1Pos = vector4(2489.08, 4960.33, 43.82, 127.56),
    bodyguard2Pos = vector4(2487.59, 4961.83, 43.82, 141.73),

    vehicle = 'baller', -- vehicle model of buyer
    vehiclePos = vector4(2490.77, 4963.66, 43.82, 135.17)
}
