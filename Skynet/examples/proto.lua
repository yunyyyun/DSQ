local sprotoparser = require "sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

handshake 1 {
	response {
		msg 0  : string
	}
}

get 2 {
	request {
		fkkey 0 : string
	}
	response {
		result 0 : string
	}
}

set 3 {
	request {
		fkkey 0 : string
		value 1 : string
	}
}

quit 4 {}

]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

heartbeat000012wer 1 {}
]]

return proto
