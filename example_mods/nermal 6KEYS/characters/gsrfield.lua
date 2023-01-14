function onCreate()
	setProperty('gf.visible', false)
	
	makeLuaSprite('iconGSR','icon-gsrfield',700,getProperty('iconP1.y')-75)
	setObjectCamera('iconGSR','hud')
end

function onEvent(name,v1,v2)
	if v1 == "intro" then
		setProperty('gf.visible', true)
		addLuaSprite('iconGSR',true)
	end
end

function onUpdate()
	setProperty('iconGSR.x',getProperty('iconP1.x')+75)
end