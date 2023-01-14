--Dynamic camera shit
camoffsetx = 0
camoffsety = 0
intensity = 15

function onUpdate()
	triggerEvent('Camera Follow Pos', 600 + camoffsetx, 600 + camoffsety)
	setProperty('cameraSpeed', 2)
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
	offsetCamera(noteData)
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
	offsetCamera(noteData)
end

function offsetCamera(direction)
	if direction == 0 then
		camoffsetx = -intensity
		camoffsety = 0

	elseif direction == 1 then
		camoffsetx = 0
		camoffsety = -intensity

	elseif direction == 2 then
		camoffsetx = intensity
		camoffsety = 0

	elseif direction == 3 then
		camoffsetx = -intensity
		camoffsety = 0

	elseif direction == 4 then
		camoffsetx = 0
		camoffsety = intensity

	elseif direction == 5 then
		camoffsetx = intensity
		camoffsety = 0
	end
end