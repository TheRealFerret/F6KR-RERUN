
local bfturn = true
--nothing above this is useful --ash
local OpponentcamMovement = 45
local GFcamMovement = 35
local BFcamMovement = 25
--speeds
local bfcamspeed = 1.7
local opponentcamspeed = 2
local gfcamspeed = 2
--zooms
local opponentzoom = 1.1
local bfzoom = 1.1
local gfzoom = 1.1


function onMoveCamera(focus)
	if focus == 'boyfriend' then
	--setProperty('defaultCamZoom',bfzoom) --if you want zooming
	campointx = getProperty('camFollow.x')
	campointy = getProperty('camFollow.y')
	bfturn = true
	setProperty('cameraSpeed', 1)
	
	elseif focus == 'dad' then
	--setProperty('defaultCamZoom',opponentzoom) --if you want zooming
	campointx = getProperty('camFollow.x')
	campointy = getProperty('camFollow.y')
	bfturn = false
	setProperty('cameraSpeed', 1)

	elseif focus == 'gf' then
	--setProperty('defaultCamZoom',gfzoom) --if you want zooming
	campointx = getProperty('camFollow.x')
	campointy = getProperty('camFollow.y')
	bfturn = false
	setProperty('cameraSpeed', 1)
	
	end
end


function goodNoteHit(id, direction, noteType, isSustainNote)
	if bfturn then
		if direction == 0 then
			setProperty('camFollow.x', campointx - BFcamMovement)
		elseif direction == 1 then
			setProperty('camFollow.y', campointy - BFcamMovement)
		elseif direction == 2 then
			setProperty('camFollow.x', campointx + BFcamMovement)
		elseif direction == 3 then
			setProperty('camFollow.x', campointx - BFcamMovement)
		elseif direction == 4 then
			setProperty('camFollow.y', campointy + BFcamMovement)
		elseif direction == 5 then
			setProperty('camFollow.x', campointx + BFcamMovement)
		end
		setProperty('cameraSpeed', bfcamspeed)
	end	
end

		-- delete this if you dont want the oponent to move the camera
function opponentNoteHit(id, direction, noteType, isSustainNote)
	if not bfturn then
		if direction == 0 then
			setProperty('camFollow.x', campointx - OpponentcamMovement)
		elseif direction == 1 then
			setProperty('camFollow.y', campointy - OpponentcamMovement)
		elseif direction == 2 then
			setProperty('camFollow.x', campointx + OpponentcamMovement)
		elseif direction == 3 then
			setProperty('camFollow.x', campointx - OpponentcamMovement)
		elseif direction == 4 then
			setProperty('camFollow.y', campointy + OpponentcamMovement)
		elseif direction == 5 then
			setProperty('camFollow.x', campointx + OpponentcamMovement)
		end
		setProperty('cameraSpeed', opponentcamspeed)
	end	
	if not bfturn then
		if direction == 0 then
			setProperty('camFollow.x', campointx - GFcamMovement)
		elseif direction == 1 then
			setProperty('camFollow.y', campointy - GFcamMovement)
		elseif direction == 2 then
			setProperty('camFollow.x', campointx + GFcamMovement)
		elseif direction == 3 then
			setProperty('camFollow.x', campointx - GFcamMovement)
		elseif direction == 4 then
			setProperty('camFollow.y', campointy + GFcamMovement)
		elseif direction == 5 then
			setProperty('camFollow.x', campointx + GFcamMovement)
		end
		setProperty('cameraSpeed', gfcamspeed)
	end

end

	-- cringe camera EWW --
    -- script by Teniente Mantequilla#0139 --
	-- edited by ash