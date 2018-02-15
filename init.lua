wifi.setmode(wifi.STATION)
wifi.sta.config("≤Your AP>","<Your password>")
wifi.sta.connect()

tmr.alarm(1, 5000, 0, function() dofile("main.lua") end)
