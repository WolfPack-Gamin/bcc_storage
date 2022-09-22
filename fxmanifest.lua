fx_version "adamant"

games {"rdr3"}

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

server_scripts {
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua',
	'client/main.js'
}


files {
  'ui/dist/css/app.css',
  'ui/dist/favicon.ico',
  'ui/dist/fonts/AncientAd.ttf',
  'ui/dist/fonts/Cherolina.ttf',
  'ui/dist/fonts/rdrlino-regular-webfont.woff',
  'ui/dist/fonts/WWI.ttf',
  'ui/dist/img/bg.png',
  'ui/dist/img/cta-bg.png',
  'ui/dist/index.html',
  'ui/dist/js/app.js',
  'ui/dist/js/app.js.map',
  'ui/dist/js/chunk-vendors.js',
  'ui/dist/js/chunk-vendors.js.map'
}
  
ui_page 'ui/dist/index.html'

exports {
	'DataViewNativeGetEventData',
}

dependency 'vorp_core'