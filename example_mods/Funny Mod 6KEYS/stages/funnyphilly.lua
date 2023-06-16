function onCreate()
	--background boi
	makeLuaSprite('stage', 'phillyfunnybg', -400, -100)
	setLuaSpriteScrollFactor('stage', 1, 1)
	addLuaSprite('stage', false)

	makeLuaSprite( 'stage2', 'wallbg', -400, -100)
	setLuaSpriteScrollFactor('stage2', 1, 1)
	addLuaSprite('stage2', false)

	makeLuaSprite( 'stage3', 'black', -400, -100)
	setLuaSpriteScrollFactor('stage3', 1, 1)
	addLuaSprite('stage3', false)

	makeLuaSprite( 'stage4', 'trollbg', -400, -100)
	setLuaSpriteScrollFactor('stage4', 1, 1)
	addLuaSprite('stage4', false)

	setProperty('stage2.visible', false)
	setProperty('stage3.visible', false)
	setProperty('stage4.visible', false)
end

function onEvent(name,value1,value2)
	if name == 'Play Animation' then 
		
		if value1 == '2' then
			setProperty('stage.visible', false);
			setProperty('stage2.visible', true);
			setProperty('stage3.visible', false);
			setProperty('stage4.visible', false);
		end

		if value1 == '3' then
			setProperty('stage3.visible', true);
			setProperty('stage.visible', false);
			setProperty('stage2.visible', false);
			setProperty('stage4.visible', false);
		end

		if value1 == '4' then
			setProperty('stage2.visible', false);
			setProperty('stage.visible', false);
			setProperty('stage3.visible', false);
			setProperty('stage4.visible', true)
		end
		
		if value1 == '1' then
			setProperty('stage2.visible', false);
			setProperty('stage.visible', true);
			setProperty('stage3.visible', false);
			setProperty('stage4.visible', false);
		end
	end
end