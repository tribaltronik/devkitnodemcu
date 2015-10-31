# devkitnodemcu
ControlBoard.net DevKit NodeMCU

Components:
* 1 x DHT22 - Temperature and humidity sensor (1 pin digital)
* 1 x MQ135 - Ar Quality Sensor (1 analog pin)
* 1 x HC-SR501 - Motion sensor (1 pin interrupt)
* 1 x Led RBG


Files description:
- config.lua : Store the wifi authentication
-  dht22.lua : library to read dht22
-  mqtt.lua : code to read dht22,movement,gas sensor and send to server with protocol MQTT
-  rgbled.lua : code to rgbled
-  configap-lua : Config ap to config wifi
-  initwifi.lua
-  init.lua : init file that try to connect to wifi with authentication on file config.lua and if fails starts AP for wifi config
