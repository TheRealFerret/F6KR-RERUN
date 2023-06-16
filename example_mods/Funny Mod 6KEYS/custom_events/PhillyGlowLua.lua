--[[
	Philly Glow Lua Script (v0.6.1+)
	Raltyro's #4 HScript Usage in Psych Lua
	by Raltyro (6/5/2022)
	(LAST MODIFIED 8/29/2022)
	
	This script replicates how philly glow but in lua
	can be used in another stages!!
	
	You can remove this credits this if your a fucker for me i won't give a shit
	fuck me if you want.
--]]

local inPhilly = false

function onCreate()
	if (not runHaxeCode or not compareVersion(getVersion(), "0.6.1")) then
		if (addLuaScript) then
			debugPrint("The version you're currently using is unoptimized for PhillyGlowLua!")
			debugPrint("Please use the version v0.6.2 and above")
			addLuaScript("custom_events/PhillyGlowLuaOld")
		else
			debugPrint("Cannot Run Philly Glow! try Replacing \"PhillyGlowLua\" Events with \"PhillyGlowLuaOld\"")
			return close(false)
		end
		--debugPrint("The version you're currently using is not supported for PhillyGlowLua!")
		--debugPrint("The required version to use this are v0.6.2 and above")
		--return close(false)
	end
	if (getVersionNumber(getVersion()) == 061) then
		debugPrint("The version you're currently using is unstable!")
		debugPrint("Please use the version v0.6.2 and above")
	end
	
	-- LMAO DONT RUN THE SCRIPT TWICE!!
	for i = 0, getProperty("luaArray.length") - 1 do
		local scriptName = getPropertyFromGroup("luaArray", i, "scriptName"):reverse()
		scriptName = scriptName:sub(1, scriptName:find("/", 1, true) - 1):reverse()
		
		if (scriptName:lower() == "phillyglowlua.lua") then
			return close(false)
		end
	end
	
	initPhillyGlow()
end

function onCreatePost()
	runHaxeCode([[
		for (v in game.eventNotes) {
			if (v.event.toLowerCase() == "philly glow") v.event = "PhillyGlowLua";
		}
	]])
end

function initPhillyGlow()
	inPhilly = (
		type(getProperty("phillyStreet.x")) == "number" or
		getPropertyFromClass("PlayState", "curStage") == "philly" or getProperty("curStage") == "philly"
	)
	
	addHaxeLibrary("BGSprite")
	addHaxeLibrary("Std")
	addHaxeLibrary("Type")
	
	runHaxeCode([[
		inPhilly = ]] .. (inPhilly and "true" or "false") .. [[;
		FlxTypedGroup = Type.getClass(game.strumLineNotes);
		FlxTypedSpriteGroup = Type.getClass(game.gfGroup);
		
		if (!game.eventPushedMap.exists("Philly Glow")) {
			defaultPhillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
			game.phillyLightsColors = defaultPhillyLightsColors;
			
			// crash prevention
			game.phillyWindow = new BGSprite('go', 0, 0, 0, 0);
			game.add(game.phillyWindow);
			
			game.phillyStreet = new BGSprite('go', 0, 0);
			game.add(game.phillyStreet);
			
			game.eventPushed({
				strumTime: 0,
				event: "Philly Glow",
				value1: "0",
				value2: "0"
			});
			
			game.remove(game.phillyWindow);
			game.remove(game.phillyStreet);
			
			game.phillyWindow.kill(); game.phillyWindow.destroy();
			//game.phillyStreet.kill(); game.phillyStreet.destroy();
		}
		else
			defaultPhillyLightsColors = game.phillyLightsColors;
		
		realDefaultPhillyLightsColors = defaultPhillyLightsColors;
		for (v in game.eventNotes) {
			if (v.event.toLowerCase() == "philly glow") v.event = "PhillyGlowLua";
		}
		
		if (inPhilly) {
			if (game.phillyTrain != null) {
				game.remove(game.phillyTrain);
				game.insert(game.members.indexOf(game.blammedLightsBlack) + 1, game.phillyTrain);
			}
		}
		else {
			game.remove(game.blammedLightsBlack);
			game.insert(game.members.indexOf(game.gfGroup) - 2, game.blammedLightsBlack);
			
			game.phillyGlowGradient.originalHeight += 500;
			game.phillyGlowGradient.originalY = game.gf.y + 150;
			game.phillyGlowGradient.scrollFactor.set(0, .5);
			
			game.triggerEventNote("Philly Glow", "2", "0");
			PhillyGlowParticle = Type.getClass(game.phillyGlowParticles.members[0]);
			var i = game.phillyGlowParticles.members.length-1;
			while (i > 0) {
				var particle = game.phillyGlowParticles.members[i];
				if(particle.alpha < 0) {
					particle.kill();
					game.phillyGlowParticles.remove(particle, true);
					particle.destroy();
				}
				--i;
			}
		}
		game.blammedLightsBlack.scale.set(2048 * 8, 2048 * 8);
		game.blammedLightsBlack.scrollFactor.set(0, 0);
		
		var excludedObjs = [
			game.phillyGlowGradient, game.phillyGlowParticles, game.dadGroup, game.boyfriendGroup,
			game.gfGroup, game.strumLineNotes, game.opponentStrums, game.playerStrums, game.grpNoteSplashes,
			game.notes, game.strumLine
		];
		setColorPhillyGlow = function(color, darkColor) {
			if (inPhilly) {
				if (game.phillyWindowEvent != null) game.phillyWindowEvent.blend = game.phillyGlowGradient;
				if (game.phillyTrain != null) game.phillyTrain.color = darkColor;
				return;
			}
			
			for (v in game.members) {
				if (!excludedObjs.contains(v) && v != null && v.camera == game.camGame) {
					if (Std.isOfType(v, FlxTypedGroup)) {
						for (v2 in v) {
							if (Std.isOfType(v2, FlxSprite) && v2.camera == game.camGame)
								v2.color = darkColor;
						}
					}
					else if (Std.isOfType(v, FlxSprite))
						v.color = darkColor;
					else
						excludedObjs.push(v); // smart move
				}
			}
		}
	]])
	--setBlendMode("blammedLightsBlack", "add")
	setBlendMode("phillyGlowGradient", "add")
end

local reqs = {
	turns = 0,
	on = false,
	colors = nil,
	spawnPars = 0,
	change = false
}
local status = {
	turns = 0,
	on = false,
	colors = nil,
	spawnPars = 0,
	change = false
}

function onEvent(n, v1, v2)
	if (inGameOver) then return end
	n = n:lower() or ""
	v1 = tostring(v1) or ""
	v2 = tostring(v2) or ""
	
	if (n == "phillyglowlua") then
		local s, empty = false, v2:trim() == ""
		
		v1 = tonumber(v1)
		
		local prevColors = reqs.colors
		if (v1 >= 1 and v1 <= 4) then
			if (not empty) then
				reqs.colors = {}
				
				local ogV2 = v2
				v2 = v2:startsWith("[") and v2:sub(2) or v2
				v2 = v2:endsWith("]") and v2:sub(0, #v2 - 1) or v2
				
				local sep = string.split(v2, ",")
				
				for _,v in pairs(sep) do
					s, color = pcall(colorfromString, v:trim())
					if (s) then
						table.insert(reqs.colors, color)
					else
						debugPrint("PhillyGlowLua Error! Value2 \"" .. ogV2 .. "\" cannot be setted")
					end
				end
			elseif (v1 ~= 2) then
				reqs.colors = {}
			end
		end
		
		if (v1 == 0) then
			reqs.on = false
			reqs.turns = reqs.turns + 1
		elseif (v1 == 1) then -- turn on
			reqs.on = true
			reqs.turns = reqs.turns + 1
		elseif (v1 == 2) then -- spawn particles
			if (reqs.on and #reqs.colors > 0 and not table.equals(reqs.colors, prevColors)) then
				reqs.turns = reqs.turns + 1
			end
			reqs.spawnPars = reqs.spawnPars + 1
		elseif (v1 == 3) then
			reqs.on = true
			reqs.turns = reqs.turns + 1
			reqs.spawnPars = reqs.spawnPars + 1
		elseif (v1 == 4) then
			reqs.change = true
		end
	--[==[
	elseif (n == "philly glow") then
		runHaxeCode([[
			for (v in game.eventNotes) {
				if (v.event.toLowerCase() == "philly glow") v.event = "PhillyGlowLua";
			}
		]])
		onEvent("PhillyGlowLua", v1, v2)
	]==]
	end
end

function ev0()
	runHaxeCode([[
		game.triggerEventNote("Philly Glow", "0", "");
		setColorPhillyGlow(0xFFFFFFFF, 0xFFFFFFFF);
	]])
end

function ev1()
	local cum = "["
	if (type(reqs.colors) == "table" and #reqs.colors > 0) then
		for i,v in pairs(reqs.colors) do
			cum = cum .. tostring(v) .. (i == #reqs.colors and "" or ",")
		end
	end
	cum = cum .. "]"
	
	runHaxeCode([[
		game.phillyLightsColors = ]] .. (cum == "[]" and "defaultPhillyLightsColors" or cum) .. [[;
		if (game.phillyLightsColors.length <= 1) game.curLightEvent = -1;
		
		game.triggerEventNote("Philly Glow", "1", "0");
		var color = game.phillyGlowGradient.color;
		var darkColor = game.phillyStreet.color;
		
		if (!inPhilly) {
			game.phillyWindowEvent.visible = false;
			game.blammedLightsBlack.alpha = .85;
			game.remove(game.phillyWindowEvent);
		}
		setColorPhillyGlow(color, darkColor);
	]])
end

function ev2()
	runHaxeCode([[
		if (inPhilly) {
			game.triggerEventNote("Philly Glow", "2", "0");
			
			game.phillyGlowParticles.forEachAlive(function(par) {
				par.blend = game.phillyGlowGradient.blend;
			});
		}
		else {
			if(!ClientPrefs.lowQuality) {
				var particlesNum = FlxG.random.int(8, 12);
				var width = (4000 / particlesNum);
				var color = game.phillyLightsColors[game.curLightEvent];
				for (j in 0...6) {
					for (i in 0...particlesNum) {
						var particle:PhillyGlowParticle = new PhillyGlowParticle(
							(game.camGame.scroll.x - (game.camGame.width / 1.25)) + width * i + FlxG.random.float(-width / 5, width / 5),
							game.phillyGlowGradient.originalY + (FlxG.random.float(0, 600) + j * 40) + 265,
							color
						);
						
						particle.blend = game.phillyGlowGradient.blend;
						game.phillyGlowParticles.add(particle);
					}
				}
			}
			
			game.phillyGlowGradient.bop();
		}
	]])
end

function ev4()
	local cum = "["
	if (type(reqs.colors) == "table" and #reqs.colors > 0) then
		for i,v in pairs(reqs.colors) do
			cum = cum .. tostring(v) .. (i == #reqs.colors and "" or ",")
		end
	end
	cum = cum .. "]"
	
	runHaxeCode([[
		defaultPhillyLightsColors = ]] .. (cum == "[]" and "realDefaultPhillyLightsColors" or cum) .. [[;
	]])
	reqs.change = false
end

function onUpdate()
	if (reqs.change ~= status.change) then
		ev4()
	end
	
	if (reqs.turns ~= status.turns) then
		if (reqs.on) then
			ev1()
		else
			ev0()
		end
	end
	
	if (reqs.spawnPars ~= status.spawnPars) then
		ev2()
	end
	
	for i, v in next, reqs do status[i] = v end
end

function onUpdatePost()
	runHaxeCode([[
		if (game.phillyGlowGradient != null) {
			game.phillyGlowGradient.scale.x = 2048 * 8;
			game.phillyGlowGradient.x = (FlxG.width - game.phillyGlowGradient.width) / 2;
		}
	]])
end

-- these are different
function equals(a, b)
	if (type(b) ~= "table") then return b == a end
	for _,v in ipairs(b) do
		if (v == a) then return true end
	end
	return false
end

function table.find(table,v)
	for i,v2 in next,table do
		if v2 == v then
			return i
		end
	end
end

function table.equals(a, b)
	if (type(a) ~= "table" or type(b) ~= "table") then return end
	for _,v in ipairs(b) do
		if (table.find(a, v)) then return true end
	end
	return false
end

function string.split(self, sep)
	if sep == "" then return {str:match((str:gsub(".", "(.)")))} end
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(self, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function string.startsWith(self, prefix) return self:find(prefix, 1, true) == 1 end
function string.endsWith(self, suffix) return self:find(suffix, 1, true) == #self - (#suffix - 1) end

function string.duplicate(s, i)
	local str = ""
	for i = 1, i do
		str = str .. s
	end
	return str
end

function colorfromString(v)
	v = v:startsWith("0x") and v:sub(3) or v
	local r, g, b = from_hex(3, "0x" .. v:sub(#v - 5, #v))
	return to_num(3, r, g, b)
end

function from_hex(hexes, hex)
	local v = {string.match(hex, "^0x?" .. string.duplicate("(%w%w)", hexes or 3) .. "$")}
	for i in next, v do v[i] = tonumber(v[i], 16) end
    return unpack(v)
end

function to_num(hexes, ...)
	return tonumber("0x" .. string.format(string.duplicate("%02X", hexes or 3), ...))
end

function string.isSpace(self, pos)
	if (#self < 1 or pos < 1 or pos > #self) then
		return false
	end
	local c = self:byte(pos)
	return (c > 8 and c < 14) or c == 32
end

function string.ltrim(self)
	local i = #self
	local r = 1
	while (r <= i and self:isSpace(r)) do
		r = r + 1
	end
	return r > 1 and self:sub(r, i) or self
end

function string.rtrim(self)
	local i = #self
	local r = 1
	while (r <= i and self:isSpace(i - r + 1)) do
		r = r + 1
	end
	return r > 1 and self:sub(0, i - r + 1) or self
end

function string.trim(self) return string.ltrim(self:rtrim()) end







-- version checker
version3rdStrumlineRalt = 1

function getVersion()
	return version or getPropertyFromClass("MainMenuState", "psychEngineVersion") or "0.0.0"
end

function getVersionLetter(ver) -- ex "0.5.2h" > "h"
	local str = ""
	string.gsub(ver, "%a+", function(e)
		str = str .. e
	end)
	return str
end

function getVersionNumber(ver) -- ex "0.6.1" > 61
	local str = ""
	string.gsub(ver, "%d+", function(e)
		str = str .. e
	end)
	return tonumber(str)
end

function getVersionBase(ver) -- ex "0.5.2h" > "0.5.2"
	local letter, str = getVersionLetter(ver), ""
	if (letter == "") then return ver end
	for s in ver:gmatch("([^"..letter.."]+)") do
		str = str .. s
	end
	return str
end

function compareVersion(ver, needed)
	local a, b = getVersionLetter(ver), getVersionLetter(needed)
	local c, d = getVersionNumber(ver), getVersionNumber(needed)
	local v = true
	if (c == d) then v = (b == "" or (a ~= "" and a:byte() >= b:byte())) end
	return c >= d and v
end
