function onCreate()
	-- background shit

	makeLuaSprite('stars','stars', -200, -100);
	scaleObject('stars', 2.7, 2.5);
	setProperty('stars.alpha', 0);
	setScrollFactor('stars', 0, 0);
	addLuaSprite('stars', false);

	makeLuaSprite('goofy_ahh','goofy_ahh', -400, -400);
	setScrollFactor('goofy_ahh', 0.3, 0.3);
	--addLuaSprite('goofy_ahh', false);


	makeLuaSprite('tree4','tree', -200, 100);
	scaleObject('tree4', 0.6, 0.6);
	setProperty('tree4.alpha', 0.5);
	setScrollFactor('tree4', 0.5, 0.5);
	addLuaSprite('tree4', false);

	makeLuaSprite('tree5','tree', 500, 100);
	scaleObject('tree5', 0.6, 0.6);
	setProperty('tree5.alpha', 0.5);
	setScrollFactor('tree5', 0.5, 0.5);
	addLuaSprite('tree5', false);

	makeLuaSprite('tree1','tree', -700, 50);
	scaleObject('tree1', 0.8, 0.8);
	setScrollFactor('tree1', 0.8, 0.8);
	addLuaSprite('tree1', false);

	makeLuaSprite('tree2','tree', 0, 50);
	scaleObject('tree2', -0.8, 0.8);
	setScrollFactor('tree2', 0.8, 0.8);
	addLuaSprite('tree2', false);

	makeLuaSprite('tree3','tree', 700, 50);
	scaleObject('tree3', 0.8, 0.8);
	setScrollFactor('tree3', 0.8, 0.8);
	addLuaSprite('tree3', false);

	makeLuaSprite('path','path', -700, -100);
	setScrollFactor('path', 1, 1);
	addLuaSprite('path', false);

	--couldn't get Queen's sprites to work, pls help :(
		--fdzfhhgfdhfghgfdhdgfjgfjfhgjfghjhjhfghdfsahf	U	HFIUHUSH	lkfj


	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end

