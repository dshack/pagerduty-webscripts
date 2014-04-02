--[[
Use this to check whether a website is up. If the website is down, it creates a new PagerDuty incident. Otherwise, it resolves the incident.

Because the script stores available status in an array through storage[domain], you can use it to check multiple sites: just create one webscript for each host you want to check.
--]]

local PD_SERVICE_KEY = 'service key goes here'

local domain = 'domain you want to check'

-- Assume 'changed' is false
local changed = false

-- Ping the domain and look for a 200. If no response, available = false
local response = http.request { url = 'http://'..domain }
local available = response and response.statuscode == 200

-- If storage[domain] is different than the available variable, site has changed
changed = tostring(available) ~= storage[domain]

-- Store the available status (true/false) into storage[domain]
storage[domain] = available

-- Log some stuff
log("checked domain:",domain)
log("changed: ",changed)
log("available: ",available)

-- Only do stuff if the website's status has changed
if changed then
	if available then
	
	-- If the website's back up, find the PD incident and resolve it.
		local response = http.request {
				method='POST',
				url='https://events.pagerduty.com/generic/2010-04-15/create_event.json',
				headers={
						['Content-Type']='application/json'
				},
				data=json.stringify {
				service_key=PD_SERVICE_KEY,
				event_type='resolve',
				incident_key=storage.incident_key
		}
		}
		log(response)
	else
	
	-- If the website's down, create a new PD incident.
	    local response = http.request {
	    method='POST',
	    url='https://events.pagerduty.com/generic/2010-04-15/create_event.json',
	    headers={
	        ['Content-Type']='application/json'
	    },
	    data=json.stringify {
	    service_key=PD_SERVICE_KEY,
	    event_type='trigger',
	    description=string.format('The domain %s is offline', domain)
			}

			}
			storage.incident_key = json.parse(response.content).incident_key
			log("incident created: key:",incident_key)
			log(response)
	end
end

return status, domain
