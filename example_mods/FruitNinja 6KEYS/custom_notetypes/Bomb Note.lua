bombpos = {}
bombtags = {}
function onCreate()
	
	math.randomseed(score)

	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Bomb Note' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'BombNote') --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'hitHealth', '-500') --Default value is: 0.023, health gained on hit
			setPropertyFromGroup('unspawnNotes', i, 'missHealth', '500') --Default value is: 0.0475, health lost on miss
			setPropertyFromGroup('unspawnNotes', i, 'hitCausesMiss', true)

			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true) --Miss has no penalties
			end
			--bomb shit
			pos = getPropertyFromGroup('unspawnNotes', i, 'strumTime')
			table.insert(bombpos, pos - crochet * 2)
		end
	end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'Bomb Note' then
		--bruh
	end
end

function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'Bomb Note' then
		playSound('bomb')
	end
end

function onUpdate(elapsed)
	spos = getSongPosition()

	for i=#bombpos,1,-1 do
		if spos >= bombpos[i] then
			createBomb()
			table.remove(bombpos, i)
		end
	end
end

function createBomb()

	if #bombtags == 0 then
		luatag = 'bomb_1'
	else
		luatag = 'bomb_' .. tonumber(mysplit(bombtags[#bombtags], '_')) + 1
	end

	makeAnimatedLuaSprite(luatag, 'Bomb', getRandomInt(-200,400), 1300)

	addAnimationByPrefix(luatag, 'idle', 'Bomb', 24, true)
	scaleObject(luatag, 1.6, 1.6)

	addLuaSprite(luatag, true)
	objectPlayAnimation(luatag, 'idle', true)

	table.insert(bombtags, luatag)

	doTweenY('b_' .. luatag, luatag, 400, 0.5, 'expoOut')
end

function mysplit (inputstr, sep)
	if sep == nil then
	   sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
	   table.insert(t, str)
	end
	return t[#t]
end

function onTweenCompleted(tag)
	if string.sub(tag, 1, 2) == 'b_' then
		thing = string.sub(tag, 3, -1)
		doTweenY('b2_' .. thing, thing, 1300, 0.5, 'expoIn')
	end

	if string.sub(tag, 1, 3) == 'b2_' then
		thing = string.sub(tag, 4, -1)
		removeLuaSprite(thing, true)
		table.remove(bombtags, 1)
	end
end