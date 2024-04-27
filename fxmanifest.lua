fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Tnoxious'
description 'A Remake of the qb-busjob. This script will add two bus jobs to QB server with Worker Clothing system and worker peds. Has a City Bus job and Dashound job that goes around the map towns paying players as they drop off npc\'s - Script also adds more bus stops to map and job area props.'
version '1.2.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
	'locales/*.lua',
    'config/*.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/*.lua'
}

server_script 'server/*.lua'


