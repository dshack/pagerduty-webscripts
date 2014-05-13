local incidentid = json.parse(request.body).messages[1].data.incident.id

local desc = "no description provided"
local trigger = json.parse(request.body).messages[1].data.incident.trigger_summary_data
local desc = trigger.description or trigger.subject or "no description provided"
	
local trigger_type = json.parse(request.body).messages[1].type

if trigger_type == "incident.trigger" then
	
	
http.request {
    method='POST',
    url='your_dashing_url',
    headers={
        ['Content-Type']='application/json'
    },
    data=json.stringify {
		auth_token='YOUR_AUTH_TOKEN',
		text = 'Incident '..incidentid..': '..desc..'!'
}

}	
	
else
	


end
