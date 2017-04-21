 redis.replicate_commands()

local nb_spaces = 5 
 
 local function get_assigned_parking(plane_id)
	
	for i = 0, nb_spaces - 1, 1
	do
		if redis.call("LINDEX", "parking", i) == plane_id then
			return tostring(i);
		end
	end
	
	return nil;
end

local function assign_parking(plane_id)
	local parking = get_assigned_parking(plane_id);
	
	if parking == nil then		
		parking = redis.call("SRANDMEMBER", "free");
		redis.call("SREM", "free", parking);
		redis.call("LSET", "parking", parking, plane_id);
	end
	
	return parking;
end

local plane_id = ARGV[1]

return assign_parking(plane_id)