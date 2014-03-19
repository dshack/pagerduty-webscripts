--[[
Use this to post a webhook to Slack chat.

You'll need a specific url for each webhook: create it at https://dshack.slack.com/services/new/incoming-webhook

The 'text' parameter is mandatory. The 'emoji' parameter is optional, and supports the emoji listed at http://unicodey.com/emoji-data/table.htm

--]]

http.request {
    method='POST',
    url='<Slack incoming webhook URL>',
    headers={
        ['Content-Type']='application/json'
    },
    data=json.stringify {
    text='hello',
    icon_emoji=':ghost:'
		}
}
