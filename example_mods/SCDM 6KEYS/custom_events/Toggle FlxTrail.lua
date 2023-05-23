function to_hex(rgb)
    local hexadecimal = '' -- yeah ignore

    for key, value in pairs(rgb) do
        local hex = ''

        while(value > 0)do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub('0123456789ABCDEF', index, index)  ..  hex            
        end

        if(string.len(hex) == 0)then
            hex = '00'

        elseif(string.len(hex) == 1)then
            hex = '0'  ..  hex
        end

        hexadecimal = hexadecimal  ..  hex
    end

    return hexadecimal
end -- Hex script by Cherry on the Psych Engine Discord!

trailEnabledDad = false
trailEnabledBF = false
timerStartedDad = false
timerStartedBF = false

local trailLength = 5
local trailDelay = 0.05

local isDefColorDad = true
local isDefColorBF = true
local defaultColorDad
local defaultColorBF
function onUpdate(elapsed)
	defaultColorDad = getColorFromHex(to_hex(getProperty('dad.healthColorArray')))
	defaultColorBF = getColorFromHex(to_hex(getProperty('boyfriend.healthColorArray')))
	if isDefColorDad == true then
		colorDad = defaultColorDad
	else
		-- Blank on Purpose
	end
	if isDefColorBF == true then
		colorBF = defaultColorBF
	else
		-- Blank on Purpose
	end
end

function onEvent(name, value1, value2)

	if name == 'Toggle FlxTrail' then
		
		if value1 == 'on' then
			if not timerStartedDad then
				runTimer('timerTrailDad', trailDelay, 0)
				timerStartedDad = true
			end
			trailEnabledDad = true
			curTrailDad = 0
		elseif value1 == 'off' then
			trailEnabledDad = false
		end
		
		if value2 == 'on' then
			if not timerStartedBF then
				runTimer('timerTrailBF', trailDelay, 0)
				timerStartedBF = true
			end
			trailEnabledBF = true
			curTrailBF = 0
		elseif value2 == 'off' then
			trailEnabledBF = false
		end
		
	end
	
	if name == 'Change FlxTrail Color' then
		
		if value1 == 'default' then
			isDefColorDad = true
		elseif value1 ~= 'default' then
			isDefColorDad = false
		end
		--[[if isDefColorDad == true and value1 == '' then
			colorDad = colorDad
		elseif isDefColorDad == false and value1 == '' then
			colorDad = getColorFromHex(colorDad)
		end]]
		
		if value2 == 'default' then
			isDefColorBF = true
		elseif value2 ~= 'default' then
			isDefColorBF = false
		end
		--[[if isDefColorBF == true and value2 == '' then
			colorBF = colorBF
		elseif isDefColorBF == false and value2 == '' then
			colorBF = getColorFromHex(colorBF)
		end]]
		
		colorDad = value1
		colorBF = value2
		
	end

end

function onStartCountdown()
	-- countdown started, duh
	-- return Function_Stop if you want to stop the countdown from happening (Can be used to trigger dialogues and stuff! You can trigger the countdown with startCountdown())
	triggerEvent('Change FlxTrail Color', 'default', 'default')
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'timerTrailDad' then
		createTrailFrame('Dad')
	end
	
	if tag == 'timerTrailBF' then
		createTrailFrame('BF')
	end
end

curTrailDad = 0
curTrailBF = 0
function createTrailFrame(tag)
	num = 0
	color = -1
	image = ''
	frame = 'BF idle dance'
	x = 0
	y = 0
	scaleX = 0
	scaleY = 0
	offsetX = 0
	offsetY = 0
	flipX = false
	flipY = false
	antialiasing = false

	if colorDad == 'default' then
		colorDad = defaultColorDad
	end
	if colorBF == 'default' then
		colorBF = defaultColorBF
	end

	local bfOrder = getObjectOrder('boyfriendGroup')
	local dadOrder = getObjectOrder('dadGroup')
	if tag == 'BF' then
		num = curTrailBF
		curTrailBF = curTrailBF + 1
		if trailEnabledBF then
			setObjectOrder('psychicTrail', bfOrder)
			if isDefColorBF == false then
				color = getColorFromHex(colorBF)
			else	
				color = colorBF
			end
			image = getProperty('boyfriend.imageFile')
			frame = getProperty('boyfriend.animation.frameName')
			x = getProperty('boyfriend.x')
			y = getProperty('boyfriend.y')
			scaleX = getProperty('boyfriend.scale.x')
			scaleY = getProperty('boyfriend.scale.y') 
			offsetX = getProperty('boyfriend.offset.x')
			offsetY = getProperty('boyfriend.offset.y')
			flipX = getProperty('boyfriend.flipX')
			flipY = getProperty('boyfriend.flipY')
			antialiasing = getProperty('boyfriend.antialiasing')
		end
	elseif tag == 'Dad' then
		num = curTrailDad
		curTrailDad = curTrailDad + 1
		if trailEnabledDad then
			setObjectOrder('psychicTrail', dadOrder)
			if isDefColorDad == false then
				color = getColorFromHex(colorDad)
			else
				color = colorDad
			end
			image = getProperty('dad.imageFile')
			frame = getProperty('dad.animation.frameName')
			x = getProperty('dad.x')
			y = getProperty('dad.y')
			scaleX = getProperty('dad.scale.x')
			scaleY = getProperty('dad.scale.y')
			offsetX = getProperty('dad.offset.x')
			offsetY = getProperty('dad.offset.y')
			flipX = getProperty('dad.flipX')
			flipY = getProperty('dad.flipY')
			antialiasing = getProperty('dad.antialiasing')
		end
	end
	
	if num - trailLength + 1 >= 0 then
		for i = (num - trailLength + 1), (num - 1) do
			setProperty('psychicTrail' .. tag .. i .. '.alpha', getProperty('psychicTrail' .. tag .. i .. '.alpha') - (trailLength * 0.01))
		end
	end
	removeLuaSprite('psychicTrail' .. tag .. (num - trailLength))
	
	if not (image == '') then
		trailTag = 'psychicTrail' .. tag .. num
		makeAnimatedLuaSprite(trailTag, image, x, y)
		setProperty(trailTag .. '.offset.x', offsetX)
		setProperty(trailTag .. '.offset.y', offsetY)
		setProperty(trailTag .. '.scale.x', scaleX)
		setProperty(trailTag .. '.scale.y', scaleY)
		setProperty(trailTag .. '.flipX', flipX)
		setProperty(trailTag .. '.flipY', flipY)
		setProperty(trailTag .. '.antialiasing', antialiasing)
		setProperty(trailTag .. '.alpha', 0.3)
		setProperty(trailTag .. '.color', color)
		setObjectOrder(trailTag, (tag == 'BF' and bfOrder - 0.1 or tag == 'Dad' and dadOrder - 0.1))
		setBlendMode(trailTag, 'add')
		addAnimationByPrefix(trailTag, 'stuff', frame, 0, false)
		addLuaSprite(trailTag, false)
	end
end