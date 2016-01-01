local module = {}  

ssid =""
password =""
secretkey =""
local unescape = function (s)
     s = string.gsub(s, "+", " ")
     s = string.gsub(s, "%%(%x%x)", function (h)
          return string.char(tonumber(h, 16))
         end)
     return s
end

function writewificonfig()
    file.remove("wificonfig.lua")
    file.open("wificonfig.lua", "a+")
    file.writeline('ssid= \"'..ssid..'\"')
    file.writeline('password= \"'..password..'\"')
     file.writeline('secretkey= \"'..secretkey..'\"')
    file.close()
end



function setup_server()
    topicid = node.chipid()
    -- Prepare HTML form
    print("Preparing HTML Form")
    if (file.open('configform.html','r')) then
        buf = file.read()
        file.close()
    end
    -- interpret variables in strings
    -- ssid="WLAN01"
    -- str="my ssid is ${ssid}"
    -- interp(str) -> "my ssid is WLAN01"
    buf = buf:gsub('($%b{})', function(w) 
        return _G[w:sub(3, -2)] or "" 
    end)

  print("Setting up Wifi AP")
    wifi.setmode(wifi.SOFTAP)
  local cfg={}
  cfg.ssid = "controlboardkit"
  cfg.pwd  = "12345678"
  wifi.ap.config(cfg)

  print("Setting up webserver")
  local srv = nil
    srv=net.createServer(net.TCP)
    srv:listen(80,function(conn)
        conn:on("receive", function(client,request)
            local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
            if(method == nil)then
                _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
            end
            local _GET = {}
            if (vars ~= nil)then
                for k, v in string.gmatch(vars, "([_%w]+)=([^%&]+)&*") do
                _GET[k] = unescape(v)
                end
            end

            if ( _GET.ssid ~= nil) then
                if (_GET.ssid == "-1") then _GET.ssid=_GET.hiddenssid end
                client:send("Saving data..");
                ssid = _GET.ssid
                password = _GET.password
                secretkey = _GET.secretkey
                if password == nil then password="" end
                print("Saving wifi data")
                writewificonfig()
                
                --client:send(buf);
                
                -- delay 100us    
                tmr.delay(2000)
                node.restart();
                return
            end

            payloadLen = string.len(buf)
            client:send("HTTP/1.1 200 OK\r\n")
            client:send("Content-Type    text/html; charset=UTF-8\r\n")
            client:send("Content-Length:" .. tostring(payloadLen) .. "\r\n")
            client:send("Connection:close\r\n\r\n")               
            client:send(buf, function(client) client:close() end);
        end)
    end)
    print("Setting up Webserver done. Please connect to: " .. wifi.ap.getip())
end

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function module.start()  
    -- Restart after 10 min
    tmr.alarm(0, 600000, 0, function() 
        print("Restart after 10 min")
        node.restart();
    end )
    print("Get available APs")
    wifi.setmode(wifi.STATION) 
    wifi.sta.getap(function(t)
        available_aps = "" 
        if t then 
            local count = 0
            for k,v in pairs(t) do 
                ap = string.format("%-10s",k) 
                ap = trim(ap)
                available_aps = available_aps .. "<option value='".. ap .."'>".. ap .."</option>"
                count = count+1
                if (count>=10) then break end
            end 
            available_aps = available_aps .. "<option value='-1'>---hidden SSID---</option>"
            setup_server()
        end
    end)
end

return module  
