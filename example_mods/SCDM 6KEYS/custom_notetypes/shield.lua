function onCreate()
	--Iterate over all notes

	for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is an Instakill Note
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'shield' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'shield_note'); --Change texture

			--if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false); --Miss has no penalties
			--end
		end
	end
	--debugPrint('Script started!')
end

-- Function called when you hit a note (after note hit calculations)
-- id: The note member id, you can get whatever variable you want from this note, example: "getPropertyFromGroup('notes', id, 'strumTime')"
-- noteData: 0 = Left, 1 = Down, 2 = Up, 3 = Right
-- noteType: The note type string/tag
-- isSustainNote: If it's a hold note, can be either true or false

function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'shield' then
		playSound('hurt', 1);
		setProperty('health',getProperty('health')-0.5);
		triggerEvent('Screen Shake','1.5,0.01','1.8,0.02');
	end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'shield' then
		playSound('defend', 0.46);
		triggerEvent('Add Camera Zoom','0.2', '0.02');
		characterPlayAnim('boyfriend', 'singRIGHT', true);
	end
end
