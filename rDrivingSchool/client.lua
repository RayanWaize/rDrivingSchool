local ESX = nil
local societyMoney = nil

if Config.newESX then
    ESX = exports["es_extended"]:getSharedObject()
else
    Citizen.CreateThread(function()
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        while ESX == nil do Citizen.Wait(100) end
        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end
        ESX.PlayerData = ESX.GetPlayerData()
    end)
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

local function rDrivingSchoolKeyboard(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

local function spawnuniCar(car)
    local carhash = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end
    local vehicle = CreateVehicle(carhash, Config.allPos.posGarageSpawn, true, false)
    local plaque = "autoecole"..math.random(1,9)
    SetVehicleNumberPlateText(vehicle, plaque)
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
end

local function UpdateSocietyMoney(money)
    societyMoney = ESX.Math.GroupDigits(money)
end

local function refreshMoney()
    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
        ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
            UpdateSocietyMoney(money)
        end, ESX.PlayerData.job.name)
    end
end

local function menuF6()
    local menuP = RageUI.CreateMenu("Auto-école", " ")
    local menuS = RageUI.CreateSubMenu(menuP, "Auto-école", " ")
    RageUI.Visible(menuP, not RageUI.Visible(menuP))

    while menuP do
        Citizen.Wait(0)
        RageUI.IsVisible(menuP, true, true, true, function()

            RageUI.Separator("Que voulez-vous faire ?")

            RageUI.ButtonWithStyle("Facture",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local player, distance = ESX.Game.GetClosestPlayer()
                    local amount = rDrivingSchoolKeyboard("Montant de la facture ?", "", 10)
                    if tonumber(amount) then
                        if player ~= -1 and distance <= 3.0 then
                            TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_autoecole', ('Auto-école'), tonumber(amount))
                            TriggerEvent('esx:showAdvancedNotification', 'Fl~g~ee~s~ca ~g~Bank', 'Facture envoyée : ', 'Vous avez envoyé une facture d\'un montant de : ~g~'..amount..'$', 'CHAR_BANK_FLEECA', 9)
                        else
                            ESX.ShowNotification("~r~Probleme~s~: Aucuns joueurs proche")
                        end
                    else
                        ESX.ShowNotification("~r~Probleme~s~: Montant invalide")
                    end
                end
            end)

            RageUI.Separator("~o~Annonces")

            RageUI.ButtonWithStyle("Ouverture",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("rDrivingSchool:sendAnnoncement", "open")
                end
            end)

            RageUI.ButtonWithStyle("Fermeture",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("rDrivingSchool:sendAnnoncement", "close")
                end
            end)

            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'autoecole' and ESX.PlayerData.job.grade_name == 'boss' then
                RageUI.Separator("~g~Attribution")

                RageUI.ButtonWithStyle("Code de la route",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestPlayer ~= -1 and closestDistance <= 3.0 then
                            TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(closestPlayer), 'dmv')
                            ESX.ShowNotification('~g~Vous avez attribué le code de la route avec succès.')
                        else
                            ESX.ShowNotification("~r~Probleme~s~: Aucuns joueurs proche")
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Permis voiture",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestPlayer ~= -1 and closestDistance <= 3.0 then
                            TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(closestPlayer), 'drive')
                            ESX.ShowNotification('~g~Vous avez attribué le permis avec succès.')
                        else
                            ESX.ShowNotification("~r~Probleme~s~: Aucuns joueurs proche")
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Permis moto",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestPlayer ~= -1 and closestDistance <= 3.0 then
                            TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(closestPlayer), 'drive_bike')
                            ESX.ShowNotification('~g~Vous avez attribué le permis avec succès.')
                        else
                            ESX.ShowNotification("~r~Probleme~s~: Aucuns joueurs proche")
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Permis camion",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestPlayer ~= -1 and closestDistance <= 3.0 then
                            TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(closestPlayer), 'drive_truck')
                            ESX.ShowNotification('~g~Vous avez attribué le permis avec succès.')
                        else
                            ESX.ShowNotification("~r~Probleme~s~: Aucuns joueurs proche")
                        end
                    end
                end)
            end

            if Config.modDev then
                if ESX.PlayerData.job and ESX.PlayerData.job.name == 'autoecole' and ESX.PlayerData.job.grade_name == 'boss' then
                    RageUI.Separator("~g~Attribution [Test-ModDev]")

                    RageUI.ButtonWithStyle("Code de la route",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(PlayerId()), 'dmv')
                            ESX.ShowNotification('~g~Vous avez attribué le code de la route avec succès.')
                        end
                    end)

                    RageUI.ButtonWithStyle("Permis voiture",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(PlayerId()), 'drive')
                            ESX.ShowNotification('~g~Vous avez attribué le permis avec succès.')
                        end
                    end)

                    RageUI.ButtonWithStyle("Permis moto",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(PlayerId()), 'drive_bike')
                            ESX.ShowNotification('~g~Vous avez attribué le permis avec succès.')
                        end
                    end)

                    RageUI.ButtonWithStyle("Permis camion",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(PlayerId()), 'drive_truck')
                            ESX.ShowNotification('~g~Vous avez attribué le permis avec succès.')
                        end
                    end)
                end
            end
        end)

        if not RageUI.Visible(menuP) and not RageUI.Visible(menuS) then
            menuP = RMenu:DeleteType("menuP", true)
        end
    end
end

Keys.Register('F6', "autoecole", 'Ouvrir le menu', function()
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'autoecole' then
        menuF6()
    end
end)


local function menuCoffre()
    local menuP = RageUI.CreateMenu("Coffre", "Auto-école")
        RageUI.Visible(menuP, not RageUI.Visible(menuP))
            while menuP do
            Citizen.Wait(0)
            RageUI.IsVisible(menuP, true, true, true, function()

                RageUI.Separator("~b~↓ Objet ↓")

                    RageUI.ButtonWithStyle("Retirer",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            RageUI.CloseAll()
                            menuCoffreRetirer()
                        end
                    end)
                    
                    RageUI.ButtonWithStyle("Déposer",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            RageUI.CloseAll()
                            menuCoffreDeposer()
                        end
                    end)
                end)
            if not RageUI.Visible(menuP) then
            menuP = RMenu:DeleteType("menuP", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos-Config.allPos.posCoffre)
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'autoecole' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, Config.allPos.posCoffre, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au coffre", time_display = 1 })
            if IsControlJustPressed(1,51) then
                menuCoffre()
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)

function menuCoffreRetirer()
    local menuCoffre = RageUI.CreateMenu("Coffre", "Auto-école")
    ESX.TriggerServerCallback('rDrivingSchool:getStockItems', function(items) 
    RageUI.Visible(menuCoffre, not RageUI.Visible(menuCoffre))
        while menuCoffre do
            Citizen.Wait(0)
                RageUI.IsVisible(menuCoffre, true, true, true, function()
                        for k,v in pairs(items) do 
                            if v.count > 0 then
                            RageUI.ButtonWithStyle(v.label, nil, {RightLabel = v.count}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    local count = rDrivingSchoolKeyboard("Combien ?", "", 2)
                                    TriggerServerEvent('rDrivingSchool:getStockItem', v.name, tonumber(count))
                                    RageUI.CloseAll()
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(menuCoffre) then
            menuCoffre = RMenu:DeleteType("Coffre", true)
        end
    end
     end)
end


function menuCoffreDeposer()
    local StockPlayer = RageUI.CreateMenu("Coffre", "Voici votre ~y~inventaire")
    ESX.TriggerServerCallback('rDrivingSchool:getPlayerInventory', function(inventory)
        RageUI.Visible(StockPlayer, not RageUI.Visible(StockPlayer))
    while StockPlayer do
        Citizen.Wait(0)
            RageUI.IsVisible(StockPlayer, true, true, true, function()
                for i=1, #inventory.items, 1 do
                    if inventory ~= nil then
                         local item = inventory.items[i]
                            if item.count > 0 then
                                    RageUI.ButtonWithStyle(item.label, nil, {RightLabel = item.count}, true, function(Hovered, Active, Selected)
                                            if Selected then
                                            local count = rDrivingSchoolKeyboard("Combien ?", '' , 8)
                                            TriggerServerEvent('rDrivingSchool:putStockItems', item.name, tonumber(count))
                                            RageUI.CloseAll()
                                        end
                                    end)
                                end
                            else
                                RageUI.Separator('Chargement en cours')
                            end
                        end
                    end, function()
                    end)
                if not RageUI.Visible(StockPlayer) then
                StockPlayer = RMenu:DeleteType("Coffre", true)
            end
        end
    end)
end


local function menuGarage()
    local menuGarageP = RageUI.CreateMenu("Garage", "Auto-école")
        RageUI.Visible(menuGarageP, not RageUI.Visible(menuGarageP))
            while menuGarageP do
            Citizen.Wait(0)
            RageUI.IsVisible(menuGarageP, true, true, true, function()
                RageUI.Separator("~u~↓ Véhicule disponible ↓")
                for k,v in pairs(Config.garageCar) do
                    RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "→→"},true, function(Hovered, Active, Selected)
                        if Selected then
                            spawnuniCar(v.model)
                            RageUI.CloseAll()
                        end
                    end)
                end
            end)
            if not RageUI.Visible(menuGarageP) then
            menuGarageP = RMenu:DeleteType("menuGarageP", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos-Config.allPos.posGarage)
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'autoecole' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, Config.allPos.posGarage, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au garage", time_display = 1 })
            if IsControlJustPressed(1,51) then
                menuGarage()
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local pos = vector3(Config.allPos.posGarageSpawn.x, Config.allPos.posGarageSpawn.y, Config.allPos.posGarageSpawn.z)
        local dist = #(plyPos-pos)
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'autoecole' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour ranger la voiture garage", time_display = 1 })
            if IsControlJustPressed(1,51) then
                local veh, dist4 = ESX.Game.GetClosestVehicle()
                if dist4 < 4 then
                    DeleteEntity(veh)
                end
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)

local function menuBoss()
    local menuBossP = RageUI.CreateMenu("Actions Patron", "Auto-école")
    RageUI.Visible(menuBossP, not RageUI.Visible(menuBossP))
    while menuBossP do
        Wait(0)
        RageUI.IsVisible(menuBossP, true, true, true, function()

            if societyMoney ~= nil then
                RageUI.Separator("~o~Argent société:~s~ ~g~"..societyMoney.."$")
            end

            RageUI.ButtonWithStyle("Retirer argent de société",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local amount = rDrivingSchoolKeyboard("Montant", "", 10)
                    amount = tonumber(amount)
                    if amount == nil then
                        RageUI.Popup({message = "Montant invalide"})
                    else
                        TriggerServerEvent('esx_society:withdrawMoney', 'autoecole', amount)
                        refreshMoney()
                    end
                end
            end)

            RageUI.ButtonWithStyle("Déposer argent de société",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local amount = rDrivingSchoolKeyboard("Montant", "", 10)
                    amount = tonumber(amount)
                    if amount == nil then
                        RageUI.Popup({message = "Montant invalide"})
                    else
                        TriggerServerEvent('esx_society:depositMoney', 'autoecole', amount)
                        refreshMoney()
                    end
                end
            end)

           RageUI.ButtonWithStyle("Accéder aux actions de Management",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerEvent('esx_society:openBossMenu', 'autoecole', function(data, menu)
                        menu.close()
                    end, {wash = false})
                    RageUI.CloseAll()
                end
            end)
        end)
        if not RageUI.Visible(menuBossP) then
            menuBossP = RMenu:DeleteType("menuBossP", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos-Config.allPos.posMenuBoss)
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'autoecole' and ESX.PlayerData.job.grade_name == 'boss' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, Config.allPos.posMenuBoss, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder aux actions patron", time_display = 1 })
            if IsControlJustPressed(1,51) then
                refreshMoney()
                menuBoss()
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)