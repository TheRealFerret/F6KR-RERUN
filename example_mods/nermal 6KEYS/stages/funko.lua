local playerStrumPos = {300,428,732,860}

function onCreatePost()
	makeLuaSprite('g','garffunko',-230,-240)
	scaleObject('g',1.5,1.5)
	addLuaSprite('g',true)
	triggerEvent('Camera Follow Pos','0','0')
	
	for i = 4,7 do 
		setPropertyFromGroup('strumLineNotes', i, 'x', playerStrumPos[i - 3])
	end
	
	for i = 0,3 do 
		setPropertyFromGroup('strumLineNotes', i, 'x', -198769420)
	end
end

function onUpdate()
    setProperty('gf.visible', false)
    setProperty('boyfriend.visible', false)
	setProperty('dad.visible', false)
	setProperty('health',2)
	setProperty('healthBar.visible', false)
	setProperty('healthBarBG.visible', false)
	setProperty('scoreTxt.visible', false)
	setProperty('timeBar.visible', false)
	setProperty('timeBarBG.visible', false)
	setProperty('timeTxt.visible', false)
	setProperty('iconP1.visible', false)
	setProperty('iconP2.visible', false)
end