-- en.lua by Tnoxious https://github.com/Tnoxious
-- Translations added by: Tnoxious
local Translations = {
    error = {
        already_driving_bus = 'You are already driving a bus!',
        not_in_bus = 'YOU ARE NOT IN JOB VEHICLE!',
        one_bus_active = 'You can only drive one bus at a time!',
        drop_off_passengers = 'Please drop off your passengers before you stop working',
		you_notworker = 'You don\'t work for me go away..',
		parking_blocked = 'Spawn Area is Blocked! Clear The Area!',
		you_haveactive_job = 'You have Active job with us.. I Can\'t Give you a new bus today..',
		killed_job = 'NOTICE: Server killed the job.. Player Actions was Trigger..',
		two_jobs_alert = 'You are working for other Bus company come back after that job..',
		drop_message = 'Server Kicked for: Attempting To Exploit',
		you_have_zofunds = 'You dont have the money for a Bus you need $',		
    },
    success = {
        dropped_off = 'Passanger was dropped off',
		bus_youparked = 'You have parked the Bus!',
		server_npc_paid = 'Passenger Paid you $',
		bonus_message = 'You got a Bonus! For a Job well done! $',
		you_have_paid = 'You paid for Bus Hire $',
    },
    info = {
        goto_busstop = 'Travel to the next bus stop to pick up a Passenger',
        drive_passanger = 'Take Passanger to the next stop.',
        busstop_text = '[E] - Bus Stop',
        bus_stop_work = '[E] - Stop Working',
        bus_job_vehicles = '[E] - Job Vehicles',
		
    },
    cinfo = {
        bus_plate = 'CITY-', -- Can be 3 or 4 characters long (uses random 4 digits)
        bus_depot = 'CityBus Depot',

    },
    dinfo = {
        bus_plate = 'DASH-', -- Can be 3 or 4 characters long (uses random 4 digits)
        bus_depot = 'Dashhound Depot',

    },	
    menu = {
        bus_header = 'City Bus Job',
		bus_button = 'Get Bus from Garage',
		bus_button_exit = 'Close',		
		bus_buttoninfo = 'You get only one fully serviced Bus for your job today look after it!',

        dash_header = 'Dashhound Job',
		dash_button = 'Get Dashhound from Garage',
		dash_buttoninfo = 'You get only one fully serviced Dashhound for your job today look after it!',
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})