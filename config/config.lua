Config = Config or {}
-- config.lua by Tnoxious https://github.com/Tnoxious modified from qb-bus script https://github.com/qbcore-framework
-- Script changes are under GPLv3 License and not to be made for sale or locked in a paywall system you are free to make any changes for own server

--This Config runs two Jobs City and Dashhound change what you need..
Config.DebugZones = false  --Shows Trigger zones for bus areas when running test change " false " when live

---------- Main Settings - Script is preset with normal settings 

Config.BusHirePrice = 1000  --Cost of bus Hire covers Both Bus types I advise be above BONUS price below.
Config.WorkClothing = false  -- When set " true " script will auto apply Clothing to player " false " will disable this part of script
Config.NpcPaysAllStops = false  --When set " true " npc will pay random amount for pickup and drop off else pays only on pickup
Config.RandomStops = false  --Random Stop Location picks from stops in _locations config keeps player busy all day long if they want it's fully random even counts stops you add/remove

--City Bus Payment per stop (pays will be different for each client session with random in place)
Config.cpay = math.random(60, 110) --using random will pay out anywhere from 50 to 100 per pickup with this setting

--Dashhound payments per stop 
Config.dpay = math.random(80, 180) --higher payment due to longer run

--BONUS Payment
Config.bonus = math.random(300, 600) --Pay the player this as BONUS when brings bus back to parking

------- END MAIN ----------

--Clothing system added won't save to player when applied it's temp Clothing effect
-- Get clothing codes from servers clothing menu to make changes what's here was random picked to test with, also note custom player peds are checked in client code.
----WORKER CLOTHING FOR CITY BUS
--Male
Config.cWorkHat = 23        -- for none set to -1
Config.cWorkBadge = 0
Config.cWorkBoots = 28
Config.cWorkPants = 29
Config.cWorkShirt = 6
Config.cWorkVest = 0      
Config.cWorkTorso = 40    --This is jacket
Config.cWorkArms = 11
--Female
Config.cWorkHatF = 34 
Config.cWorkBadgeF = 0
Config.cWorkBootsF = 77
Config.cWorkPantsF = 18
Config.cWorkShirtF = 25
Config.cWorkVestF = 0
Config.cWorkTorsoF = 20
Config.cWorkArmsF = 5
-------------------

----WORKER CLOTHING FOR Dashhound
--Male
Config.dWorkHat = 23 
Config.dWorkBadge = 0
Config.dWorkBoots = 28
Config.dWorkPants = 29
Config.dWorkShirt = 6
Config.dWorkVest = 0
Config.dWorkTorso = 40
Config.dWorkArms = 11
--Female Below
Config.dWorkHatF = 34 
Config.dWorkBadgeF = 0
Config.dWorkBootsF = 77
Config.dWorkPantsF = 18
Config.dWorkShirtF = 25
Config.dWorkVestF = 0
Config.dWorkTorsoF = 20
Config.dWorkArmsF = 5
-------------------


--These are Vehicles been used by scipt
Config.CityBusType = "bus"
Config.DashBusType = "coach"

--Bus Job Peds also add these to whitelist on server! 
Config.CityBusPed = "a_m_m_tourist_01" --City Bus Ped for another choice see https://docs.fivem.net/docs/game-references/ped-models/
Config.ScenarioBusPed = "WORLD_HUMAN_AA_SMOKE" --Sets the Ped in a Scenario of choice see https://wiki.rage.mp/index.php?title=Scenarios

Config.DashBusPed = "a_m_y_business_02" --Dashhound Ped
Config.ScenariosDashPed = "WORLD_HUMAN_AA_COFFEE" --Sets the Ped in a Scenario of choice see https://wiki.rage.mp/index.php?title=Scenarios

--Job Peds Yes working custom peds XOXO Tnoxious
Config.CityBusPedLocation = vector4(445.56, -594.92, 27.5, 350.88)  --Where City Bus Job Ped will spawn
Config.DashBusPedLocation = vector4(479.12, -580.47, 27.5, 87.73)  --Where Dashhound Job Ped will spawn

--Bus Blips/Spawns
Config.CityBusLocation = vector4(445.59, -588.06, 28.51, 269.4) --spawn and park City Bus area also is the Blip area on Map
Config.DashBusLocation = vector4(473.52, -589.67, 28.5, 172.63) --spawn and park Dashhound Bus area is the Blip area on Map

--AntiGlitch/Bug Fun
Config.TelePlayer = true  -- Just for a giggle if we catch player trying to use a car for jobs we send them to a set area like far away island disable if want
Config.TelePlayerTo = vector4(3669.48, 5644.97, 12.43, 329.79) -- This is island up north

--Preset Peds for Bus stops leave as is for stable running
Config.NpcSkins = {
    [1] = {
        'a_f_m_skidrow_01',
        'a_f_m_soucentmc_01',
        'a_f_m_soucent_01',
        'a_f_m_soucent_02',
        'a_f_m_tourist_01',
        'a_f_m_trampbeac_01',
        'a_f_m_tramp_01',
        'a_f_o_genstreet_01',
        'a_f_o_indian_01',
        'a_f_o_ktown_01',
        'a_f_o_salton_01',
        'a_f_o_soucent_01',
        'a_f_o_soucent_02',
        'a_f_y_beach_01',
        'a_f_y_bevhills_01',
        'a_f_y_bevhills_02',
        'a_f_y_bevhills_03',
        'a_f_y_bevhills_04',
        'a_f_y_business_01',
        'a_f_y_business_02',
        'a_f_y_business_03',
        'a_f_y_business_04',
        'a_f_y_eastsa_01',
        'a_f_y_eastsa_02',
        'a_f_y_eastsa_03',
        'a_f_y_epsilon_01',
        'a_f_y_fitness_01',
        'a_f_y_fitness_02',
        'a_f_y_genhot_01',
        'a_f_y_golfer_01',
        'a_f_y_hiker_01',
        'a_f_y_hipster_01',
        'a_f_y_hipster_02',
        'a_f_y_hipster_03',
        'a_f_y_hipster_04',
        'a_f_y_indian_01',
        'a_f_y_juggalo_01',
        'a_f_y_runner_01',
        'a_f_y_rurmeth_01',
        'a_f_y_scdressy_01',
        'a_f_y_skater_01',
        'a_f_y_soucent_01',
        'a_f_y_soucent_02',
        'a_f_y_soucent_03',
        'a_f_y_tennis_01',
        'a_f_y_tourist_01',
        'a_f_y_tourist_02',
        'a_f_y_vinewood_01',
        'a_f_y_vinewood_02',
        'a_f_y_vinewood_03',
        'a_f_y_vinewood_04',
        'a_f_y_yoga_01',
        'g_f_y_ballas_01',
    },
    [2] = {
        'ig_barry',
        'ig_bestmen',
        'ig_beverly',
        'ig_car3guy1',
        'ig_car3guy2',
        'ig_casey',
        'ig_chef',
        'ig_chengsr',
        'ig_chrisformage',
        'ig_clay',
        'ig_claypain',
        'ig_cletus',
        'ig_dale',
        'ig_dreyfuss',
        'ig_fbisuit_01',
        'ig_floyd',
        'ig_groom',
        'ig_hao',
        'ig_hunter',
        'csb_prolsec',
        'ig_joeminuteman',
        'ig_josef',
        'ig_josh',
        'ig_lamardavis',
        'ig_lazlow',
        'ig_lestercrest',
        'ig_lifeinvad_01',
        'ig_lifeinvad_02',
        'ig_manuel',
        'ig_milton',
        'ig_mrk',
        'ig_nervousron',
        'ig_nigel',
        'ig_old_man1a',
        'ig_old_man2',
        'ig_oneil',
        'ig_orleans',
        'ig_ortega',
        'ig_paper',
        'ig_priest',
        'ig_prolsec_02',
        'ig_ramp_gang',
        'ig_ramp_hic',
        'ig_ramp_hipster',
        'ig_ramp_mex',
        'ig_roccopelosi',
        'ig_russiandrunk',
        'ig_siemonyetarian',
        'ig_solomon',
        'ig_stevehains',
        'ig_stretch',
        'ig_talina',
        'ig_taocheng',
        'ig_taostranslator',
        'ig_tenniscoach',
        'ig_terry',
        'ig_tomepsilon',
        'ig_tylerdix',
        'ig_wade',
        'ig_zimbor',
        's_m_m_paramedic_01',
        'a_m_m_afriamer_01',
        'a_m_m_beach_01',
        'a_m_m_beach_02',
        'a_m_m_bevhills_01',
        'a_m_m_bevhills_02',
        'a_m_m_business_01',
        'a_m_m_eastsa_01',
        'a_m_m_eastsa_02',
        'a_m_m_farmer_01',
        'a_m_m_fatlatin_01',
        'a_m_m_genfat_01',
        'a_m_m_genfat_02',
        'a_m_m_golfer_01',
        'a_m_m_hasjew_01',
        'a_m_m_hillbilly_01',
        'a_m_m_hillbilly_02',
        'a_m_m_indian_01',
        'a_m_m_ktown_01',
        'a_m_m_malibu_01',
        'a_m_m_mexcntry_01',
        'a_m_m_mexlabor_01',
        'a_m_m_og_boss_01',
        'a_m_m_paparazzi_01',
        'a_m_m_polynesian_01',
        'a_m_m_prolhost_01',
        'a_m_m_rurmeth_01',
    }
}