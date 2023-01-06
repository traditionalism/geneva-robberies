fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'geneva-robberies'
author 'geneva/traditionalism'
description '(partially) Authentic GTA5 convenience store robberies for FiveM.'
repository 'https://github.com/traditionalism/geneva-robberies'

dependency 'ox_lib'

shared_script '@ox_lib/init.lua'

server_scripts {
    'server.lua',
    'bridge/**/server.lua'
}

client_scripts {
    'config.lua',
    'client.lua'
}