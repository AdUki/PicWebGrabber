require('socket.http')

local counter = 1

function sleep(seconds)
	counter = counter + 1
	if counter == 10 then 
		print ('# Failed to download file' .. arg[1])
		os.exit()
	end
	os.execute('sleep 1')
end

repeat
	body = socket.http.request(arg[1])
	if body == nil then sleep(1) end
until body ~= nil
io.write(body)