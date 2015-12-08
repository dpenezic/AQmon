# Sensor modules
Lua modules for [AQmon][] project.<br/>

[luatool.py]: https://github.com/4refr0nt/luatool

### Sensor modules
- `bmp180.lua`: BMP085 / BMP180 sensors.
- `am2321.lua`: AM2320 / AM2321 sensors.
- `bme280.lua`: BME280 sensor, can replace BMPxxx and AM232x sensors.
- `pms3003.lua`: PMS3003 sensor.
- `sensor_hub.lua`: Read all sensors above.

#### Notes
- Do not use pin `D8` (`gpio15`) for `I2C` as the
  pull-up resistors will interfeere with the bootiung process.
- BMP085, BMP180 and BME280 sensors have the same I2C address,
  so you can ony have one of them on the buss.

### Ussage example
*Note*: Do not use pin `D8` (`gpio15`) for `I2C` as the pull-up resistors will
interfeere with the bootiung process.

#### BMP085, BMP180
```lua
-- module setup and read
sda,scl=3,4 -- GPIO0,GPIO2
found=require('bmp180').init(sda,scl)
if found then
  bmp180.read(0)   -- 0:low power .. 3:oversample
  p,t = bmp180.pressure,bmp180.temperature
end

-- release memory
bmp180,package.loaded.bmp180 = nil,nil

-- format and print the results
if type(p)=='number' then
  p=('%6d'):format(p)
  p=('%4s.%2s'):format(p:sub(1,4),p:sub(5))
end
if type(t)=='number' then
  t=('%5d'):format(t)
  t=('%3s.%2s'):format(t:sub(1,3),t:sub(4))
end
print(('p:%s hPa, t:%s C, heap:%d')
  :format(p or 'null',t or 'null',node.heap()))
```

#### AM2320, AM2321
```lua
-- module setup and read
sda,scl=3,4 -- GPIO0,GPIO2
found=require('am2321').init(sda,scl)
if found then
  am2321.read()
  h,t = am2321.humidity,am2321.temperature
end

-- release memory
am2321,package.loaded.am2321 = nil,nil

-- format and print the results
if type(h)=='number' then
  h=('%5d'):format(h)
  h=('%3s.%2s'):format(h:sub(1,3),h:sub(4))
end
if type(t)=='number' then
  t=('%5d'):format(t)
  t=('%3s.%2s'):format(t:sub(1,3),t:sub(4))
end
print(('h:%s %%, t:%s C, heap:%d')
 :format(h or 'null',t or 'null',node.heap()))
```

#### BME280
```lua
-- module setup and read
sda,scl=3,4 -- GPIO0,GPIO2
found=require('bme280').init(sda,scl)
if found then
  bme280.read()
  p,t,h = bme280.pressure,bme280.temperature,bme280.humidity
end

-- release memory
bme280,package.loaded.bme280 = nil,nil

-- format and print the results
if type(p)=='number' then
  p=('%6d'):format(p)
  p=('%4s.%2s'):format(p:sub(1,4),p:sub(5))
end
if type(t)=='number' then
  t=('%5d'):format(t)
  t=('%3s.%2s'):format(t:sub(1,3),t:sub(4))
end
if type(h)=='number' then
  h=('%5d'):format(h)
  h=('%3s.%2s'):format(h:sub(1,3),h:sub(4))
end
print(('p:%s hPa, t:%s C, h:%s %%, heap:%d')
 :format(p or 'null',t or 'null',h or 'null',node.heap()))
```

#### PMS3003
```lua
-- module setup and read
pinSET=7
require('pms3003').init(pinSET)
pms3003.verbose=true -- verbose mode
pms3003.read(function()
  pm01 = pms3003.pm01 or 'null'
  pm25 = pms3003.pm25 or 'null'
  pm10 = pms3003.pm10 or 'null'

-- release memory
  pms3003,package.loaded.pms3003 = nil,nil

-- print the results
  print(('pm1:%s, pm2.5:%s, pm10:%s [ug/m3], heap:%d'):format(pm01,pm25,pm10,node.heap()))
end)
```
#### Sensor Hub
```lua
-- module setup and read: no PMS3003
sda,scl,pinSET=3,4,nil -- GPIO0,GPIO2
require('sensors').init(sda,scl,pinSET)
sensors.verbose=true -- verbose mode
sensors.read()

-- module setup and read: all sensors
sda,scl,pinSET=5,6,7
require('sensors').init(sda,scl,pinSET)
sensors.read(function()
  print(sensors.format({heap=node.heap(),time=tmr.time()},
    'sensors:{time}[s],{t}[C],{h}[%],{p}[hPa],{pm01},{pm25},{pm10}[ug/m3],{heap}[b]'))
end)

-- release memory
sensors,package.loaded.sensors = nil,nil
```