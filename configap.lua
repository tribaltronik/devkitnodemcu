
print('Config AP')
dofile("rgbled.lua")
-- put module in AP mode
wifi.setmode(wifi.SOFTAP)
-- Now you should see an SSID wireless router named ESP_STATION when you scan for available WIFI networks
-- Lets connect to the module from a computer of mobile device. So, find the SSID and connect using the password selected
wifi.ap.config(cfg)
print(wifi.ap.getip())
ap_mac = wifi.ap.getmac()

-- create a server on port 80 and wait for a connection, when a connection is coming in function c will be executed
sv=net.createServer(net.TCP,30)
sv:listen(80,function(c)
    c:on("receive", function(c, pl)
        -- print the payload pl received from the connection
        print(pl)
        print(string.len(pl))
        -- wait until SSID comes back and parse the SSID and the password
        
        print(string.match(pl,"GET"))
        ssid_start,ssid_end=string.find(pl,"SSID=")
        
        if ssid_start and ssid_end then
            amper1_start, amper1_end =string.find(pl,"&", ssid_end+1)
        
            if amper1_start and amper1_end then
                http_start, http_end =string.find(pl,"HTTP/1.1", ssid_end+1)
                
                if http_start and http_end then
                    ssid=string.sub(pl,ssid_end+1, amper1_start-1)
                    
                    password=string.sub(pl,amper1_end+10, http_start-2)
                    
                    print("ESP8266 connecting to SSID: " .. ssid .. " with PASSWORD: " .. password)
                    
                    if ssid and password then
                        sv:close()
                        
                        -- close the server and set the module to STATION mode
                        wifi.setmode(wifi.STATION)
                        
                        print("ESP8266 mode now is: " .. wifi.getmode())
                        --write wifi config on memory
                        writewificonfig()
                        -- configure the module wso it can connect to the network using the received SSID and password
                        wifi.sta.config(ssid,password)
                        writewificonfig()
                        print("Setting up ESP8266 for station mode? Please wait")
                        
                        tmr.delay(10000000)
                        
                        --print("ESP8266 STATION IP now is: " .. wifi.sta.getip())
                        --print("ESP8266 AP IP now is: " .. wifi.ap.getip())
                        new_ip =wifi.sta.getip()
                        rgb_solid(1) --green
                        dofile('mqtt.lua')
                        -- now the module is configured and connected to the network so lets start setting things up for the control logic
                        sv=net.createServer(net.TCP, 30) 
                        sv:listen(80,function(c)
                            c:on("receive", function(c, pl)
          
                                print("ESP8266 STATION IP now is: " .. new_ip)
                                c:send("ESP8266 STATION IP now is: " .. new_ip) 
                                c:send("Action completed") 
                            end)
                        end)
                    end
                end
            end
        end
        topicid = node.chipid()
        -- this is the web page that requests the SSID and password from the user
        c:send("<html>")
        c:send("<body>")
        c:send("<h1>NODEMCU Dev Kit ControlBoard Setup</h1> ")
        mac_mess1 = "The module MAC address is: " .. ap_mac
        mac_mess2 = "You will need this MAC address to find the IP address of the module, please take note of it."
        c:send("<h2>Topic ID: " .. topicid.."mcu</h2> ")
        c:send("<h2>Topics MQTT:</h2> ")
        c:send("<h2>"..topicid.."mcu/temp</h2> ")
        c:send("<h2>"..topicid.."mcu/hum</h2> ")
        c:send("<h2>"..topicid.."mcu/gas</h2> ")
        c:send("<h2>"..topicid.."mcu/move</h2> ")
        c:send("<h2>" .. mac_mess1 .. "</h2> ")
        c:send("<h2>" .. mac_mess2 .. "</h2> ")
        c:send("<h2>Enter SSID and Password for your WIFI router</h2> ")
         c:send("<form action='' method=’get’>")
        c:send("SSID:")
        c:send("<input type='text' name='SSID' value='' maxlength='100' />")
        c:send("<br />")
        c:send("Password:")
        c:send("<input type='text' name='Password' value='' maxlength='100' />")
        c:send("<input type='submit' value='Submit' />")
        c:send("</form> </body></html>")
      
    end)
end)

