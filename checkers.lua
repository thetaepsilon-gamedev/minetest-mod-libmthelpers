local check = {}



local numbercheck = function(val, label, caller)
	local valtype = type(val)
	if (valtype ~= "number") then
		error(caller.."(): non-numerical value passed for "..label)
	end
end
check.number = numbercheck



local integercheck = function(val, label, caller)
	numbercheck(val, label, caller)
	if (val % 1.0 ~= 0.0) then
		error(caller.."(): integer value required for "..label)
	end
end
check.integer = integercheck



local rangecheck = function(val, lower, upper, isinteger, label, caller)
	if isinteger then integercheck(val, label, caller) else numbercheck(val, label, caller) end
	if (val < lower) or (val > upper) then
		error(caller.."(): "..label.." expected value in range "..lower.."-"..upper..", got "..val)
	end
end
check.range = rangecheck



check.mkassert = function(caller)
	return function(condition, message)
		if not condition then
			error(caller..": "..message)
		end
	end
end



return check
