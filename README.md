# temp-sensor-esp8266LUA
Temperature sensor sender using ESP8266 and DS18b20 sensor. The code is based on the ESP-01 board.

The sensor is configurable via HTTP GET command:
http://192.168.4.1/cfg?conf='{"apssid":"AP_name","appwd":"passwd","sendhost":"sendhost.com","sendport":"80","sendpath":"/path/to?data=","tag":"someTag","sendInterval":"60","samplingPeriod":"10"}'


When initially powered on the sensor is in one of two states:
1) Accepting configuration
2) Sensor and sending mode

Mode 1 last for 60 seconds, during which the sensor is in AP mode and configurable with the HTTP GET command specified above. After the 60 seconds, the sensor reboots it self and will enter mode 2, in which it is in client mode and will stay indefinitely untill rebooted. The sensor will appear with the SSID of "TEMP_SENSOR_v2" and the password is "temperature".

Alternatively, the configuration file can initially be saved to the board (which may be easier that trying to connect a device to the sensor when it is in Mode 1 (AP mode), since there is no Internet connection from it).

# Hardware

The data line of the DS18b20 sensor needs to be connected to gpio0. The DS18b20 should work in parasitic mode and best performance is achieved by connecting the positive (usually red line) and the ground (usually black) to the ground pin of the ESP-01.

Using 2*AA rechargeable batteries (2500 mAh) each, the sensor should be able to send for 36-48 hours. If using an ESP-board that has deep sleep capability enabled, you need to modify the code. 
