function onCreate()
	-- background shit
	makeLuaSprite('ruinsback', 'ruinsback', -400, -100);
	setScrollFactor('ruinsback', 1, 1);
	-- sprites that only load if Low Quality is turned off

	addLuaSprite('ruinsback', false);
	
	close(true); --For performance reasons, close this script once the ruins is fully loaded, as this script won't be used anymore after loading the ruins
end