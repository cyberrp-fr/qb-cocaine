fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author '0xIbra <ibragim.ai95@gmail.com>'
description 'QB-Cocaine'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
