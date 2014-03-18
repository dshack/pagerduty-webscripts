--[[
Use this script to post stuff to HipChat. You can find your room id at https://subdomain.hipchat.com/rooms, 
and API docs are here: https://www.hipchat.com/docs/apiv2
--]]

local HIPCHAT_ROOM = 'your hipchat id'
local HIPCHAT_TOKEN = 'your hipchat auth token'
local MESSAGE = 'something you want to tell hipchat'

http.request {
    method='POST',
    url='https://api.hipchat.com/v2/room/'..HIPCHAT_ROOM..'/notification?auth_token='..HIPCHAT_TOKEN..'',
    headers={
        ['Content-Type']='application/json'
    },
    data=json.stringify {
    color='yellow',
    message=MESSAGE,
        message_format='text'           
}

}       
    
    
