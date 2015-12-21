
id = wifi.sta.getmac()
gpio2 = 4
gpio0 = 3
lasttemp = -999
cumTemp = 0
count = 0

--Default values if configuration parameters not set

if (host == nil or host == '') then
     host = "default-host.com"
end
if (port == nil or port == '' or port == 0) then
     port = 80
end
if (path == nil or path == '') then
     path = "/default/path.ext?data="
end
if (tag == nil or tag == '') then
     tag = "tagText"
end
if (samplingPeriod == nil or samplingPeriod == '') then
     samplingPeriod = 10
end
if (sendInterval == nil or sendInterval == '') then
     sendInterval = 30
end


function getTemp()
     print("Getting temperature")
     t = require("ds18b20")
     t.setup(gpio0)
     addrs = t.addrs()
     if (addrs ~= nil) then
       print("Total DS18B20 sensors: "..table.getn(addrs))
     end
     -- Just read temperature
     lasttemp = t.read()
     cumTemp = cumTemp + lasttemp
     count = count + 1
     print("Temperature: ")
     print(lasttemp)
     -- Don't forget to release it after use
     t = nil
     ds18b20 = nil
     package.loaded["ds18b20"]=nil
end

function sendData(jsonString)

     wifi.sleeptype(wifi.NONE_SLEEP)
     --print("Sending data")
     time = tmr.now()
     cn=net.createConnection(net.TCP,0)
     cn:on("receive", function(cn,pl) print(pl) end)
     cn:on("sent", function(cn) --[[print("Data sent")]] cn:close() end)
     --cn:on("disconnection", function(cn) print("DC: Disconnected") end)
     
     cn:connect(port,host)
     cn:on("connection", function(conn,pld)
          --print("Connected")
          conn:send("GET ".. path .. jsonString .. " HTTP/1.1\r\n")
          conn:send("Host: "..host .."\r\n")
          conn:send("Accept: */*\r\n")
          conn:send("\r\n")
          end)
     wifi.sleeptype(wifi.MODEM_SLEEP)

     end
     
function checkStatus()
     if wifi.sta.status() ~= 5 then
          print("Not connected. Restarting.")
          node.restart()
          end
     end

function heartBeat()
     sendData('{"heartBeat","id"="'..id..'","tag"="'..tag..'"}')
end

function sendTemp()
     --getTemp()
     if( count > 0) then
          temp = cumTemp / count
          cumTemp = 0
          count = 0
     else
          temp = lastTemp
     end
     s = string.format("%02f", temp)
     sendData('{"temp"='..s..',"id"="'..id..'","tag"="'..tag..'"}')
end

tmr.alarm(0,600000,1,heartBeat)
tmr.alarm(1,300000,1,checkStatus)
tmr.alarm(2,sendInterval*1000,1,sendTemp)
tmr.alarm(3,samplingPeriod*1000,1,getTemp)
