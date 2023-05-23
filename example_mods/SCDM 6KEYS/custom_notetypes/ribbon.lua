random = 0
sustain = 0



function onCreate()

	precacheImage('ribbonJumpscare')
	--Iterate over all notes

	for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is an Instakill Note
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'ribbon' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'ribbonAssets'); --Change texture

			--if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true); --Miss has no penalties
			--end
		end
	end
	--debugPrint('Script started!')
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	
	if noteType == 'ribbon' then
		makeAnimatedLuaSprite('ribbonJumpscare','ribbonJumpscare', 0, 0);
		addAnimationByPrefix('ribbonJumpscare','idle','ribbon idle', 24, false);--true or false to loop
		objectPlayAnimation('ribbonJumpscare','idle', true);
		setObjectCamera('ribbonJumpscare', 'camOther', true);
		playSound('RibbonSound', 1.5)
		addLuaSprite('ribbonJumpscare', true);
		runTimer('remove', 2, 2)
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'remove' then
		removeLuaSprite('ribbonJumpscare');
	end
end