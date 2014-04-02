# PagerDuty Webscripts


Code to do stuff with pagerduty and webscripts.io. To use these:

1. Sign up for an account at webscript.io
2. Create a new script
3. Paste the contents of the .lua file into your webscript
4. Point your PagerDuty service at the webscript URL

Webscripts uses Lua because [reasons](https://www.webscript.io/help#lua). It's pretty simple to learn, and they have a [tutorial](https://www.webscript.io/documentation/lua-tutorial) as well as a great [support team](support@webscript.io).


# Setup basics

1. Sign up for an account at [webscript.io](http://webscripts.io). The free plan will work for testing, but scripts expire after 7 days, so you may want the (very reasonable) $4.95/month plan if you like the service and plan on using it long-term.

2. Create a new script.

3. Copy/paste any of the .lua files into the webscript. Some of them will require you to change some configuration variables around.

4. Point your PagerDuty service at the webscript URL (use [this article](http://www.pagerduty.com/docs/guides/hipchat-integration-guide/) as a template, switching out the Hipchat URL for a webhooks URL).


# PagerDuty Webhook notes
Full guide to webhooks [here](http://developer.pagerduty.com/documentation/rest/webhooks).

- Getting an element (ex. incident ID) from a PagerDuty webhook blob looks like this:

		local incidentid = json.parse(request.body).messages[1].data.incident.id

- PagerDuty sends webhooks on all incident state changes (list of possible types [here](http://www.pagerduty.com/docs/guides/hipchat-integration-guide/). For most hooks, you'll want to filter out all but the status you're looking for. Something like:

		local trigger_type = json.parse(request.body).messages[1].type
		if trigger_type == "incident.acknowledge" then (some code)
		else end

- PagerDuty may sometimes also send multiple webhooks, so you may want to dedupe by storing an incident key and checking future incident keys to see whether they already exist.

		if incidentid ~= storage.incidentid then
		storage.incidentid = incidentid else (some code)
		
# PagerDuty API notes

You'll need to generate a read/write API key if you want to post notes. For most other operations, a read-only key should be fine. For more information, see the PD [Integration API docs](http://developer.pagerduty.com/documentation/integration/events).

Sample call to get incidents looks like this:

		local response = http.request {
			method='GET',
			url='https://subdomain.pagerduty.com/api/v1/incidents/' .. incidentid .. '',
			headers={
		        Authorization='Token token=PAGER_DUTY_TOKEN,
		        ['Content-Type']='application/json'
		    }
			}

Posting a note looks like this:

		http.request {
		    method='POST',
		    url='https://subdomain.pagerduty.com/api/v1/incidents/' .. incidentid .. '/notes',
		    headers={
		        Authorization='Token token=PAGER_DUTY_TOKEN,
		        ['Content-Type']='application/json'
		    },
		    data=json.stringify {
		    requester_id=requester,
		    note={
		        content='STUFF_THAT_GOES_IN_NOTE'
		    }
		}
		
		}

You can also trigger events with just a service key - useful if you don't want to grant full account access to a script.

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

# Additional Tips

- If you need to inspect an incoming webhook and webscript won't display the body because it's too long, just add a `log(request.body)` line somewhere in your code. The full body will output in the log tab, and you can inspect it with something like [jsonprettyprint](http://jsonprettyprint.com/). Alternatively, you can point the webhooks at [RequestBin](http://requestb.in/), and inspect them there.

- If there is an error in your code and you produce 500's, you may need to copy/paste to a new webscript URL. PagerDuty will treat multiple subsequent 500's as a sign of a bad URL, and delay or stop calling that URL for some time.

- If you want to make an outbound call through Plivo, you need to self-host on heroku, and may also need a paid Plivo plan. It's easy; instructions [here](https://github.com/plivo/voicechat/).

- To avoid pasting service keys into every script, you can store them all in a single foo.webscript.io/storestuff script. See storage_example.lua.


# Ideas
If you're looking to hack on something....here's a running list of scripts I'd like to make:

- Call the on-call from a schedule: you'd need to [query some schedules for the on-call users](http://support.pagerduty.com/entries/23586358-Determine-Who-Is-On-Call), get their contact information, and then place an outbound call with Plivo or Twilio.
- ~~Website uptime monitoring~~: Done!
- Turn a PD webhook into an emailhook [using your gmail account](https://www.webscript.io/examples/email).
- Translate another service's webhooks into a PagerDuty API call.
- Create sample guides for Campfire, ~~Slack~~ etc. like the HipChat one.

If you work on any of them, feel free to strike them from this list.

# Improvements? Comments?

Go ahead and submit a pull request for changes. For feedback, email [dshack@pagerduty.com](dshack@pagerduty.com). I'd love to see what you make with this.




