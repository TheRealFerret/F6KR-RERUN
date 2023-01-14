function onCreatePost()
	duration = getPropertyFromClass('Conductor', 'stepCrochet') * 2 / 1100
end

function onBeatHit() 
	doTweenY('jumpUp', 'iconP1', getProperty('iconP1.y') - 20, duration, 'cubeOut')
end

function onTweenCompleted(tag)
	if tag == 'jumpUp' then
		doTweenY('fallDown', 'iconP1', getProperty('iconP1.y') + 20, duration, 'cubeIn')
	end
end

function onUpdate(e)
	local angleOfs = math.random(-15, 15)
	if getProperty('healthBar.percent') < 20 then
		setProperty('iconP1.angle', angleOfs)
	else
		setProperty('iconP1.angle', 0)
	end
end