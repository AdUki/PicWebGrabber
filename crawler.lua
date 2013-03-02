-- Get OS type
do
	local lfs = require 'lfs'
	local dir = lfs.currentdir()
	if string.byte(dir) ~= string.byte('/') 
		then windows = true 
		else unix = true
	end
	
	runOnBackground = function(cmd)
		if windows == true 
			-- on Windows
			then return ("START /B " .. cmd)
			-- on Unix
			else return (cmd .. '&')
		end
	end
end

-- Load the relevant LuaSocket modules
local http = require("socket.http")
local ltn12 = require("ltn12")

-- Declaration of main tables and variables
local domain
local regexpDomain
local newHops = {}
local oldHops = {}
local pictures = {}
local fetchBody = {}

-- Helper functions

function savePic(link)
	-- Regexp on image
	local match = false
	for regexp in ipairs(arg, 2) do
		if link:find(regexp) ~= nil then 
			match = true 
			break
		end
	end
	if match == false then return end
	-- Save image
	local name = link:match("[^/]*$")
	if pictures[name] == nil then
		pictures[name] = true 
		os.execute(runOnBackground("lua download.lua " .. link .. " " .. name));
	end
end

function getNewHops(body)
	for tag in body:gmatch('<a[^>]*>') do
		link = tag:match('href="([^"]*)"')
		if link == nil then return end
		if link:find('^/') ~= nil 
		then link = 'http://' .. regexpDomain .. link end
		
		-- remove unused attributes after ?
		--[[
		if link:find('?') ~= nil then
			local page = link:match('?.*'):match('page=%d+');
			link = link:match('^[^?]*') .. '?' .. page or ''
		end
		--]]
		-- somtimes there are links to pictures, save them
		if link:find("\.jpg$") ~= nil
		then savePic(link) 
		-- found unique links add to new hops
		elseif link:find(regexpDomain) ~= nil
		then 
			if oldHops[link] == nil
			then newHops[link] = true end
		end
	end
end

function getPictures(body)
	for tag in body:gmatch('<img([^>]*)>') do
		link = tag:match('src="([^"]*)"')
		if link == nil then return end
		if link:find('^/') ~= nil 
		then link = 'http://' .. regexpDomain .. link end
		-- unique found links add to pictures
		if link:find(regexpDomain) ~= nil
		then savePic(link) end
	end
end

-- Load domain
if #arg == 0 then
	print 'Usage: lua crawler.lua [url] [regexp...]'
	os.exit()
end
domain = arg[1]
newHops[domain] = true;

-- Add http:// suffix if necessary
if domain:find('^http://') == nil then
	regexpDomain = domain
	domain = 'http://' .. domain
else
	regexpDomain = domain:sub(8)
end
-- Set base domain
regexpDomain = regexpDomain:match('[^/]+')
print('DOMAIN ' .. regexpDomain .. '\n')

-- Main loop
local url = domain;
newHops[url] = true;
repeat
	print ('\nSearching url: ' .. url)
	
	local counter = 0
	for i,v in pairs(newHops) do
		if fetchBody[i] == nil then
			counter = counter + 1
			fetchBody[i] = io.popen(runOnBackground('lua grab.lua "' .. url .. '"'))
			if counter == 10 then break end
		end
	end
	
	if fetchBody[url] ~= nil then
		local body = fetchBody[url]:read("*a");
		fetchBody[url] = nil;
		if (body ~= nil) then
			getNewHops(body)
			getPictures(body)
			newHops[url] = nil
			oldHops[url] = true
			url = next(newHops)
		end
	end
until url == nil 
