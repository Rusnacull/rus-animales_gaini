local QRCore = exports['qr-core']:GetCoreObject()
isLoggedIn = false
local isBusy = false
PlayerJob = {}

RegisterNetEvent('QRCore:Client:OnPlayerLoaded')
AddEventHandler('QRCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerJob = QRCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QRCore:Client:OnJobUpdate')
AddEventHandler('QRCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

local SpawnedGainii = {}
local InteractedGaini = nil
local HarvestedGainii = {}
local canHarvest = true
local closestGaini = nil
local isDoingAction = false

Citizen.CreateThread(function()
    while true do
    Wait(150)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local inRange = false

    for i = 1, #Config.Gainii do
        local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Gainii[i].x, Config.Gainii[i].y, Config.Gainii[i].z, true)

		if dist < 50.0 then
			inRange = true
			local hasSpawned = false
			local needsUpgrade = false
			local upgradeId = nil
			local tableRemove = nil

			for z = 1, #SpawnedGainii do
				local p = SpawnedGainii[z]
				if p.id == Config.Gainii[i].id then
					hasSpawned = true
				end
			end

			if not hasSpawned then
				local hash = GetHashKey('a_c_chicken_01')
				while not HasModelLoaded(hash) do
					Wait(10)
					RequestModel(hash)
				end
				RequestModel(hash)
				local data = {}
				data.id = Config.Gainii[i].id
				data.obj = CreatePed(hash, Config.Gainii[i].x, Config.Gainii[i].y, Config.Gainii[i].z -1.0, 200, false, true, true, true)
				Citizen.InvokeNative(0x283978A15512B2FE, data.obj, true) -- SetRandomOutfitVariation
				SetEntityNoCollisionEntity(PlayerPedId(), data.obj, false)
				SetEntityCanBeDamaged(data.obj, false)
				SetEntityInvincible(data.obj, true)
				Wait(1000)
				FreezeEntityPosition(data.obj, true) -- NPC can't escape
				SetBlockingOfNonTemporaryEvents(data.obj, true) -- NPC can't be scared
				table.insert(SpawnedGainii, data)
				hasSpawned = false
			end
		end
    end
    if not InRange then
        Wait(5000)
    end
    end
end)

-- destroy plant
function DestroyGaini()
    local plant = GetClosestGaini()
    local hasDone = false

    for k, v in pairs(HarvestedGainii) do
        if v == plant.id then
            hasDone = true
        end
    end

    if not hasDone then
        table.insert(HarvestedGainii, plant.id)
        local ped = PlayerPedId()
        isDoingAction = true
        TriggerServerEvent('rus-animales_gaini:server:plantHasBeenHarvested', plant.id)
		TaskStartScenarioInPlace(ped, `WORLD_HUMAN_CROUCH_INSPECT`, 0, true)
		Wait(5000)
		ClearPedTasks(ped)
		SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
		TriggerServerEvent('rus-animales_gaini:server:destroyGaini', plant.id)
		isDoingAction = false
		canHarvest = true
    else
		QRCore.Functions.Notify('error', 'error')
    end
end

-- havest gaini
function HarvestGaini()
    local plant = GetClosestGaini()
    local hasDone = false

    for k, v in pairs(HarvestedGainii) do
        if v == plant.id then
            hasDone = true
        end
    end

    if not hasDone then
        table.insert(HarvestedGainii, plant.id)
        local ped = PlayerPedId()
        isDoingAction = true
        TriggerServerEvent('rus-animales_gaini:server:plantHasBeenHarvested', plant.id)
		TaskStartScenarioInPlace(ped, `WORLD_HUMAN_CROUCH_INSPECT`, 0, true)
		Wait(10000)
		ClearPedTasks(ped)
		SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
		--print("Culeg")
		TriggerServerEvent('rus-animales_gaini:server:harvestGaini', plant.id)
		isDoingAction = false
		canHarvest = true
    else
		QRCore.Functions.Notify('error', 'error')
    end
end

function RemoveGainiFromTable(plantId)
    for k, v in pairs(Config.Gainii) do
        if v.id == plantId then
            table.remove(Config.Gainii, k)
        end
    end
end

-- trigger actions
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		local InRange = false
		local ped = PlayerPedId()
		local pos = GetEntityCoords(ped)

		for k, v in pairs(Config.Gainii) do
			if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.x, v.y, v.z, true) < 1.3 and not isDoingAction and not v.beingHarvested and not IsPedInAnyVehicle(PlayerPedId(), false) then
				if PlayerJob.name == 'police' then
					local plant = GetClosestGaini()
					DrawText3D(v.x, v.y, v.z, 'Gaina: ' .. v.labelos)
					DrawText3D(v.x, v.y, v.z - 0.18, 'Apa: ' .. v.thirst .. '% - Mancare: ' .. v.hunger .. '%')
					DrawText3D(v.x, v.y, v.z - 0.36, 'Crestere: ' ..  v.growth .. '% -  Fericire: ' .. v.quality.. '%')
					DrawText3D(v.x, v.y, v.z - 0.54, 'Confisca Gaina [G]')
					if IsControlJustPressed(0, QRCore.Shared.Keybinds['G']) then
						if v.id == plant.id then
							DestroyGaini()
						end
					end
				else
					if v.growth < 100 then
						local plant = GetClosestGaini()
						DrawText3D(v.x, v.y, v.z, 'Gaina: ' .. v.labelos)
						DrawText3D(v.x, v.y, v.z - 0.18, 'Apa: ' .. v.thirst .. '% - Mancare: ' .. v.hunger .. '%')
						DrawText3D(v.x, v.y, v.z - 0.36, 'Crestere: ' ..  v.growth .. '% -  Fericire: ' .. v.quality.. '%')
						DrawText3D(v.x, v.y, v.z - 0.54, 'Dai Apa [G] : Dai de Mancare [J]')
						if IsControlJustPressed(0, QRCore.Shared.Keybinds['G']) then
							if v.id == plant.id then
								TriggerEvent('rus-animales_gaini:client:waterGaini')
							end
						elseif IsControlJustPressed(0, QRCore.Shared.Keybinds['J']) then
							if v.id == plant.id then
								TriggerEvent('rus-animales_gaini:client:feedGaini')
							end
						end
					else
						DrawText3D(v.x, v.y, v.z, 'Gaina: ' .. v.labelos)
						DrawText3D(v.x, v.y, v.z - 0.18, '[Fericire: ' .. v.quality .. ']')
						DrawText3D(v.x, v.y, v.z - 0.36, 'Colecteaza [E]')

						if IsControlJustReleased(0, QRCore.Shared.Keybinds['E']) and canHarvest then
							local plant = GetClosestGaini()
							local callpolice = math.random(1,100)
							if v.id == plant.id then
								HarvestGaini()
								if callpolice > 95 then
									local coords = GetEntityCoords(PlayerPedId())
									-- alert police action here
								end
							end
						end
					end
				end
			end
		end
    end
end)

function GetClosestGaini()
    local dist = 1000
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local plant = {}
    for i = 1, #Config.Gainii do
        local xd = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Gainii[i].x, Config.Gainii[i].y, Config.Gainii[i].z, true)
        if xd < dist then
            dist = xd
            plant = Config.Gainii[i]
        end
    end
    return plant
end

RegisterNetEvent('rus-animales_gaini:client:removeGainiObject')
AddEventHandler('rus-animales_gaini:client:removeGainiObject', function(plant)
    for i = 1, #SpawnedGainii do
        local o = SpawnedGainii[i]
        if o.id == plant then
			SetEntityAsMissionEntity(o.obj, false)
            FreezeEntityPosition(o.obj, false)
			SetEntityInvincible(o.obj, false)
			Wait(60000)
			if o.obj then
			DeleteEntity(o.obj)
			end
        end
    end
end)

-- water gaini
RegisterNetEvent('rus-animales_gaini:client:waterGaini')
AddEventHandler('rus-animales_gaini:client:waterGaini', function()
    local entity = nil
    local plant = GetClosestGaini()
    local ped = PlayerPedId()
    isDoingAction = true
    for k, v in pairs(SpawnedGainii) do
        if v.id == plant.id then
            entity = v.obj
        end
    end
	local hasItem = QRCore.Functions.HasItem('wateringcan', 1)
	if hasItem then
		Citizen.InvokeNative(0x5AD23D40115353AC, ped, entity, -1)
		TaskStartScenarioInPlace(ped, `WORLD_HUMAN_CROUCH_INSPECT`, 0, true)
		Wait(10000)
		ClearPedTasks(ped)
		SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
		TriggerServerEvent('rus-animales_gaini:server:waterGaini', plant.id)
		isDoingAction = false
	else
		QRCore.Functions.Notify('Nu ai Adus apa ce vrei sa ii dai sa bea?', 'error')
		Wait(5000)
		isDoingAction = false
	end
end)

-- feed gaini
RegisterNetEvent('rus-animales_gaini:client:feedGaini')
AddEventHandler('rus-animales_gaini:client:feedGaini', function()
    local entity = nil
    local plant = GetClosestGaini()
    local ped = PlayerPedId()
    isDoingAction = true
    for k, v in pairs(SpawnedGainii) do
        if v.id == plant.id then
            entity = v.obj
        end
    end
	local hasItem = QRCore.Functions.HasItem('corn', 1)
	if hasItem then
		Citizen.InvokeNative(0x5AD23D40115353AC, ped, entity, -1)
		TaskStartScenarioInPlace(ped, `WORLD_HUMAN_FEED_CHICKEN`, 0, true)
		Wait(14000)
		ClearPedTasks(ped)
		SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
		TriggerServerEvent('rus-animales_gaini:server:feedGaini', plant.id)
		isDoingAction = false
	else
		QRCore.Functions.Notify('Nu ai Porumb la tine !', 'error')
		Wait(5000)
		isDoingAction = false
	end
end)

RegisterNetEvent('rus-animales_gaini:client:updateGainiData')
AddEventHandler('rus-animales_gaini:client:updateGainiData', function(data)
    Config.Gainii = data
end)

RegisterNetEvent('rus-animales_gaini:client:plantNewSeed')
AddEventHandler('rus-animales_gaini:client:plantNewSeed', function(type, labelos)
    local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.5, 0.0)
	local ped = PlayerPedId()
    if CanGainiSeedHere(pos) and not IsPedInAnyVehicle(PlayerPedId(), false) then
		TaskStartScenarioInPlace(ped, `WORLD_HUMAN_CROUCH_INSPECT`, 0, true)
		Wait(10000)
		ClearPedTasks(ped)
		SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
		TaskStartScenarioInPlace(ped, `WORLD_HUMAN_CROUCH_INSPECT`, 0, true)
		Wait(20000)
		ClearPedTasks(ped)
		SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
		TriggerServerEvent('rus-animales_gaini:server:plantNewSeed', type, pos, labelos)
    else
		QRCore.Functions.Notify('Mult prea aproape de alt animal!', 'error')
		TriggerServerEvent('rus-animales_gaini:server:giveSeed')
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.25, 0.25)
    SetTextFontForCurrentCommand(9)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end

function CanGainiSeedHere(pos)
    local canGaini = true

    for i = 1, #Config.Gainii do
        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Gainii[i].x, Config.Gainii[i].y, Config.Gainii[i].z, true) < 1.3 then
            canGaini = false
        end
    end

    return canGaini
end

----------------------------------------------------------------------------------------------
