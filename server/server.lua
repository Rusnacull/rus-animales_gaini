local QRCore = exports['qr-core']:GetCoreObject()
local GainiiLoaded = false

-- use seed
QRCore.Functions.CreateUseableItem("gaina", function(source, item)
    local src = source
    local Player = QRCore.Functions.GetPlayer(src)
    --local sansa = math.random(1,3)
    --if sansa == 1 then
        TriggerClientEvent('rus-animales_gaini:client:plantNewSeed', src, 'oua', 'Oua')
        Player.Functions.RemoveItem('gaina', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items['gaina'], "remove")
    -- elseif sansa == 2 then
    --     TriggerClientEvent('rus-animales_gaini:client:plantNewSeed', src, 'oua', 'Oua')
    --     Player.Functions.RemoveItem('gaina', 1)
    --     TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items['gaina'], "remove")
    -- else
    --     TriggerClientEvent('rus-animales_gaini:client:plantNewSeed', src, 'pene', 'Pene')
    --     Player.Functions.RemoveItem('gaina', 1)
    --     TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items['gaina'], "remove")
    -- end



end)


Citizen.CreateThread(function()
    while true do
        Wait(5000)
        if GainiiLoaded then
            TriggerClientEvent('rus-animales_gaini:client:updateGainiData', -1, Config.Gainii)
        end
    end
end)

Citizen.CreateThread(function()
    TriggerEvent('rus-animales_gaini:server:getGainii')
    GainiiLoaded = true
end)

RegisterServerEvent('rus-animales_gaini:server:saveGaini')
AddEventHandler('rus-animales_gaini:server:saveGaini', function(data, plantId)
    local data = json.encode(data)
    MySQL.Async.execute('INSERT INTO animale_private_gaini (properties, plantid) VALUES (@properties, @plantid)', {
        ['@properties'] = data,
        ['@plantid'] = plantId
    })
end)

-- give seed
RegisterServerEvent('rus-animales_gaini:server:giveSeed')
AddEventHandler('rus-animales_gaini:server:giveSeed', function()
    local src = source
    local Player = QRCore.Functions.GetPlayer(src)
    Player.Functions.AddItem('gaina', math.random(1, 2))
    TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items['gaina'], "add")
end)

-- plant seed
RegisterServerEvent('rus-animales_gaini:server:plantNewSeed')
AddEventHandler('rus-animales_gaini:server:plantNewSeed', function(type, location, labelos)
    local src = source
    local plantId = math.random(111111, 999999)
    local Player = QRCore.Functions.GetPlayer(src)
    local SeedData = {
        id = plantId,
        type = type,
        labelos = labelos,
        x = location.x,
        y = location.y,
        z = location.z,
        hunger = Config.StartingHunger,
        thirst = Config.StartingThirst,
        growth = 0.0,
        quality = 100.0,
        grace = true,
        beingHarvested = false,
        planter = Player.PlayerData.citizenid
    }

    local GainiCount = 0

    for k, v in pairs(Config.Gainii) do
        if v.planter == Player.PlayerData.citizenid then
            GainiCount = GainiCount + 1
        end
    end

    if GainiCount >= Config.MaxGainiCount then
		TriggerClientEvent('QRCore:Notify', src, 'Deja ai : ' .. Config.MaxGainiCount .. ' din cate poti pune', 'error')
        
    else
        table.insert(Config.Gainii, SeedData)
        TriggerEvent('rus-animales_gaini:server:saveGaini', SeedData, plantId)
        TriggerEvent('rus-animales_gaini:server:updateGainii')
    end
end)

-- check plant
RegisterServerEvent('rus-animales_gaini:server:plantHasBeenHarvested')
AddEventHandler('rus-animales_gaini:server:plantHasBeenHarvested', function(plantId)
    for k, v in pairs(Config.Gainii) do
        if v.id == plantId then
            v.beingHarvested = true
        end
    end
    TriggerEvent('rus-animales_gaini:server:updateGainii')
end)

-- distory plant (police)
RegisterServerEvent('rus-animales_gaini:server:destroyGaini')
AddEventHandler('rus-animales_gaini:server:destroyGaini', function(plantId)
    local src = source
    local Player = QRCore.Functions.GetPlayer(src)
    for k, v in pairs(Config.Gainii) do
        if v.id == plantId then
            table.remove(Config.Gainii, k)
        end
    end
	TriggerClientEvent('rus-animales_gaini:client:removeGainiObject', src, plantId)
	TriggerEvent('rus-animales_gaini:server:GainiRemoved', plantId)
	TriggerEvent('rus-animales_gaini:server:updateGainii')
	TriggerClientEvent('QRCore:Notify', src, 'ai luat gaina', 'success')
end)

-- harvest plant
RegisterServerEvent('rus-animales_gaini:server:harvestGaini')
AddEventHandler('rus-animales_gaini:server:harvestGaini', function(plantId)
    local src = source
    local Player = QRCore.Functions.GetPlayer(src)
    local amount
    local label
    local item
	local poorQuality = false
    local goodQuality = false
	local exellentQuality = false
    local hasFound = false
    --print("Culeg din server")
    for k, v in pairs(Config.Gainii) do
        if v.id == plantId then
            --print(plantId)
            for y = 1, #Config.YieldRewards do
                --print(Config.YieldRewards)
                if v.type == Config.YieldRewards[y].type then
                    label = Config.YieldRewards[y].labelos
                    item = Config.YieldRewards[y].item
                    amount = math.random(Config.YieldRewards[y].rewardMin, Config.YieldRewards[y].rewardMax)
                    local quality = math.ceil(v.quality)
                    hasFound = true
                    table.remove(Config.Gainii, k)
					if quality > 0 and quality < 65 then -- poor
                        poorQuality = true
					elseif quality >= 65 and quality < 85 then -- good
						goodQuality = true
					elseif quality >= 85 then -- excellent
						exellentQuality = true
                    end
                end
            end
        end
    end
	-- give rewards

    if hasFound then
        --print("Culeg si dau produse")
        if poorQuality then
			local pooramount = math.random(1,3)
			Player.Functions.AddItem(item, pooramount)
			TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items[item], "add")

			Player.Functions.SetMetaData("repfermier", Player.PlayerData.metadata["repfermier"] + pooramount)
			Wait(5000)
			TriggerEvent('rus-animales_gaini:server:repfermier', src)
        elseif goodQuality then
			local goodamount = math.random(3,6)
			Player.Functions.AddItem(item, goodamount)
			TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items[item], "add")

			Player.Functions.SetMetaData("repfermier", Player.PlayerData.metadata["repfermier"] + goodamount)
			Wait(5000)
			TriggerEvent('rus-animales_gaini:server:repfermier', src)
		elseif exellentQuality then
			local exellentamount = math.random(6,12)
			Player.Functions.AddItem(item, exellentamount)
			TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items[item], "add")
			Player.Functions.AddItem('gaina', 1)
			TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items[item], "add")

			Player.Functions.SetMetaData("repfermier", Player.PlayerData.metadata["repfermier"] + exellentamount)
			Wait(5000)
			TriggerEvent('rus-animales_gaini:server:repfermier', src)
		else
			print("Ceva este in neregula cod24361 rus-animales_gaini 193!")
        end
		TriggerClientEvent('rus-animales_gaini:client:removeGainiObject', src, plantId)
        TriggerEvent('rus-animales_gaini:server:GainiRemoved', plantId)
        TriggerEvent('rus-animales_gaini:server:updateGainii')
    end
end)

RegisterServerEvent('rus-animales_gaini:server:updateGainii')
AddEventHandler('rus-animales_gaini:server:updateGainii', function()
	local src = source
    TriggerClientEvent('rus-animales_gaini:client:updateGainiData', src, Config.Gainii)
end)

-- water plant
RegisterServerEvent('rus-animales_gaini:server:waterGaini')
AddEventHandler('rus-animales_gaini:server:waterGaini', function(plantId)
    local src = source
    local Player = QRCore.Functions.GetPlayer(src)
    for k, v in pairs(Config.Gainii) do
        if v.id == plantId then
            Config.Gainii[k].thirst = Config.Gainii[k].thirst + Config.ThirstIncrease
            if Config.Gainii[k].thirst > 100.0 then
                Config.Gainii[k].thirst = 100.0
            end
        end
    end
    Player.Functions.RemoveItem('wateringcan', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items['wateringcan'], "add")
    Wait(2000)
    Player.Functions.AddItem('wateringcan_goala', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items['wateringcan_goala'], "add")
    
    
    
    TriggerEvent('rus-animales_gaini:server:updateGainii')
end)

-- feed plant
RegisterServerEvent('rus-animales_gaini:server:feedGaini')
AddEventHandler('rus-animales_gaini:server:feedGaini', function(plantId)
    local src = source
    local Player = QRCore.Functions.GetPlayer(src)
    for k, v in pairs(Config.Gainii) do
        if v.id == plantId then
            Config.Gainii[k].hunger = Config.Gainii[k].hunger + Config.HungerIncrease
            if Config.Gainii[k].hunger > 100.0 then
                Config.Gainii[k].hunger = 100.0
            end
        end
    end
    Player.Functions.RemoveItem('corn', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items['corn'], "remove")
    TriggerEvent('rus-animales_gaini:server:updateGainii')
end)

-- update plant
RegisterServerEvent('rus-animales_gaini:server:updateIndianGainii')
AddEventHandler('rus-animales_gaini:server:updateIndianGainii', function(id, data)
    local result = MySQL.query.await('SELECT * FROM animale_private_gaini WHERE plantid = @plantid', {
        ['@plantid'] = id
    })
    if result[1] then
        local newData = json.encode(data)
        MySQL.Async.execute('UPDATE animale_private_gaini SET properties = @properties WHERE plantid = @id', {
            ['@properties'] = newData,
            ['@id'] = id
        })
    end
end)

-- remove plant
RegisterServerEvent('rus-animales_gaini:server:GainiRemoved')
AddEventHandler('rus-animales_gaini:server:GainiRemoved', function(plantId)
    local result = MySQL.query.await('SELECT * FROM animale_private_gaini')
    if result then
        for i = 1, #result do
            local plantData = json.decode(result[i].properties)
            if plantData.id == plantId then
                MySQL.Async.execute('DELETE FROM animale_private_gaini WHERE id = @id', {
                    ['@id'] = result[i].id
                })
                for k, v in pairs(Config.Gainii) do
                    if v.id == plantId then
                        table.remove(Config.Gainii, k)
                    end
                end
            end
        end
    end
end)

-- get plant
RegisterServerEvent('rus-animales_gaini:server:getGainii')
AddEventHandler('rus-animales_gaini:server:getGainii', function()
    local data = {}
    local result = MySQL.query.await('SELECT * FROM animale_private_gaini')
    if result[1] then
        for i = 1, #result do
            local plantData = json.decode(result[i].properties)
            print('Incarc Gainile cu ID: '..plantData.id)
            table.insert(Config.Gainii, plantData)
        end
    end
end)

-- plant timer
Citizen.CreateThread(function()
    while true do
        Wait(Config.GrowthTimer*60)
        for i = 1, #Config.Gainii do
            if Config.Gainii[i].growth < 100 then
                if Config.Gainii[i].grace then
                    Config.Gainii[i].grace = false
                else
                    Config.Gainii[i].thirst = Config.Gainii[i].thirst - 0.5
                    Config.Gainii[i].hunger = Config.Gainii[i].hunger - 0.5
                    Config.Gainii[i].growth = Config.Gainii[i].growth + 1

                    if Config.Gainii[i].quality > 100 then
                        Config.Gainii[i].quality = 100
                    end

                    if Config.Gainii[i].growth > 100 then
                        Config.Gainii[i].growth = 100
                    end

                    if Config.Gainii[i].hunger < 0 then
                        Config.Gainii[i].hunger = 0
                    end

                    if Config.Gainii[i].thirst < 0 then
                        Config.Gainii[i].thirst = 0
                    end

                    if Config.Gainii[i].quality < 25 then
                        Config.Gainii[i].quality = 25
                    end

                    if Config.Gainii[i].thirst < 85 or Config.Gainii[i].hunger < 85 then
                        Config.Gainii[i].quality = Config.Gainii[i].quality - 0.5
                    end

                    if Config.Gainii[i].thirst > 90 and Config.Gainii[i].hunger > 90 and Config.Gainii[i].quality < 100 then
                        Config.Gainii[i].quality = Config.Gainii[i].quality + 4
                        Config.Gainii[i].growth = Config.Gainii[i].growth + 4
                    end
                end
            end
            TriggerEvent('rus-animales_gaini:server:updateIndianGainii', Config.Gainii[i].id, Config.Gainii[i])
        end
        TriggerEvent('rus-animales_gaini:server:updateGainii')
    end
end)

-- used by harvest to show new dealer reputation
RegisterServerEvent('rus-animales_gaini:server:repfermier')
AddEventHandler('rus-animales_gaini:server:repfermier', function(source)
    local src = source
	local Player = QRCore.Functions.GetPlayer(src)
	local curRep = Player.PlayerData.metadata["repfermier"]
	TriggerClientEvent('QRCore:Notify', src, 'Ai Crescut Reputatia cu '.. curRep, 'primary')
end)
