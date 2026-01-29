fx_version 'cerulean'
game 'gta5'

author 'X1Studios'
description 'Simple Duty System with Multiple Departments, Blips & Discord Logging, using OX_Lib For The Menu'
author 'You'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_script 'client.lua'
server_script 'server.lua'
