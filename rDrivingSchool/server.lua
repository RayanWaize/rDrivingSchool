local ESX = nil

if Config.newESX then
    ESX = exports["es_extended"]:getSharedObject()
else
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

TriggerEvent('esx_society:registerSociety', 'autoecole', 'autoecole', 'society_autoecole', 'society_autoecole', 'society_autoecole', {type = 'private'})



RegisterServerEvent('rDrivingSchool:sendAnnoncement')
AddEventHandler('rDrivingSchool:sendAnnoncement', function(state)
    local _src = source
    local xPlayers	= ESX.GetPlayers()
    if state == "open" then
        for i=1, #xPlayers, 1 do
            TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Auto-école', '~g~Annonce', 'L\'auto-école est désormais ouvert', 'CHAR_BLANK_ENTRY', 8)
        end
    elseif state == "close" then
        for i=1, #xPlayers, 1 do
            TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Auto-école', '~r~Annonce', 'L\'auto-école est désormais fermé', 'CHAR_BLANK_ENTRY', 8)
        end
    else
        TriggerClientEvent('esx:showAdvancedNotification', _src, 'Auto-école', '~r~Erreur', 'L\'annonce que vous essayez de faire ne marche pas.', 'CHAR_BLANK_ENTRY', 8)
    end
end)

ESX.RegisterServerCallback('rDrivingSchool:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_autoecole', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterNetEvent('rDrivingSchool:getStockItem')
AddEventHandler('rDrivingSchool:getStockItem', function(itemName, count)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_autoecole', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then

			-- can the player carry the said amount of x item?
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', 'Vous avez retiré ~r~'..inventoryItem.label.." x"..count, 'CHAR_MP_FM_CONTACT', 8)
		else
			TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', "Quantité ~r~invalide", 'CHAR_MP_FM_CONTACT', 9)
		end
	end)
end)

ESX.RegisterServerCallback('rDrivingSchool:getPlayerInventory', function(source, cb)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local items   = xPlayer.inventory

	cb({items = items})
end)

RegisterNetEvent('rDrivingSchool:putStockItems')
AddEventHandler('rDrivingSchool:putStockItems', function(itemName, count)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_autoecole', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', 'Vous avez déposé ~g~'..inventoryItem.label.." x"..count, 'CHAR_MP_FM_CONTACT', 8)
		else
			TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', "Quantité ~r~invalide", 'CHAR_MP_FM_CONTACT', 9)
		end
	end)
end)


ESX.RegisterServerCallback('rPermisPoint:getAllLicenses', function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(target)
        local allLicenses = {}
        MySQL.Async.fetchAll('SELECT * FROM user_licenses WHERE owner = @owner', {['owner'] = xPlayer.identifier}, function(result)
            for k,v in pairs(result) do
                table.insert(allLicenses, {
                    Name = xPlayer.getName(),
                    Type = v.type,
                    Point = v.point,
                    Owner = v.owner
                })
            end
            cb(allLicenses)
        end)
    end)


ESX.RegisterServerCallback('rPermisPoint:getLicenses', function(source, cb)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
    local mylicense = {}
    MySQL.Async.fetchAll('SELECT * FROM user_licenses WHERE owner = @owner', {
        ['@owner'] = xPlayer.identifier
    }, function(result)
        for k,v in pairs(result) do
                table.insert(mylicense, {
                    Name = xPlayer.getName(),
                    Type = v.type,
                    Point = v.point,
                    Owner = v.owner
                })
        end
        cb(mylicense)
    end)
end)


RegisterServerEvent('rPermisPoint:addPoint')
AddEventHandler('rPermisPoint:addPoint', function(permis, qty, owner)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.Async.fetchAll('SELECT * FROM user_licenses WHERE type = @type AND owner = @owner', {['type'] = permis, ['owner'] = owner}, function(result)

    if result[1].point + qty < 13 then

    MySQL.Async.fetchAll("UPDATE user_licenses SET point = @point WHERE owner = @owner AND type = @type",
    {
      ['point'] = result[1].point + qty,
      ['owner'] = owner,
      ['type'] = permis
    },
    function(result)
        TriggerClientEvent('esx:showNotification', _src, "Vous avez ajouté "..qty.." point(s) à ~y~"..ESX.GetPlayerFromIdentifier(owner).getName())
    end)
else
    TriggerClientEvent('esx:showNotification', _src, "Vous pouvez pas mettre plus que 12 point ~r~!")
end
end)
end)


RegisterServerEvent('rPermisPoint:removePoint')
AddEventHandler('rPermisPoint:removePoint', function(permis, qty, owner)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.Async.fetchAll('SELECT * FROM user_licenses WHERE type = @type AND owner = @owner', {['type'] = permis, ['owner'] = owner}, function(result)

    if result[1].point - qty > -1 then

    MySQL.Async.fetchAll("UPDATE user_licenses SET point = @point WHERE owner = @owner AND type = @type",
    {
      ['point'] = result[1].point - qty,
      ['owner'] = owner,
      ['type'] = permis
    },
    function(R)
        TriggerClientEvent('esx:showNotification', _src, "Vous avez retier "..qty.." point(s) à ~y~"..ESX.GetPlayerFromIdentifier(owner).getName())
        if result[1].point - qty == 0 then
            MySQL.Async.execute('DELETE FROM user_licenses WHERE owner = @owner AND type = @type', {['type'] = permis, ['owner'] = owner})
            TriggerClientEvent('esx:showNotification', _src, "La licence de "..ESX.GetPlayerFromIdentifier(owner).getName().." a été retiré car il avait 0 point")
        end
    end)
else
    TriggerClientEvent('esx:showNotification', _src, "Vous pouvez pas mettre moins que 0 point ~r~!")
end
end)
end)



ESX.RegisterServerCallback('rPermisPoint:getAllLicensesForPlayer', function(source, cb)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local allLicensesForMe = {}
    MySQL.Async.fetchAll('SELECT * FROM user_licenses WHERE owner = @owner', {['owner'] = xPlayer.identifier}, function(result)
        for k,v in pairs(result) do
            if v.type ~= "dmv" then
                table.insert(allLicensesForMe, {
                    Type = v.type,
                    Point = v.point
                })
            end
        end
        cb(allLicensesForMe)
    end)
end)