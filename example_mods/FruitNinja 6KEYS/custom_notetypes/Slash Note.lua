fruitpos = {}

fruittags = {}
animplaying = 0

fruitlist = {'Apple', 'Watermelon', 'Peach', 'Pear'}

twoplayer = false

function onCreate()

	if songName == 'Versus' then
		twoplayer = true
	end

	math.randomseed(score)

    for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is an Slash Note
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Slash Note' then

			pos = getPropertyFromGroup('unspawnNotes', i, 'strumTime')

			table.insert(fruitpos, pos - crochet)
		end
	end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'Slash Note' then

		triggerEvent('Play Animation', 'slash', 'BF')
		triggerEvent('Screen Shake', '0.15, 0.015', '')


		objectPlayAnimation(fruittags[1 + animplaying], 'slashed', true)
		runTimer('F_' .. fruittags[1 + animplaying], 0.2, 1)
		animplaying = animplaying + 1
		
	end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'Slash Note' then

		triggerEvent('Play Animation', 'slash', 'Dad')
		triggerEvent('Screen Shake', '0.15, 0.015', '')


		objectPlayAnimation(fruittags[1 + animplaying], 'slashed', true)
		runTimer('F_' .. fruittags[1 + animplaying], 0.2, 1)
		animplaying = animplaying + 1
		
	end
end

function onTimerCompleted(tag, loops, loopsleft)
	--If the timer tag starts with F_ then remove the sprite and remove it from fruittags
	if string.sub(tag, 1, 2) == 'F_' then
		f = string.sub(tag, 3, #tag)
		animplaying = animplaying - 1
		removeLuaSprite(f, true)
		table.remove(fruittags, 1)

	end
end

function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'Slash Note' then
		doTweenAlpha(fruittags[1 + animplaying] .. '_alpha', fruittags[1 + animplaying], 0, 0.2, 'linear')
		runTimer('F_' .. fruittags[1 + animplaying], 0.2, 1)
		animplaying = animplaying + 1
	end
end

function createFruit()
	if #fruittags == 0 then
		luatag = 'fruit_1'
	else
		luatag = 'fruit_' .. tonumber(mysplit(fruittags[#fruittags], '_')) + 1
	end
	
	fruitName = fruitlist[math.random(1,#fruitlist)]

	fruitxpos = 0
	if twoplayer then
		--two player spawn positions
		--fruitxpos = math.random(-250,250)
		fruitxpos = getRandomInt(-200,400)
	else
		fruitxpos = getRandomInt(-200,400)
	end

	makeAnimatedLuaSprite(luatag, fruitName, fruitxpos, 1300)

	addAnimationByPrefix(luatag, 'idle', fruitName .. '0000', 0, true)
	addAnimationByPrefix(luatag, 'slashed', fruitName .. ' slash', 30, false)

	scaleObject(luatag, 1.6, 1.6)

	addLuaSprite(luatag, true)
	objectPlayAnimation(luatag, 'idle', true)

	table.insert(fruittags, luatag)

	if twoplayer then
		doTweenY('F_' .. luatag, luatag, 600, 0.7, 'backOut')
	else
		doTweenY('F_' .. luatag, luatag, 400, 0.7, 'backOut')
	end
end

function onUpdate(elapsed)
	spos = getSongPosition()

	for i=#fruitpos,1,-1 do
		if spos >= fruitpos[i] then
			createFruit()
			table.remove(fruitpos, i)
		end
	end
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