--uart.setup(0,9600,8,0,1)
tmr.delay(2000000)
print("Read config.")
sendhost = " "
sendpath = " "
if file.open("config", "r") then
conf = file.read()
configs = cjson.decode(conf)
          for k, v in pairs( configs ) do
               print(k, v)
          end
wifi.sta.config(configs["apssid"],configs["appwd"])
host = configs["sendhost"]
path = configs["sendpath"]
port = configs["sendport"]
tag = configs["tag"]
samplingPeriod = configs["samplingPeriod"]
sendInterval = configs["sendInterval"]
file.close()
end
wifi.setmode(wifi.STATIONAP)
wifi.ap.config({ssid="esp_dsv2",pwd="temperature"})
wifi.sta.autoconnect(1)
wifi.sta.connect()
tmr.delay(2000000)
if file.open("server","r") then
     wifi.setmode(wifi.SOFTAP)
     wifi.ap.config({ssid="TEMP_SENSOR_v2",pwd="temperature"})
     tmr.delay(2000000)
     --Start config server
     file.close()
     file.remove("server")
     print("Starting configuration server")
     dofile("configServer.lua")
else
     wifi.setmode(wifi.STATION)
     wifi.sta.autoconnect(1)
     wifi.sta.connect()
     tmr.delay(2000000)
     --Start temperature sender
     file.close()
     file.open("server","w+")
     file.write(".")
     file.close()
     print("Starting temperature sender")
     dofile("tempsender.lua")
end
