--[[
Use this script with webscripts.io to automatically create conference calls for new PagerDuty incidents.
To get it working with your PagerDuty instance, change the subdomain in the API calls below to your subdomain.
Also remember to put in your PagerDuty API key!

Since you'll need a read/write API key to do this, make sure you're using an obfuscated URL for your endpoint–
'mycompany.webscript.io/pdzlkjhsdafas' is better than 'mycompany.webscript.io/pagerduty'.

--]]

-- Put your PagerDuty API key here.
local PAGER_DUTY_TOKEN = ''

-- Get the trigger type from the incident blob
local trigger_type = json.parse(request.body).messages[1].type

-- Only fire when an incident is ack'd
if trigger_type == "incident.acknowledge" then

-- Get the incident ID from the incident blob
local incidentid = json.parse(request.body).messages[1].data.incident.id

-- Make sure we haven't seen this incident before

if incidentid ~= storage.incidentid then

storage.incidentid = incidentid

-- Call the Voice Chat API to create the conference.
local response = http.request {
    method='POST',
    url='http://voicechatapi.com/api/v1/conference/'
}

-- Get the conference URL that VoiceChatAPI sends back.
local url = json.parse(response.content).conference_url

-- Get the assignee of the pagerduty incident.
local response = http.request {
	method='GET',
	url='https://api.pagerduty.com/incidents/' .. incidentid .. '',
	headers={
        Authorization='Token token=' .. PAGER_DUTY_TOKEN,
        ['Content-Type']='application/json',
				Accept='application/vnd.pagerduty+json;version=2'
    }
	}

local requester = json.parse(response.content).last_status_change_by.id

-- Add a note to the incident in Pager Duty with a link to the conference URL.
http.request {
    method='POST',
    url='https://api.pagerduty.com/incidents/' .. incidentid .. '/notes',
    headers={
        Authorization='Token token=' .. PAGER_DUTY_TOKEN,
        ['Content-Type']='application/json',
				Accept='application/vnd.pagerduty+json;version=2'
    },
    data=json.stringify {
    requester_id=requester,
    note={
        content=url
    }
}

}


return trigger_type

else

end

else end
