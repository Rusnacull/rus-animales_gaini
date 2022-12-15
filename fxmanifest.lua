fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

author 'Rusnacull#3856'
description 'rus-animales_gaini'

client_scripts {
    'client/client.lua',
	'client/trader.lua',
	'client/npc.lua',
}

server_scripts {
    'server/server.lua',
	'@oxmysql/lib/MySQL.lua',
}

shared_scripts { 
	'config.lua',
}
