--package.cpath = "luaclib/?.so;?.so"
--package.path = "lualib/?.lua;examples/?.lua"
package.path = appPath

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "clientsocket"
local proto = require "proto"
local sproto = require "sproto"
print_r = require "print_r"

local host = sproto.new(proto.s2c):host "package"
local request = host:attach(sproto.new(proto.c2s)) 


local fd = -1

function luaconnect(addr,port)
    print("addr==",addr,port)
    fd = (socket.connect(addr,port))
    return 0
end


local function send_package(fd, pack)
	--print("-------------------------yun_c:  send_package called",fd, pack)
	local package = string.pack(">s2", pack)
	--print("-------------------------yun0228_c:]"..package.."[")
	--print("------------s",fd, package)
	socket.send(fd, package)
	--print("--------------e")
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		--print("----------------yun_c recv_package result, last==",type(result),type(last))
		return result, last
	end
	local r = socket.recv(fd)
	if not r then
		--print("---------------------yun_c recv_package last==", last)
		return nil, last
	end
	if r == "" then
		error "Server closed"
	end
	--print("---------------------yun_c recv_package last r==["..last..r.."]___")
	return unpack_package(last .. r)
end

local session = 0

local function send_request(name, args)
	--print("-------------------------yun_c:  send_request called",name, args)
	session = session + 1
	local str = request(name, args, session)
	send_package(fd, str)
	--print("-----request name, args, session|||str = ",name,type(args), session,str)
	if type(args)=="table" then 
	--print_r(args)
	end
	--print("Request:", session)
end

local last = ""

local function print_request(name, args)
	--print("REQUEST", name)
	if args then
		for k,v in pairs(args) do
			print("request____",k,v)
		end
	end
end

local function print_response(session, args)
	--print("RESPONSE", session)
	if args then
		for k,v in pairs(args) do
			print("reply____",k,v)
		end
	end
end

local function print_package(t, ...)
	if t == "REQUEST" then
		print_request(...)
	else
		assert(t == "RESPONSE")
		print_response(...)
	end
end

local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		
		if not v then
			break
		end
		--print("v-----s["..v.."]",type(v))
		print_package(host:dispatch(v))
	end
end

function set( key,value)
    print("fd====",fd)
	send_request("set", { fkkey = key, value = value })
end

function get( key)
	send_request("get", { fkkey = key })
    while true do
		print("while-----------")
		local v
		v, last = recv_package(last)
		if not v then
			break
		end
		print("v-----s["..v.."]",type(v))
		local t , session, result = host:dispatch(v)
		print("t==---",session,t)
		if t == "RESPONSE" then
			if result then
				print("type==",type(result))
				for k,v in pairs(result) do
					print("reply____",k,v)
					return v
				end
			end
		end
	end
    return  "error"
end

function test008()
    print(088888)
end






