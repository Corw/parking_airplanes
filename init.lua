local result = ""

-- delete keys if they exist
if redis.call("EXISTS", "parking") == 1 then
	redis.call("DEL", "parking");
end

if redis.call("EXISTS", "free") then
	redis.call("DEL", "free");
end

local nb_spaces = 100

-- initialize
for i=0, nb_spaces - 1, 1
do
	redis.call("LPUSH", "parking", "empty")
	redis.call("SADD", "free", i)
end
