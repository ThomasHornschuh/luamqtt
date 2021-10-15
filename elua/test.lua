-- load mqtt library



local mqtt = require("mqtt.init")

-- create MQTT client, flespi tokens info: https://flespi.com/kb/tokens-access-keys-to-flespi-platform
local con
if elua then 
    con = require("mqtt.picosocket")
else
    con = require("mqtt.luasocket")    
end     
   
local client = mqtt.client{ uri = "test.mosquitto.org",  clean = true, connector=con }

-- assign MQTT client event handlers
client:on{
    connect = function(connack)
        if connack.rc ~= 0 then
            print("connection to broker failed:", connack:reason_string(), connack)
            return
        end

        -- connection established, now subscribe to test topic and publish a message after
        assert(client:subscribe{ topic="luamqtt/#", qos=1, callback=function()
            assert(client:publish{ topic = "luamqtt/simpletest", payload = "hello" })
        end})
    end,

    message = function(msg)
        assert(client:acknowledge(msg))

        -- receive one message and disconnect
        print("received message", msg)
        client:disconnect()
    end,
}

-- run ioloop for client
mqtt.run_ioloop(client)

