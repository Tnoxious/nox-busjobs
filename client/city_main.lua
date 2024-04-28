-- city_main.lua by Tnoxious https://github.com/Tnoxious modified from qb-bus script https://github.com/qbcore-framework
-- Script changes are under GPLv3 License and not to be made for sale or locked in a paywall system you are free to make any changes for own server
local QBCore = exports['qb-core']:GetCoreObject()
PlayerJob = {}
local PlayerData = QBCore.Functions.GetPlayerData()
local route = 1
local max = #CityLoc.NPCLocations.Locations
local busBlip = nil
local JobBus  = nil
BusActive = false
StopsActive = false
local DebugZoneSett = Config.DebugZones

local NpcData = {
    Active = false,
    CurrentNpc = nil,
    LastNpc = nil,
    CurrentDeliver = nil,
    LastDeliver = nil,
    Npc = nil,
    NpcBlip = nil,
    DeliveryBlip = nil,
    NpcTaken = false,
    NpcDelivered = false,
    CountDown = 180
}

local CityBusData = {
    Active = false,
}

-- Functions

---- Work Clothing
--- Change in config code will check if player is a mp ped or not 
local function SetWorkBusClothing()
if Config.WorkClothing then
  local ped = PlayerPedId()
   local morf = GetEntityModel(ped)

if morf == `mp_m_freemode_01` then
--male ped clothing
SetPedComponentVariation(ped, 3, Config.cWorkArms, 0, 0)
SetPedComponentVariation(ped, 11, Config.cWorkTorso, 0, 0)
SetPedComponentVariation(ped, 9, Config.cWorkVest, 0, 0)
SetPedComponentVariation(ped, 8, Config.cWorkShirt, 0, 0)
SetPedComponentVariation(ped, 4, Config.cWorkPants, 0, 0)
SetPedComponentVariation(ped, 6, Config.cWorkBoots, 0, 0)
SetPedComponentVariation(ped, 10, Config.cWorkBadge, 0, 0)
SetPedPropIndex(ped, 0, Config.cWorkHat, 0, true)
end
if morf == `mp_f_freemode_01` then
--female ped clothing
SetPedComponentVariation(ped, 3, Config.cWorkArmsF, 0, 0)
SetPedComponentVariation(ped, 11, Config.cWorkTorsoF, 0, 0)
SetPedComponentVariation(ped, 9, Config.cWorkVestF, 0, 0)
SetPedComponentVariation(ped, 8, Config.cWorkShirtF, 0, 0)
SetPedComponentVariation(ped, 4, Config.cWorkPantsF, 0, 0)
SetPedComponentVariation(ped, 6, Config.cWorkBootsF, 0, 0)
SetPedComponentVariation(ped, 10, Config.cWorkBadgeF, 0, 0)
SetPedPropIndex(ped, 0, Config.cWorkHatF, 0, true)
   end
   end
end

--Resets to normal Clothing after job
local function ResetPedClothing()
if Config.WorkClothing then
--check if player is a custom ped then force reload
  local ped = PlayerPedId()
  local morf = GetEntityModel(ped)
if morf == `mp_m_freemode_01` or morf == `mp_f_freemode_01` then
    TriggerServerEvent("qb-clothes:loadPlayerSkin")
    TriggerServerEvent("qb-clothing:loadPlayerSkin")
	Citizen.Wait(100)
	  end
	  end
end

local function SpawnCityBusPed()
    local cfgped = Config.CityBusPed
    local setpedkey = GetHashKey(cfgped)
    local PedLoc = Config.CityBusPedLocation
    RequestModel(cfgped)
    while not HasModelLoaded(cfgped) do
        Wait(0)
    end
    local ped = CreatePed(3, setpedkey, PedLoc.x, PedLoc.y, PedLoc.z, PedLoc.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, Config.ScenarioBusPed, true, true)

    local zone =
        BoxZone:Create(
        PedLoc.xyz,
        2.5,
        2.5,
        {
            name = "zone_cityBus" .. ped,
            heading = PedLoc.w,
            debugPoly = DebugZoneSett,
            minZ = PedLoc.z - 3.0,
            maxZ = PedLoc.z + 2.0
        }
    )
    zone:onPlayerInOut(
        function(inside)
            if PlayerData.job.name == "bus" then
                if inside then
                    TriggerEvent("nox-menu:client:CityBusJobMenu")
                end
            else
                QBCore.Functions.Notify(Lang:t("error.you_notworker"), "error", 2000)
            end
        end
    )
end

local function resetNpcTask()
    NpcData = {
        Active = false,
        CurrentNpc = nil,
        LastNpc = nil,
        CurrentDeliver = nil,
        LastDeliver = nil,
        Npc = nil,
        NpcBlip = nil,
        DeliveryBlip = nil,
        NpcTaken = false,
        NpcDelivered = false
    }
end

local function updateBlip()
    if PlayerData.job.name == "bus" then
        busBlip = AddBlipForCoord(Config.CityBusLocation)
        SetBlipSprite(busBlip, 513)
        SetBlipDisplay(busBlip, 4)
        SetBlipScale(busBlip, 0.6)
        SetBlipAsShortRange(busBlip, true)
        SetBlipColour(busBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Lang:t("cinfo.bus_depot"))
        EndTextCommandSetBlipName(busBlip)
    elseif busBlip ~= nil then
        RemoveBlip(busBlip)
    end
end

local function whitelistedCityVehicle()
    local ped = PlayerPedId()
    local veh = GetEntityModel(GetVehiclePedIsIn(ped))
    local retval = false
    if veh == GetHashKey(Config.CityBusType) then
        retval = true
    end
    return retval
end

local function nextStop()
    if Config.RandomStops and max then
        route = math.random(1, max)
    else
        if route <= (max - 1) then
            route = route + 1
        else
            route = 1
        end
    end
end

local function GetDeliveryCityLocation()
    nextStop()
    DrawMarker(
        27,
        CityLoc.NPCLocations.Locations[route].x,
        CityLoc.NPCLocations.Locations[route].y,
        CityLoc.NPCLocations.Locations[route].z,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        4.0,
        4.0,
        4.0,
        4.0,
        174,
        219,
        242,
        222,
        false,
        false,
        false,
        true,
        false,
        false,
        false
    )
    if NpcData.DeliveryBlip ~= nil then
        RemoveBlip(NpcData.DeliveryBlip)
    end
    NpcData.DeliveryBlip =
        AddBlipForCoord(
        CityLoc.NPCLocations.Locations[route].x,
        CityLoc.NPCLocations.Locations[route].y,
        CityLoc.NPCLocations.Locations[route].z
    )
    SetBlipColour(NpcData.DeliveryBlip, 3)
    SetBlipRoute(NpcData.DeliveryBlip, true)
    SetBlipRouteColour(NpcData.DeliveryBlip, 3)
    NpcData.LastDeliver = route
    local inRange = false
    local PolyZone =
        CircleZone:Create(
        vector3(
            CityLoc.NPCLocations.Locations[route].x,
            CityLoc.NPCLocations.Locations[route].y,
            CityLoc.NPCLocations.Locations[route].z
        ),
        6,
        {
            name = "buscityjobdeliver",
            useZ = true,
            debugPoly = DebugZoneSett
        }
    )

    if not StopsActive then
        PolyZone:destroy()
        RemoveBlip(NpcData.DeliveryBlip)
    else
        PolyZone:onPlayerInOut(
            function(isPointInside)
                if isPointInside then
                    inRange = true
                    exports["qb-core"]:DrawText(Lang:t("info.busstop_text"), "rgb(220, 20, 60)")
                    CreateThread(
                        function()
                            repeat
                                Wait(0)
                                DrawMarker(
                                    1,
                                    CityLoc.NPCLocations.Locations[route].x,
                                    CityLoc.NPCLocations.Locations[route].y,
                                    CityLoc.NPCLocations.Locations[route].z,
                                    1.0,
                                    1.0,
                                    1.0,
                                    1.0,
                                    1.0,
                                    4.0,
                                    4.0,
                                    4.0,
                                    4.0,
                                    174,
                                    219,
                                    242,
                                    222,
                                    false,
                                    false,
                                    false,
                                    true,
                                    false,
                                    false,
                                    false
                                )
                                if IsControlJustPressed(0, 38) then
                                    local ped = PlayerPedId()
                                    local veh = GetVehiclePedIsIn(ped, 0)
                                    TaskLeaveVehicle(NpcData.Npc, veh, 0)
                                    SetEntityAsMissionEntity(NpcData.Npc, false, true)
                                    SetEntityAsNoLongerNeeded(NpcData.Npc)
                                    local targetCoords = CityLoc.NPCLocations.Locations[NpcData.LastNpc]
                                    TaskGoStraightToCoord(
                                        NpcData.Npc,
                                        targetCoords.x,
                                        targetCoords.y,
                                        targetCoords.z,
                                        1.0,
                                        -1,
                                        0.0,
                                        0.0
                                    )
                                    QBCore.Functions.Notify(Lang:t("success.dropped_off"), "success")
                                    if Config.NpcPaysAllStops then
                                        TriggerServerEvent("nox-buscityjob:server:NpcPay")
                                    end
                                    if NpcData.DeliveryBlip ~= nil then
                                        RemoveBlip(NpcData.DeliveryBlip)
                                    end

                                    local RemovePed = function(pped)
                                        SetTimeout(
                                            60000,
                                            function()
                                                DeletePed(pped)
                                            end
                                        )
                                    end
                                    RemovePed(NpcData.Npc)
                                    resetNpcTask()
                                    nextStop()
                                    TriggerEvent("nox-buscityjob:client:DoBusNpc")
                                    exports["qb-core"]:HideText()
                                    PolyZone:destroy()
                                    break
                                end
                            until not inRange
                        end
                    )
                else
                    exports["qb-core"]:HideText()
                    inRange = false
                end
            end
        )
    end
end

local function closeMenuFull()
    exports["qb-menu"]:closeMenu()
end

RegisterNetEvent(
    "nox-buscityjob:client:TakeVehicle",
    function(data)
        local coords = Config.CityBusLocation
        if (CityBusData.Active) then
            QBCore.Functions.Notify(Lang:t("error.one_bus_active"), "error")
            return
        else
            SetWorkBusClothing()
            Wait(100)
            QBCore.Functions.TriggerCallback(
                "QBCore:Server:SpawnVehicle",
                function(netId)
                    local veh = NetToVeh(netId)
                    SetVehicleNumberPlateText(veh, Lang:t("cinfo.bus_plate") .. tostring(math.random(100, 999)))
                    exports["LegacyFuel"]:SetFuel(veh, 100.0)
                    closeMenuFull()
                    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                    SetVehicleEngineOn(veh, true, true)
                end,
                data.model,
                coords,
                true
            )
            Wait(1000)
            TriggerServerEvent("nox-busjobs:server:payDeposit")
        end
    end
)

-- Events
RegisterNetEvent(
    "nox-busjob:client:BusStatusActive",
    function()
        BusActive = true
    end
)
AddEventHandler(
    "onResourceStart",
    function(resourceName)
        if GetCurrentResourceName() == resourceName then
            updateBlip()
            local player = QBCore.Functions.GetPlayerData()
            PlayerJob = player.job
        end
    end
)
RegisterNetEvent(
    "QBCore:Client:OnPlayerLoaded",
    function()
        PlayerData = QBCore.Functions.GetPlayerData()
        updateBlip()
    end
)
RegisterNetEvent(
    "QBCore:Client:OnPlayerUnload",
    function()
        PlayerData = {}
    end
)
RegisterNetEvent(
    "QBCore:Client:OnJobUpdate",
    function(JobInfo)
        PlayerData.job = JobInfo
        updateBlip()
    end
)
RegisterNetEvent(
    "nox-buscityjob:client:DoBusNpc",
    function()
        if whitelistedCityVehicle() then
            StopsActive = true
            if not NpcData.Active then
                local Gender = math.random(1, #Config.NpcSkins)
                local PedSkin = math.random(1, #Config.NpcSkins[Gender])
                local model = GetHashKey(Config.NpcSkins[Gender][PedSkin])

                RequestModel(model)
                while not HasModelLoaded(model) do
                    Wait(0)
                end

                NpcData.Npc =
                    CreatePed(
                    3,
                    model,
                    CityLoc.NPCLocations.Locations[route].x,
                    CityLoc.NPCLocations.Locations[route].y,
                    CityLoc.NPCLocations.Locations[route].z - 0.98,
                    CityLoc.NPCLocations.Locations[route].w,
                    false,
                    true
                )
                PlaceObjectOnGroundProperly(NpcData.Npc)
                FreezeEntityPosition(NpcData.Npc, true)
                if NpcData.NpcBlip ~= nil then
                    RemoveBlip(NpcData.NpcBlip)
                end

                QBCore.Functions.Notify(Lang:t("info.goto_busstop"), "primary")
                NpcData.NpcBlip =
                    AddBlipForCoord(
                    CityLoc.NPCLocations.Locations[route].x,
                    CityLoc.NPCLocations.Locations[route].y,
                    CityLoc.NPCLocations.Locations[route].z
                )
                SetBlipColour(NpcData.NpcBlip, 3)
                SetBlipRoute(NpcData.NpcBlip, true)
                SetBlipRouteColour(NpcData.NpcBlip, 3)
                NpcData.LastNpc = route
                NpcData.Active = true
                local inRange = false
                local PolyZone =
                    CircleZone:Create(
                    vector3(
                        CityLoc.NPCLocations.Locations[route].x,
                        CityLoc.NPCLocations.Locations[route].y,
                        CityLoc.NPCLocations.Locations[route].z
                    ),
                    5,
                    {
                        name = "buscityjobdeliver",
                        useZ = true,
                        debugPoly = DebugZoneSett
                    }
                )
                PolyZone:onPlayerInOut(
                    function(isPointInside)
                        if isPointInside then
                            inRange = true
                            DrawMarker(
                                1,
                                CityLoc.NPCLocations.Locations[route].x,
                                CityLoc.NPCLocations.Locations[route].y,
                                CityLoc.NPCLocations.Locations[route].z,
                                1.0,
                                1.0,
                                1.0,
                                1.0,
                                1.0,
                                4.0,
                                4.0,
                                4.0,
                                4.0,
                                174,
                                219,
                                242,
                                222,
                                false,
                                false,
                                false,
                                true,
                                false,
                                false,
                                false
                            )
                            exports["qb-core"]:DrawText(Lang:t("info.busstop_text"), "rgb(220, 20, 60)")
                            CreateThread(
                                function()
                                    repeat
                                        Wait(5)
                                        if IsControlJustPressed(0, 38) then
                                            local ped = PlayerPedId()
                                            local veh = GetVehiclePedIsIn(ped, 0)
                                            local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(veh)
                                            for i = maxSeats - 1, 0, -1 do
                                                if IsVehicleSeatFree(veh, i) then
                                                    freeSeat = i
                                                    break
                                                end
                                            end
                                            ClearPedTasksImmediately(NpcData.Npc)
                                            FreezeEntityPosition(NpcData.Npc, false)
                                            TaskEnterVehicle(NpcData.Npc, veh, -1, freeSeat, 1.0, 0)

                                            QBCore.Functions.Notify(Lang:t("info.drive_passanger"), "primary")

                                            if NpcData.NpcBlip ~= nil then
                                                RemoveBlip(NpcData.NpcBlip)
                                            end
                                            GetDeliveryCityLocation()
                                            NpcData.NpcTaken = true
                                            TriggerServerEvent("nox-buscityjob:server:NpcPay")
                                            exports["qb-core"]:HideText()
                                            PolyZone:destroy()
                                            break
                                        end
                                    until not inRange
                                end
                            )
                        else
                            exports["qb-core"]:HideText()
                            inRange = false
                        end
                    end
                )
            else
                QBCore.Functions.Notify(Lang:t("error.already_driving_bus"), "error")
            end
        else
            QBCore.Functions.Notify(Lang:t("error.not_in_bus"), "error")
            ExecuteCommand("BusKillJobNow")
        end
    end
)

-- Threads
CreateThread(
    function()
        SpawnCityBusPed()
        local inRange = false
        local PolyZone =
            CircleZone:Create(
            vector3(Config.CityBusLocation.x, Config.CityBusLocation.y, Config.CityBusLocation.z),
            5,
            {
                name = "busMain",
                useZ = true,
                debugPoly = DebugZoneSett
            }
        )
        PolyZone:onPlayerInOut(
            function(isPointInside)
                local inVeh = whitelistedCityVehicle()
                if PlayerData.job.name == "bus" then
                    if isPointInside then
                        inRange = true
                        CreateThread(
                            function()
                                repeat
                                    Wait(5)
                                    if not inVeh then
                                        if IsControlJustReleased(0, 38) then
                                            exports["qb-core"]:HideText()
                                            break
                                        end
                                    else
                                        if BusActive then
                                            DrawMarker(
                                                22,
                                                Config.CityBusLocation.x,
                                                Config.CityBusLocation.y,
                                                Config.CityBusLocation.z,
                                                1.0,
                                                1.0,
                                                1.0,
                                                1.0,
                                                1.0,
                                                4.0,
                                                4.0,
                                                4.0,
                                                4.0,
                                                174,
                                                219,
                                                242,
                                                222,
                                                false,
                                                false,
                                                false,
                                                true,
                                                false,
                                                false,
                                                false
                                            )
                                            exports["qb-core"]:DrawText(Lang:t("info.bus_stop_work"), "left")
                                            if IsControlJustReleased(0, 38) then
                                                if (not NpcData.Active or NpcData.Active and NpcData.NpcTaken == false) then
                                                    if IsPedInAnyVehicle(PlayerPedId(), false) then
                                                        local PlayerJobCar = GetVehiclePedIsIn(PlayerPedId())
                                                        if BusActive then
                                                            TriggerServerEvent("nox-busjobcomplete:server:cPayBonus")
                                                        end
                                                        Wait(100)
                                                        CityBusData.Active = false
                                                        BusActive = false
                                                        StopsActive = false
                                                        QBCore.Functions.Notify(
                                                            Lang:t("success.bus_youparked"),
                                                            "success",
                                                            5000
                                                        )
                                                        DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                                        RemoveBlip(NpcData.NpcBlip)
                                                        RemoveBlip(NpcData.DeliveryBlip)
                                                        exports["qb-core"]:HideText()
                                                        GetDeliveryCityLocation()
                                                        resetNpcTask()
                                                        ClearAreaOfPeds(
                                                            CityLoc.NPCLocations.Locations[route].x,
                                                            CityLoc.NPCLocations.Locations[route].y,
                                                            CityLoc.NPCLocations.Locations[route].z,
                                                            4,
                                                            true
                                                        )
                                                        NpcData.Active = false
                                                        Wait(5)
                                                        ResetPedClothing()
                                                        break
                                                    end
                                                else
                                                    QBCore.Functions.Notify(
                                                        Lang:t("error.drop_off_passengers"),
                                                        "error"
                                                    )
                                                end
                                            end
                                        end
                                    end
                                until not inRange
                            end
                        )
                    else
                        exports["qb-core"]:HideText()
                        inRange = false
                    end
                end
            end
        )
    end
)

RegisterCommand(
    "buscityjobMenu",
    function()
        exports["qb-menu"]:openMenu(
            {
                {
                    header = Lang:t("menu.bus_header"),
                    icon = "fa fa-institution",
                    isMenuHeader = true
                },
                {
                    header = Lang:t("menu.bus_button"),
                    txt = Lang:t("menu.bus_buttoninfo"),
                    icon = "fas fa-bus",
                    params = {
                        event = "nox-menu:client:GetJobCityBus",
                        args = {
                            model = Config.CityBusType
                        }
                    }
                },
                {
                    header = Lang:t("menu.bus_button_exit"),
                    txt = "",
                    icon = "fa fa-close",
                    params = {
                        event = "",
                        args = {
                            closeMenuFull()
                        }
                    }
                }
            }
        )
    end
)

RegisterCommand(
    "BusKillJobNow",
    function()
        RemoveBlip(NpcData.DeliveryBlip)
        CityBusData.Active = false
        BusActive = false
        exports["qb-core"]:HideText()
        DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
        RemoveBlip(NpcData.NpcBlip)
        resetNpcTask()
        ClearAreaOfPeds(
            CityLoc.NPCLocations.Locations[route].x,
            CityLoc.NPCLocations.Locations[route].y,
            CityLoc.NPCLocations.Locations[route].z,
            4,
            true
        )
        StopsActive = false
        GetDeliveryCityLocation()
        Wait(5)
        ResetPedClothing()

        QBCore.Functions.Notify(Lang:t("error.killed_job"), "error", 5000)
        Wait(1000)
        if Config.TelePlayer then
            local entity = GetPlayerPed(-1)
            SetEntityCoords(entity, Config.TelePlayerTo.x, Config.TelePlayerTo.y, Config.TelePlayerTo.z, 0, 0, 0, false)
            SetEntityHeading(entity, Config.TelePlayerTo.h)
            PlaceObjectOnGroundProperly(entity)
            Citizen.Wait(1500)
            DoScreenFadeIn(200)
        end
    end
)

RegisterNetEvent(
    "nox-buscityjob:client:StopJob",
    function()
        RemoveBlip(NpcData.DeliveryBlip)
        CityBusData.Active = false
        BusActive = false
        exports["qb-core"]:HideText()
        DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
        RemoveBlip(NpcData.NpcBlip)
        resetNpcTask()
        ClearAreaOfPeds(
            CityLoc.NPCLocations.Locations[route].x,
            CityLoc.NPCLocations.Locations[route].y,
            CityLoc.NPCLocations.Locations[route].z,
            4,
            true
        )
        StopsActive = false
        GetDeliveryCityLocation()
        Wait(5)
        ResetPedClothing()
    end
)

RegisterNetEvent(
    "nox-menu:client:CityBusJobMenu",
    function(data)
        if DashBusActive then
            QBCore.Functions.Notify(Lang:t("error.two_jobs_alert"), "error", 2000)
        else
            if not BusActive then
                ExecuteCommand("buscityjobMenu")
            else
                QBCore.Functions.Notify(Lang:t("error.you_haveactive_job"), "error", 2000)
            end
        end
    end
)

RegisterNetEvent(
    "nox-menu:client:GetJobCityBus",
    function(data)
        local citycoord = Config.CityBusLocation
        local ParkZoneCity = IsPositionOccupied(citycoord.x, citycoord.y, citycoord.z, 5, 0, 23 or 127 or 2175 or 67711)
        if ParkZoneCity then
            QBCore.Functions.Notify(Lang:t("error.parking_blocked"), "error")
        else
            if BusActive then
                QBCore.Functions.Notify(Lang:t("error.you_haveactive_job"), "error", 3000)
            else
                if PlayerData.job.name == "bus" then
                    local PlayerData = QBCore.Functions.GetPlayerData()
                    if BusActive then
                        QBCore.Functions.Notify(Lang:t("error.one_bus_active"), "error")
                    else
                        model = data.model
                        TriggerEvent("nox-buscityjob:client:TakeVehicle", data)
                        BusActive = true
                        CityBusData.Active = true
                    end
                else
                    QBCore.Functions.Notify(Lang:t("error.you_notworker"), "error", 2000)
                end
            end
        end
    end
)
