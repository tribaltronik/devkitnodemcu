-- MQTT init
clientID = node.chipid().."mcu"
mqttserver = "societytools.dynip.sapo.pt"


-- move sensor pin
movepin = 5
dhtpin = 4 --  data pin, GPIO2
gpio.mode(movepin,gpio.INT)

print("ClientID: " .. clientID);
m = mqtt.Client(wifi.sta.getmac(), 120, "user", "password")
m:lwt("/lwt", wifi.sta.getmac(), 0, 0)

-- on publish message receive event
m:on("message", function(conn, topic, data)
  print(topic .. ":" )
  if data ~= nil then
    print(data)
  end
end)

function sendmqttmovement(level)
   m:publish(clientID .."/move",'{"value":"' ..level..'"}',0,1, function(conn) 
    print("sent move detection:"..level)
   end) 
end

function readDHT()
    
    dht22 = require("dht22")
    dht22.read(dhtpin)
    t = dht22.getTemperature()
    h = dht22.getHumidity()
    
    if h == nil then
      print("Error reading from DHT22")
    else  
 
       m:publish(clientID .."/temp",'{"value":"' ..((t-(t % 10)) / 10)..'.'..(t % 10)..'"}',0,1, function(conn) 
           print("Temperature: "..((t-(t % 10)) / 10).."."..(t % 10).." deg C")
       end)     
      m:publish(clientID .."/hum",'{"value":"' ..((h-(h % 10)) / 10)..'.'..(h % 10)..'"}',0,1, function(conn) 
           print("Humidity: "..((h - (h % 10)) / 10).."."..(h % 10).."%")
       end)
 
            
        -- temperature in degrees Celsius  and Farenheit
        -- floating point and integer version:
        
           
        -- humidity
        -- floating point and integer version
        
    end
end

function readGAS()
gas = adc.read(0)
    m:publish(clientID .."/gas",'{"value":"' ..gas..'"}',0,1, function(conn) 
       print("sent GAS: ",gas)
   end)
end

m:on("connect", function(con) 
print ("connected") 
readDHT()
end)

m:on("offline", function(con) 
     print ("MQTT reconnecting...") 
     print(node.heap())
     tmr.alarm(1, 10000, 0, function()
          m:connect(mqttserver, 1883, 0)
     end)
end)

-- Connect to the broker
m:connect(mqttserver, 1883, 0, function(conn) 
    print("connected MQTT") 
    
    readGAS()
    readDHT()
end)


-- loop infinito de 60000 ms
tmr.alarm(0,60000,1,function()
    
    readGAS()
    readDHT()
end)

-- interrupt for pin where movement sensor is connected
gpio.trig(movepin, "both",sendmqttmovement)
