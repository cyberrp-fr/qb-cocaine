fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'QB-Cocaine'
version '1.0.0'
author '0xIbra'

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
