# devkitnodemcu
ControlBoard.net DevKit NodeMCU

![alt tag](https://github.com/tribaltronik/devkitnodemcu/blob/master/DevkitNodeMCU.jpg)

Components:
* 1 x DHT22 - Temperature and humidity sensor (1 pin digital)
* 1 x MQ135 - Ar Quality Sensor (1 analog pin)
* 1 x HC-SR501 - Motion sensor (1 pin interrupt)
* 1 x Led RBG

If you want to BUY this kit click here:
http://www.ebay.com/itm/Smart-Home-DevKit-DIY-ControlBoard-Net-NodeMCU-Based-/131641456092?ssPageName=ADME:L:LCA:US:1123


How to program:

Use the ESPLORER:
- http://esp8266.ru/esplorer/

Files description:
- config.lua : Store the wifi authentication
-  dht22.lua : library to read dht22
-  mqtt.lua : code to read dht22,movement,gas sensor and send to server with protocol MQTT
-  rgbled.lua : code to rgbled
-  configap-lua : Config ap to config wifi
-  initwifi.lua
-  init.lua : init file that try to connect to wifi with authentication on file config.lua and if fails starts AP for wifi config

How to use:
- Power the Dev Kit NodeMCU;
- In a device (Smartphone, Tablet) connect to wifi AP "controlboardkit" with the password "12345678";
- When connected, open your browser and entry this url: "192.168.4.1";
- Select your home wifi network and password;
