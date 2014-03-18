--[[
This is actually two scripts - ping the heartbeat one then run the other one as a cron job. More docs here:
https://www.webscript.io/examples/heartbeat
http://blog.buildinginternetofthings.com/2012/11/01/using-webscript-io-to-check-your-device-status/
--]]

--Heartbeat script

storage.lastping = os.time()
return "ok"

--Monitor (cron) script

local PD_SERVICE_KEY = 'my pd service key'
local DESCRIPTION = 'some event'

local N = 1
local THRESHOLD = N * 60 -- N minutes
 
local lastping = tonumber(storage.lastping or 0)
local dead = os.time() - lastping > THRESHOLD
if dead then

local DESCRIPTION = 'The thingy has not pinged in '..N..' minutes.'
	
http.request {
    method='POST',
    url='https://events.pagerduty.com/generic/2010-04-15/create_event.json',
    headers={
        ['Content-Type']='application/json'
    },
    data=json.stringify {
    service_key=PD_SERVICE_KEY,
    event_type='trigger',
    description=DESCRIPTION
}

}


end

return { lastping=lastping, dead=dead }