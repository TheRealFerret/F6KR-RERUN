forceLua = true -- shit going to be real

local inPhilly = false
local week7 = false

function onCreate()
	inPhilly = type(getProperty("phillyTrain.x")) == "number" -- Check if it's in Philly Stage
	week7 = inPhilly and type(getProperty("phillyStreet.x")) == "number" -- Check if the user Psych Engine has Official Week 7
	
	if (not week7 or forceLua) then
		if (addLuaScript) then
			addLuaScript(runHaxeCode and "custom_events/PhillyGlowLua" or "custom_events/PhillyGlowLuaOld")
		else
			debugPrint("Cannot Run Philly Glow! try Replacing \"Philly Glow\" Events with \"PhillyGlowLua\"")
			return close(false)
		end
	else
		return close(false)
	end
end