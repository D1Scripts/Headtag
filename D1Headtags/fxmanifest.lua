fx_version 'cerulean'
game 'gta5'

author 'Lamaa'
description 'HeadTag system'
version '1.0.0'

dependencies {
    'mysql-async'
}

-- Client-side scripts
client_scripts {
    'client.lua',  -- Client-side script to handle head tags and commands
}

-- Server-side scripts
server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'db.lua',      -- Database operations (load first)
    'server.lua'   -- Server-side script to handle setting and updating tags (load second)
}

server_exports {
    'SavePlayerTags',
    'LoadPlayerTags'
}