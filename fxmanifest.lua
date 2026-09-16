fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'fr_hud'
author 'Mirage (merged)'
description 'Modern modular HUD for FiveM — player / car / minimap / pulse (single resource)'
version '2.2.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua'
}

server_scripts { 'server/update.lua' }

client_scripts {
    'client/main.lua',
    'client/needs.lua',
    'client/player.lua',
    'client/car.lua',
    'client/minimap.lua',
    'client/pulse.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/scale.js',
    'audiodirectory/seatbelt_sounds.awc',
    'data/seatbelt_sounds.dat54.rel'
}

data_file 'AUDIO_WAVEPACK' 'audiodirectory'
data_file 'AUDIO_SOUNDDATA' 'data/seatbelt_sounds.dat'
