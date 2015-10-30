
print("WIFI control")
timeout    = 20000000 -- 20s

dofile("rgbled.lua")
rgb_solid(0) --red

function writewificonfig()
    file.remove("config.lua")
    file.open("config.lua", "a+")
    file.writeline('ssid= \"'..ssid..'\"')
    file.writeline('password= \"'..password..'\"')
    file.close()
end

dofile('config.lua')

wifi.setmode(wifi.STATION)
print("ESP8266 mode is: " .. wifi.getmode())
cfg={}
-- Set the SSID of the module in AP mode and access password
cfg.ssid="controlboardkit"
cfg.pwd="12345678"
cfg.auth=0


if ssid and password then
    local time = tmr.now()
    print("ESP8266 SSID is: " .. ssid .. " and PASSWORD is: " .. password)
    --Station mode
    
     --init.lua
     wifi.setmode(wifi.STATION)
     wifi.sta.config(ssid,password)
     wifi.sta.connect()
     tmr.alarm(1, 1000, 1, function()
        if wifi.sta.status() == 5 then 
               tmr.stop(1)
                  print("Station: connected! IP: " .. wifi.sta.getip())
                 rgb_solid(1)   -- Turn LED white to indicate success
                 -- dofile(MAIN)
                 print('Start app')
                 dofile ("mqtt.lua")
         else
                     if tmr.now() - time > timeout then
                        tmr.stop(1)
                        print("Timeout!")

                       rgb_solid(2) --blue
                       dofile ("configap.lua")
                  end
         end 
     end)

end


