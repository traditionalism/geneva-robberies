fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'geneva-robberies'
author 'geneva/traditionalism'
description '(partially) Authentic GTA5 convenience store robberies for FiveM.'

shared_script '@ox_lib/init.lua'

escrow_ignore {
    'config.lua',
    'bridge/**/server.lua'
}

server_scripts {
    'server.lua',
    'bridge/**/server.lua'
}

client_scripts {
    'config.lua',
    'client.lua'
}