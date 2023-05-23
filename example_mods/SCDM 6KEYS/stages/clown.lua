function onCreate()
	-- background shit
	
	makeLuaSprite('boinger', 'boinger', -500, -650);
	setScrollFactor('boinger', 0.6, 0.6);
	scaleObject('boinger', 0.8, 0.8);
	addLuaSprite('boinger');


	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end