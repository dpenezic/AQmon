#!/bin/bash

: ${PORT:=`ls /dev/ttyUSB? /dev/rfcomm? 2>/dev/null`}
: ${VERSION:=0.9.6-dev_20150704}
: ${CHANNEL:=37527}

(($#))||set wipe bmp180 am2321 i2d pms3003 sensor_hub \
            keys_v$CHANNEL wifi_init rgbLED sendData AQmon init

while (($#)); do
  PORT=`ls /dev/ttyUSB? /dev/rfcomm? 2>/dev/null`
  opt=$1
  trap "exit" SIGHUP SIGINT SIGTERM
  case $opt in
  nodemcu_float|nodemcu_integer)
    esptool.py --port $PORT --baud 115200 write_flash 0x00000 \
      ../nodemcu-firmware/bin/$opt\_$VERSION.bin ;;
# list) luatool.py -p $PORT -l;;
  wipe)
    luatool.py -p $PORT -rw;;
  bmp180|dht22|am2321)
    luatool.py -p $PORT -rcf $opt.lua;;
  wifi_init|i2d|pms3003|sendData|rgbLED|keys) #|hueLED)
    luatool.py -p $PORT -cf $opt.lua;;
  app|app.*|AQmon|AQmon.*)
    luatool.py -p $PORT -rcf ${opt%.*}.lua -t app.lua;;
  hub|hub.*|*_hub|*_hub.*)
    luatool.py -p $PORT -rcf ${opt%.*}.lua -t sensors.lua;;
  init|init.lua)
    luatool.py -p $PORT -rf ${opt%.*}.lua;;
  *_v*|*_v*.lua)  # alternative versions, ej keys_v37527
    luatool.py -p $PORT -cf ${opt%.*}.lua -t ${opt/_v*/.lua};;
  *_test.lua)# test scripts
    luatool.py -p $PORT -df $opt -t test.lua;;
  *.lua)     # other scipts
    luatool.py -p $PORT -f $opt;;
  esac && shift
  trap - SIGHUP SIGINT SIGTERM
done
