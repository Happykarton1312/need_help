ESX 						   = nil
local CopsConnected       	   = 0
local PlayersHarvestingKoda    = {}
local PlayersTransformingKoda  = {}
local PlayersSellingKoda       = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function CountCops()
	local xPlayers = ESX.GetPlayers()

	CopsConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			CopsConnected = CopsConnected + 1
		end
	end

	SetTimeout(120 * 1000, CountCops)
end

CountCops()

--Sammler
local function HarvestKoda(source)

	SetTimeout(Config.TimeToFarm, function()
		if PlayersHarvestingKoda[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local koda = xPlayer.getInventoryItem('steine')

			if koda.limit ~= -1 and koda.count >= koda.limit then
				TriggerClientEvent('esx:showNotification', source, _U('taschen_voll'))
			else
				xPlayer.addInventoryItem('steine', 1)
				HarvestKoda(source)
			end
		end
	end)
end

RegisterServerEvent('esx_steine:startHarvestKoda')
AddEventHandler('esx_steine:startHarvestKoda', function()
	local _source = source

	if not PlayersHarvestingKoda[_source] then
		PlayersHarvestingKoda[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('objekt_pflücken'))
		HarvestKoda(_source)
	else
		print(('esx_steine: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_steine:stopHarvestKoda')
AddEventHandler('esx_steine:stopHarvestKoda', function()
	local _source = source

	PlayersHarvestingKoda[_source] = false
end)

local function TransformKoda(source)

	SetTimeout(Config.TimeToProcess, function()
		if PlayersTransformingKoda[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local kodaQuantity = xPlayer.getInventoryItem('steine').count
			local pooch = xPlayer.getInventoryItem('kieselsteine')

			if pooch.limit ~= -1 and pooch.count >= pooch.limit then
				TriggerClientEvent('esx:showNotification', source, _U('nicht_genug_objekt'))
			elseif kodaQuantity < 5 then
				TriggerClientEvent('esx:showNotification', source, _U('keine_objekt_mehr'))
			else
				xPlayer.removeInventoryItem('steine', 2)
				xPlayer.addInventoryItem('kieselsteine', 1)

				TransformKoda(source)
			end
		end
	end)
end

RegisterServerEvent('esx_steine:startTransformKoda')
AddEventHandler('esx_steine:startTransformKoda', function()
	local _source = source

	if not PlayersTransformingKoda[_source] then
		PlayersTransformingKoda[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('objekt_wird_verarbeitet'))
		TransformKoda(_source)
	else
		print(('esx_steine: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_steine:stopTransformKoda')
AddEventHandler('esx_steine:stopTransformKoda', function()
	local _source = source

	PlayersTransformingKoda[_source] = false
end)

local function SellKoda(source)

	SetTimeout(Config.TimeToSell, function()
		if PlayersSellingKoda[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local poochQuantity = xPlayer.getInventoryItem('kieselsteine').count

			if poochQuantity == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('kein_objekt_mehr_zum_verkaufen'))
			else
				xPlayer.removeInventoryItem('kieselsteine', 1)
				if CopsConnected == 0 then
					xPlayer.addAccountMoney('bank', 120)
					TriggerClientEvent('esx:showNotification', source, _U('verkaufe_objekt'))
				elseif CopsConnected == 1 then
					xPlayer.addAccountMoney('bank', 120)
					TriggerClientEvent('esx:showNotification', source, _U('verkaufe_objekt'))
				elseif CopsConnected == 2 then
					xPlayer.addAccountMoney('bank', 120)
					TriggerClientEvent('esx:showNotification', source, _U('verkaufe_objekt'))
				elseif CopsConnected == 3 then
					xPlayer.addAccountMoney('bank', 120)
					TriggerClientEvent('esx:showNotification', source, _U('verkaufe_objekt'))
				elseif CopsConnected == 4 then
					xPlayer.addAccountMoney('bank', 170)
					TriggerClientEvent('esx:showNotification', source, _U('verkaufe_objekt'))
				elseif CopsConnected >= 5 then
					xPlayer.addAccountMoney('bank', 170)
					TriggerClientEvent('esx:showNotification', source, _U('verkaufe_objekt'))
				end

				SellKoda(source)
			end
		end
	end)
end

RegisterServerEvent('esx_steine:startSellKoda')
AddEventHandler('esx_steine:startSellKoda', function()
	local _source = source

	if not PlayersSellingKoda[_source] then
		PlayersSellingKoda[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('verkaufen_von_objekt'))
		SellKoda(_source)
	else
		print(('esx_steine: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_steine:stopSellKoda')
AddEventHandler('esx_steine:stopSellKoda', function()
	local _source = source

	PlayersSellingKoda[_source] = false
end)

RegisterServerEvent('esx_steine:GetUserInventory')
AddEventHandler('esx_steine:GetUserInventory', function(currentZone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	TriggerClientEvent('esx_steine:ReturnInventory',
		_source,
		xPlayer.getInventoryItem('steine').count,
		xPlayer.getInventoryItem('kieselsteine').count,
		xPlayer.job.name,
		currentZone
	)
end)

ESX.RegisterUsableItem('steine', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem('steine', 1)

	TriggerClientEvent('esx_steine:onPot', _source)
	TriggerClientEvent('esx:showNotification', _source, _U('used_one_koda'))
end)
