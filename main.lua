
CLIENTID = 'ESP8266-' ..  node.chipid() -- The MQTT ID. Change to something you like
print('main')
ip = wifi.sta.getip()
print('clientid: '..CLIENTID)
print('ip: '..ip)

leds = 6
rows = 3
offset = 2
saturation = 30
black = string.char(0, 0, 0)
statuscolor = string.char(saturation, saturation, saturation)
status = 0
color2 = string.char(0, 0, saturation)

ws2812.init()
buffer = ws2812.newBuffer(6*3, 3)
buffer:fill(0,0,0)
ws2812.write(buffer)

buffer:set(1, statuscolor)
ws2812.write(buffer)

sntp.sync("pool.ntp.org",
    function(sec, usec, server, info) syncsucsses(sec, usec, server, info) end,
    function(DNS, mem, UDP, Timeout) syncerror(DNS, mem, UDP, Timeout) end,
    true)
tmr.alarm(1, 1000, tmr.ALARM_AUTO, function() ptime() end)


function ptime()
  tm = rtctime.epoch2cal(rtctime.get())
  print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"] + offset, tm["min"], tm["sec"]))

  buffer:fill(0,0,0)
  buffer:set(1, statuscolor)
  if status > 0 then
    updaterow(0,tm["hour"] + offset)
    updaterow(1,tm["min"])
    updaterow(2,tm["sec"])
  end
  ws2812.write(buffer)
end

function updaterow(row, digit)
  for i=1,leds do
    if digit >= 2^(leds-i) then
      buffer:set(i+(row*leds), color2)
      digit = digit - 2^(leds-i)
    end
  end
end

function syncsucsses(sec, usec, server, info)
  print('sync', sec, usec, server)
  statuscolor = string.char(saturation, 0, 0)
  status = 1
end

function syncerror(DNS, mem, UDP, Timeout)
  print('error', DNS, mem, UDP, Timeout)
  statuscolor = string.char(0, saturation, 0)
  status = -1
end
