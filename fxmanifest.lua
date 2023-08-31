fx_version "cerulean"

description "Basic React (TypeScript) & Lua Game Scripts Boilerplate"
author "Bostra"
version '1.0.0'
repository 'https://github.com/b0stra'

lua54 'yes'

games {
  "gta5",
  "rdr3"
}

ui_page 'web/build/index.html'

client_scripts { "client/**/*",
"@ox_lib/init.lua"
}
server_scrips {
  "server/**/*",
  "@ox_lib/init.lua"
}

files {
	'web/build/index.html',
	'web/build/**/*',
}