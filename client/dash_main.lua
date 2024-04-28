-- dash_main.lua by Tnoxious https://github.com/Tnoxious modified from qb-bus script https://github.com/qbcore-framework
-- Script changes are under GPLv3 License and not to be made for sale or locked in a paywall system you are free to make any changes for own server
local QBCore = exports['qb-core']:GetCoreObject()
PlayerJob = {}
local PlayerData = QBCore.Functions.GetPlayerData()
local route = 1
local max = #DashLoc.NPCLocations.Locations
local DashBlip = nil
local JobBus  = nil
DashBusActive = false
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

local DashBusData = {
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
SetPedComponentVariation(ped, 3, Config.dWorkArms, 0, 0)
SetPedComponentVariation(ped, 11, Config.dWorkTorso, 0, 0)
SetPedComponentVariation(ped, 9, Config.dWorkVest, 0, 0)
SetPedComponentVariation(ped, 8, Config.dWorkShirt, 0, 0)
SetPedComponentVariation(ped, 4, Config.dWorkPants, 0, 0)
SetPedComponentVariation(ped, 6, Config.dWorkBoots, 0, 0)
SetPedComponentVariation(ped, 10, Config.dWorkBadge, 0, 0)
SetPedPropIndex(ped, 0, Config.dWorkHat, 0, true)
end
if morf == `mp_f_freemode_01` then
--female ped clothing
SetPedComponentVariation(ped, 3, Config.dWorkArmsF, 0, 0)
SetPedComponentVariation(ped, 11, Config.dWorkTorsoF, 0, 0)
SetPedComponentVariation(ped, 9, Config.dWorkVestF, 0, 0)
SetPedComponentVariation(ped, 8, Config.dWorkShirtF, 0, 0)
SetPedComponentVariation(ped, 4, Config.dWorkPantsF, 0, 0)
SetPedComponentVariation(ped, 6, Config.dWorkBootsF, 0, 0)
SetPedComponentVariation(ped, 10, Config.dWorkBadgeF, 0, 0)
SetPedPropIndex(ped, 0, Config.dWorkHatF, 0, true)
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

local function SpawnDashBusPed()
    local cfgped = Config.DashBusPed
    local setpedkey = GetHashKey(cfgped)
    local PedLoc = Config.DashBusPedLocation
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
    TaskStartScenarioInPlace(ped, Config.ScenariosDashPed, true, true)

    local zone =
        BoxZone:Create(
        PedLoc.xyz,
        2.5,
        2.5,
        {
            name = "zone_DashBus" .. ped,
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
                    TriggerEvent("nox-menu:client:DashBusJobMenu")
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
        DashBlip = AddBlipForCoord(Config.DashBusLocation)
        SetBlipSprite(DashBlip, 513)
        SetBlipDisplay(DashBlip, 4)
        SetBlipScale(DashBlip, 0.6)
        SetBlipAsShortRange(DashBlip, true)
        SetBlipColour(DashBlip, 7)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Lang:t("dinfo.bus_depot"))
        EndTextCommandSetBlipName(DashBlip)
    elseif DashBlip ~= nil then
        RemoveBlip(DashBlip)
    end
end

local function whitelistedDashVehicle()
    local ped = PlayerPedId()
    local veh = GetEntityModel(GetVehiclePedIsIn(ped))
    local retval = false
    if veh == GetHashKey(Config.DashBusType) then
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

local function GetDeliveryDashLocation()
    nextStop()
    DrawMarker(
        27,
        DashLoc.NPCLocations.Locations[route].x,
        DashLoc.NPCLocations.Locations[route].y,
        DashLoc.NPCLocations.Locations[route].z,
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
        DashLoc.NPCLocations.Locations[route].x,
        DashLoc.NPCLocations.Locations[route].y,
        DashLoc.NPCLocations.Locations[route].z
    )
    SetBlipColour(NpcData.DeliveryBlip, 3)
    SetBlipRoute(NpcData.DeliveryBlip, true)
    SetBlipRouteColour(NpcData.DeliveryBlip, 3)
    NpcData.LastDeliver = route
    local inRange = false
    local PolyZone =
        CircleZone:Create(
        vector3(
            DashLoc.NPCLocations.Locations[route].x,
            DashLoc.NPCLocations.Locations[route].y,
            DashLoc.NPCLocations.Locations[route].z
        ),
        6,
        {
            name = "busDashjobdeliver",
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
                                    DashLoc.NPCLocations.Locations[route].x,
                                    DashLoc.NPCLocations.Locations[route].y,
                                    DashLoc.NPCLocations.Locations[route].z,
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
                                    local targetCoords = DashLoc.NPCLocations.Locations[NpcData.LastNpc]
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
                                        TriggerServerEvent("nox-busDashjob:server:NpcPay")
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
                                    TriggerEvent("nox-busDashjob:client:DoBusNpc")
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
    "nox-busDashjob:client:TakeVehicle",
    function(data)
        local coordss = Config.DashBusLocation
        if (DashBusData.Active) then
            QBCore.Functions.Notify(Lang:t("error.one_bus_active"), "error")
            return
        else
            SetWorkBusClothing()
            Wait(100)
            QBCore.Functions.TriggerCallback(
                "QBCore:Server:SpawnVehicle",
                function(netId)
                    local veh = NetToVeh(netId)
                    SetVehicleNumberPlateText(veh, Lang:t("dinfo.bus_plate") .. tostring(math.random(100, 999)))
                    exports["LegacyFuel"]:SetFuel(veh, 100.0)
                    closeMenuFull()
                    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                    SetVehicleEngineOn(veh, true, true)
                end,
                data.model,
                coordss,
                true
            )
            Wait(1000)
            TriggerServerEvent("nox-busjobs:server:payDepositDash")
        end
    end
)

-- Events
RegisterNetEvent(
    "nox-busjob:client:DashStatusActive",
    function()
        DashBusActive = true
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
    "nox-busDashjob:client:DoBusNpc",
    function()
        if whitelistedDashVehicle() then
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
                    DashLoc.NPCLocations.Locations[route].x,
                    DashLoc.NPCLocations.Locations[route].y,
                    DashLoc.NPCLocations.Locations[route].z - 0.98,
                    DashLoc.NPCLocations.Locations[route].w,
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
                    DashLoc.NPCLocations.Locations[route].x,
                    DashLoc.NPCLocations.Locations[route].y,
                    DashLoc.NPCLocations.Locations[route].z
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
                        DashLoc.NPCLocations.Locations[route].x,
                        DashLoc.NPCLocations.Locations[route].y,
                        DashLoc.NPCLocations.Locations[route].z
                    ),
                    5,
                    {
                        name = "busDashjobdeliver",
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
                                DashLoc.NPCLocations.Locations[route].x,
                                DashLoc.NPCLocations.Locations[route].y,
                                DashLoc.NPCLocations.Locations[route].z,
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
                                            GetDeliveryDashLocation()
                                            NpcData.NpcTaken = true
                                            TriggerServerEvent("nox-busDashjob:server:NpcPay")
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
            ExecuteCommand("BusKillDashJobNow")
        end
    end
)

-- Threads
CreateThread(
    function()
        SpawnDashBusPed()
        local inRange = false
        local PolyZone =
            CircleZone:Create(
            vector3(Config.DashBusLocation.x, Config.DashBusLocation.y, Config.DashBusLocation.z),
            5,
            {
                name = "DashMain",
                useZ = true,
                debugPoly = DebugZoneSett
            }
        )
        PolyZone:onPlayerInOut(
            function(isPointInside)
                local inVeh = whitelistedDashVehicle()
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
                                        if DashBusActive then
                                            DrawMarker(
                                                22,
                                                Config.DashBusLocation.x,
                                                Config.DashBusLocation.y,
                                                Config.DashBusLocation.z,
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
                                                        if DashBusActive then
                                                            TriggerServerEvent("nox-busjobcomplete:server:cPayBonus")
                                                        end
                                                        Wait(100)
                                                        DashBusData.Active = false
                                                        DashBusActive = false
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
                                                        GetDeliveryDashLocation()
                                                        resetNpcTask()
                                                        ClearAreaOfPeds(
                                                            DashLoc.NPCLocations.Locations[route].x,
                                                            DashLoc.NPCLocations.Locations[route].y,
                                                            DashLoc.NPCLocations.Locations[route].z,
                                                            4,
                                                            true
                                                        )
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
    "busDashjobMenu",
    function()
        exports["qb-menu"]:openMenu(
            {
                {
                    header = Lang:t("menu.dash_header"),
                    icon = "fa fa-institution",
                    isMenuHeader = true
                },
                {
                    header = Lang:t("menu.dash_button"),
                    txt = Lang:t("menu.dash_buttoninfo"),
                    icon = "fas fa-bus",
                    params = {
                        event = "nox-menu:client:GetJobDashBus",
                        args = {
                            model = Config.DashBusType
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
    "BusKillDashJobNow",
    function()
        RemoveBlip(NpcData.DeliveryBlip)
        DashBusData.Active = false
        DashBusActive = false
        exports["qb-core"]:HideText()
        DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
        RemoveBlip(NpcData.NpcBlip)
        resetNpcTask()
        ClearAreaOfPeds(
            DashLoc.NPCLocations.Locations[route].x,
            DashLoc.NPCLocations.Locations[route].y,
            DashLoc.NPCLocations.Locations[route].z,
            4,
            true
        )
        StopsActive = false
        GetDeliveryDashLocation()
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
    "nox-busDashjob:client:StopJob",
    function()
        RemoveBlip(NpcData.DeliveryBlip)
        DashBusData.Active = false
        DashBusActive = false
        exports["qb-core"]:HideText()
        DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
        RemoveBlip(NpcData.NpcBlip)
        resetNpcTask()
        ClearAreaOfPeds(
            DashLoc.NPCLocations.Locations[route].x,
            DashLoc.NPCLocations.Locations[route].y,
            DashLoc.NPCLocations.Locations[route].z,
            4,
            true
        )
        StopsActive = false
        GetDeliveryDashLocation()
        Wait(5)
        ResetPedClothing()
    end
)

RegisterNetEvent(
    "nox-menu:client:DashBusJobMenu",
    function(data)
        if BusActive then
            QBCore.Functions.Notify(Lang:t("error.two_jobs_alert"), "error", 2000)
        else
            if not DashBusActive then
                ExecuteCommand("busDashjobMenu")
            else
                QBCore.Functions.Notify(Lang:t("error.you_haveactive_job"), "error", 2000)
            end
        end
    end
)

RegisterNetEvent(
    "nox-menu:client:GetJobDashBus",
    function(data)
        local dashcoord = Config.DashBusLocation
        local ParkZonedash = IsPositionOccupied(dashcoord.x, dashcoord.y, dashcoord.z, 5, 0, 23 or 127 or 2175 or 67711)
        if ParkZonedash then
            QBCore.Functions.Notify(Lang:t("error.parking_blocked"), "error")
        else
            if DashBusActive then
                QBCore.Functions.Notify(Lang:t("error.you_haveactive_job"), "error", 3000)
            else
                if PlayerData.job.name == "bus" then
                    local PlayerData = QBCore.Functions.GetPlayerData()
                    if DashBusActive then
                        QBCore.Functions.Notify(Lang:t("error.one_bus_active"), "error")
                    else
                        model = data.model
                        TriggerEvent("nox-busDashjob:client:TakeVehicle", data)
                        DashBusActive = true
                        DashBusData.Active = true
                    end
                else
                    QBCore.Functions.Notify(Lang:t("error.you_notworker"), "error", 2000)
                end
            end
        end
    end
)
