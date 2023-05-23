random = 0
sustain = 0

images = {
	'spam/Spam01',
	'spam/Spam02',
	'spam/Spam03',
	'spam/Spam04',
	'spam/Spam05',
	'spam/Spam06',
	'spam/Spam07',
	'spam/Spam08',
	'spam/Spam09',
	'spam/Spam10',
	'spam/Spam11',
	'spam/Spam12',
	'spam/Spam13',
	'spam/Spam14',
	'spam/Spam15',
	'spam/Spam16',
	'spam/Spam17',
	'spam/Spam18',
	'spam/Spam19',
	'spam/Spam20',
}

function onCreate()
	--Iterate over all notes

	for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is an Instakill Note
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'spam' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'spam'); --Change texture

			--if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true); --Miss has no penalties
			--end
		end
	end
	--debugPrint('Script started!')
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	random = getRandomInt(0, #images)

	if noteType == 'spam' then
		if isSustainNote then
			sustain = sustain + 1
			if sustain == 1 then
				sustain = sustain - 1
				debugPrint(sustain)
				return Function_Stop
			end
		else
			makeLuaSprite('the image', images[random], math.random(100, 900), math.random(0, 500))
			setScrollFactor('the image', 0, 0);
			setObjectOrder('the image', getObjectOrder('boyfriendGroup') + 100)
			doTweenAlpha('image opacity', 'the image', 0, 0, 'linear')
			addLuaSprite('the image')
			setObjectCamera('the image', 'camOther', true);
			runTimer('image stuffs', 0.1, 1)
			playSound('bigshot', 1)
			playSound('BOOM', 0.3)
		end
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'image stuffs' then
		doTweenAlpha('image tweens', 'the image', 1, 0.1, 'linear')
		runTimer('image stuff', 1, 1)
	end 
	if tag == 'image stuff' then
		doTweenAlpha('image tweens', 'the image', 0, 1, 'linear')
	end
end

