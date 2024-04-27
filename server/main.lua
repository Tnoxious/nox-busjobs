-- main.lua by Tnoxious https://github.com/Tnoxious modified from qb-bus script https://github.com/qbcore-framework
-- Script changes are under GPLv3 License and not to be made for sale or locked in a paywall system you are free to make any changes for own server
local QBCore = exports['qb-core']:GetCoreObject()

--Check if near City Bus
function NearBus(src)
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    for _, v in pairs(CityLoc.NPCLocations.Locations) do
        local dist = #(coords - vector3(v.x,v.y,v.z))
        if dist < 20 then
            return true
        end
    end
end

--Check if near Dashhound
function NearDash(src)
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    for _, v in pairs(DashLoc.NPCLocations.Locations) do
        local dist = #(coords - vector3(v.x,v.y,v.z))
        if dist < 20 then
            return true
        end
    end
end

--NPC payments for City Bus
RegisterNetEvent('nox-buscityjob:server:NpcPay', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "bus" then
        if NearBus(src) then
            local CityPayment = Config.cpay 
            Player.Functions.AddMoney('bank', CityPayment)    ---or if want add " cash " to not use bank
			TriggerClientEvent('QBCore:Notify', src, Lang:t('success.server_npc_paid')..CityPayment , "primary")
        else
            DropPlayer(src, Lang:t('error.drop_message'))  --some anti Exploit stuff qb also used 
        end
    else
        DropPlayer(src, Lang:t('error.drop_message'))
    end
end)

--NPC payments for Dashhound
RegisterNetEvent('nox-busDashjob:server:NpcPay', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "bus" then
        if NearDash(src) then
            local DashPayment = Config.dpay 
            Player.Functions.AddMoney('bank', DashPayment)    ---or if want add " cash " to not use bank
			TriggerClientEvent('QBCore:Notify', src, Lang:t('success.server_npc_paid')..DashPayment , "primary")
        else
            DropPlayer(src, Lang:t('error.drop_message'))  --some anti Exploit stuff basic but handy
        end
    else
        DropPlayer(src, Lang:t('error.drop_message'))
    end
end)

--Bonus pay
RegisterNetEvent('nox-busjobcomplete:server:cPayBonus', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "bus" then
            local BonusPayment = Config.bonus 
            Player.Functions.AddMoney('bank', BonusPayment)    ---or if want add " cash " to not use bank
			TriggerClientEvent('QBCore:Notify', src, Lang:t('success.bonus_message')..BonusPayment , "success")
    else
        DropPlayer(src, Lang:t('error.drop_message'))
    end
end)

--Take cash off player for hire of City Bus
RegisterNetEvent("nox-busjobs:server:payDeposit", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Balancec = Player.PlayerData.money['bank']
	if Balancec >= Config.BusHirePrice then	
	Player.Functions.RemoveMoney('bank', Config.BusHirePrice, 'citybus-deposit')
	TriggerClientEvent('QBCore:Notify', src, Lang:t('success.you_have_paid')..Config.BusHirePrice , "success")
	TriggerClientEvent('nox-buscityjob:client:DoBusNpc', src)
	TriggerClientEvent('nox-busjob:client:BusStatusActive', src)	
	else 
	    TriggerClientEvent('QBCore:Notify', src, Lang:t('error.you_have_zofunds')..Config.BusHirePrice , "error")
		TriggerClientEvent('nox-buscityjob:client:StopJob', src)
	end

end)

--Take cash off player for hire of Dashhound
RegisterNetEvent("nox-busjobs:server:payDepositDash", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Balanced = Player.PlayerData.money['bank']
	if Balanced >= Config.BusHirePrice then	
	Player.Functions.RemoveMoney('bank', Config.BusHirePrice, 'dashhound-deposit')
	TriggerClientEvent('QBCore:Notify', src, Lang:t('success.you_have_paid')..Config.BusHirePrice , "success")
	TriggerClientEvent('nox-busDashjob:client:DoBusNpc', src)
	TriggerClientEvent('nox-busjob:client:DashStatusActive', src)	
	else 
	    TriggerClientEvent('QBCore:Notify', src, Lang:t('error.you_have_zofunds')..Config.BusHirePrice , "error")
		TriggerClientEvent('nox-busDashjob:client:StopJob', src)
	end

end)