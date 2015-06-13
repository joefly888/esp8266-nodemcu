-- this is an adaptation of the work of from 
-- http://captain-slow.dk/2015/04/16/posting-to-thingspeak-with-esp8266-and-nodemcu/
-- this modification POST to Ubidots.com instead

wifi.setmode(wifi.STATION)
wifi.sta.config("your-SSID","your-PASSWORD")  -- need to wait for a few seconds to connect
print(wifi.sta.getip())  -- issue command to see local IP, may print nil prior to connection

idvariable = "your-ubidots-variableID"
token = "your-ubidots-token"


function postUbidots(level)
    connout = nil
    connout = net.createConnection(net.TCP, 0)
 
    connout:on("receive", function(connout, payloadout)
        if (string.find(payloadout, "201 CREATED") ~= nil) then
            print("GOOD POST");
        end
    end)
 
    connout:on("connection", function(connout, payloadout)
        local value = node.readvdd33() / 1000;   
        local var = '{"value": '..value..'}';
        local num = string.len(var);   
        local postval = "POST /api/v1.6/variables/"..idvariable.."/values HTTP/1.1\n"       
          .."Content-Type: application/json\n"
          .."Content-Length: "..num.."\n"
          .."X-Auth-Token: "..token .."\n" 
          .."Host: things.ubidots.com\n\n"
          ..var.."\n\n"; 
        connout:send(postval)
    end)
 
    connout:on("disconnection", function(connout, payloadout)
        connout:close();
        collectgarbage();
    end)
 
    connout:connect(80,'things.ubidots.com')
end

tmr.alarm(1, 60000, 1, function() postUbidots(0) end)  -- post to ubicode every minute
