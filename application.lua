-- file : application.lua
local module = {}  
m = nil
config = require("config")
-- DHT sensor
dhtpin = 4 --  data pin, GPIO2

-- move sensor pin
movepin = 5
movement = 0
gpio.mode(movepin,gpio.INT)

-- DHT22 sensor logic
function get_dht22() 
    DHT= require("dht22_min")
    DHT.read(dhtpin)
    temperature = DHT.getTemperature()
    humidity = DHT.getHumidity()
 
    if humidity == nil then
        print("Error reading from DHT22")
    else
        print("Temperature: "..(temperature / 10).."."..(temperature % 10).." deg C")
        print("Humidity: "..(humidity / 10).."."..(humidity % 10).."%")
        m:publish(config.ID .. "/temp",'{"value":"' ..(temperature / 10).."."..(temperature % 10)..'"}',0,0)
        m:publish(config.ID .. "/hum",'{"value":"' ..(humidity / 10).."."..(humidity % 10)..'"}',0,0)
    end
    DHT = nil
    package.loaded["dht22_min"]=nil  
end

function readGAS()
    gas = adc.read(0)
    print("sent GAS: ",gas)
    m:publish(config.ID .."/gas",'{"value":"' ..gas..'"}',0,1)
end

function changemovement(level)
    print("Move detected: "..level)
    movement = 1
end

function verifymovement()
    if movement == 1 then
        print("sent move detection")
        m:publish(config.ID .."/move",'{"value":"1"}',0,1)
        movement = 0
    else
        m:publish(config.ID .."/move",'{"value":"0"}',0,1)
    end
end

-- Sends a simple ping to the broker
local function send_ping()  
    if wifi.sta.status() == 5 then 
        m:publish(config.ID .. "/ping","id=" .. config.ID,0,0)
        get_dht22() 
        readGAS()
        verifymovement()
     else
        m:close()
        mqtt_start()
     end   
end

-- Sends my id to the broker for registration
local function register_myself()  
    m:subscribe(config.ID.."/status",0,function(conn)
        print("Subscribed to: "..config.ID.."/status")
    end)
    m:subscribe(config.ID.."/topics",0,function(conn)
        print("Subscribed to: : "..config.ID.."/topics")
    end)
end

local function mqtt_start()  
    print("start mqtt")
    print("ID:"..config.ID)
    print("User:"..config.user.." Pass:"..config.pass)
    m = mqtt.Client(config.ID, 120,config.user, config.pass)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
        print(topic .. ": " .. data)
        if topic == config.ID.."/status" then
            if data == "alive" then
                m:publish(config.ID .. "/status",'{"id":"' .. config.ID..'","ip":"' .. wifi.sta.getip()..'"}',0,0)
            end    
        end
        if topic == config.ID.."/topics" then
            if data == "topics" then
                print("Send topics");
                m:publish(config.ID .. "/topics",'{"topics": [{"topic":"temp","description":"Temperature"},{"topic":"hum","description":"Humidity"},{"topic":"move","description":"Movement"},{"topic":"gas","description":"Air Quality"},{"topic":"status","description":"Status of NodeMCU(IP...)"}]}',0,0)
            end      
        end
        -- do something, we have received a message
      end
    end)
    -- Connect to broker
    m:connect(config.HOST, config.PORT, 0, 1, function(con) 
        print("Connected to broker")
        rgb.color("green") -- Green
        register_myself()
        -- And then pings each 1000 milliseconds
        tmr.stop(6)
        send_ping() 
        tmr.alarm(6, 60000, 1, send_ping)
        -- interrupt for pin where movement sensor is connected
        gpio.trig(movepin, "up",changemovement)
    end) 

end

function module.start()  
  mqtt_start()
end

return module  
