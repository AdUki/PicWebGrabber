-- Load the relevant LuaSocket modules
local http = require("socket.http")
local ltn12 = require("ltn12")

local siteName = arg[1]
local fileName = arg[2] or 'noname'

print('> Downloading ' .. fileName)

-- Create local file for saving data
myFile = io.open( fileName, "w+b" ) 

-- Request remote file and save data to local file
http.request{
    url = siteName,
    sink = ltn12.sink.file(myFile)
}