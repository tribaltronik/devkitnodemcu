-- file : config.lua
local module = {}
-- Load wifi credencials
dofile('wificonfig.lua')

module.HOST = "mqtt.controlboard.net"  
module.PORT = 1883  
module.ID = node.chipid().."mcu"
module.user = node.chipid().."mcu"
module.pass = secretkey 
return module  
