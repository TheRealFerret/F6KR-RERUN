function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'jumpScareNote' then
			if string.lower(songName) == 'abuse' or string.lower(songName) == 'abuse gayremix' then
				setPropertyFromGroup('unspawnNotes', i, 'texture', 'notes/jumpscareNoteAsset2');
				setPropertyFromGroup('unspawnNotes', i, 'offsetY', -50)
			else
				setPropertyFromGroup('unspawnNotes', i, 'texture', 'notes/jumpscareNoteAsset1');
				setPropertyFromGroup('unspawnNotes', i, 'offsetX', -30)
			end
			
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true);
			end
		end
	end
end


function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'jumpScareNote' then
		setProperty('health',getProperty('health')-1)
		
		playSound('sonic.exe laugh', 10);
		makeLuaSprite('garf', 'garfieldjumpscare', 50, 0)
		scaleObject('garf', 1.8, 1)
		addLuaSprite('garf', true)
		setObjectCamera('garf', 'other')
		setProperty('garf.alpha', 1)

		--[[cameraShake('game', 0.10, 0.5);
        cameraShake('hud', 0.10, 0.5);
        cameraShake('other', 0.10, 0.5);]]

		--[[if getProperty('storyDifficultyText') == 'Gay' then
			cameraShake('game', 0.5, 0.1);
			cameraShake('hud', 0.5, 0.1);
		end]]
		
			runTimer('scary', 0.5);

		function onTimerCompleted(tag, l, ll)
			if tag == 'scary' then
				doTweenAlpha('garftween', 'garf', 0, 0.5, 'linear');
			end
		end
	end
end

function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'jumpScareNote' then
	end
end