function onCreate()
	-- background shit

	makeLuaSprite('neobg','neobg', -420, -160);
	setScrollFactor('neobg', 0.2, 1);
	addLuaSprite('neobg', false);

	makeLuaSprite('neo_amongus','neo_amongus', -1100, -100);
	setScrollFactor('neo_amongus', 0.1, 0.8);
	addLuaSprite('neo_amongus', false);

	makeLuaSprite('neo_amongus2','neo_amongus', -1100-2191, -100);
	setScrollFactor('neo_amongus2', 0.1, 0.8);
	addLuaSprite('neo_amongus2', false);

	makeLuaSprite('neo_city','neo_city', -1200, -170);
	setScrollFactor('neo_city', 0.2, 1);
	addLuaSprite('neo_city', false);

	makeLuaSprite('neo_city2','neo_city', -1200-2191, -170);
	setScrollFactor('neo_city2', 0.2, 1);
	addLuaSprite('neo_city2', false);



	makeLuaSprite('TUNNELTCHOOTCHOO', '', -1000, 0)
	makeGraphic('TUNNELTCHOOTCHOO', 4000, 2000, '000000')
	addLuaSprite('TUNNELTCHOOTCHOO',false)





	makeAnimatedLuaSprite('rail3','rail', -410, 570);
		addAnimationByPrefix('rail3','move','rail',24);
	addLuaSprite('rail3', false);
	scaleObject('rail3', 1.25, 0.6);

	makeAnimatedLuaSprite('rail2','rail', -410, 610);
		addAnimationByPrefix('rail2','move','rail',24);
	addLuaSprite('rail2', false);
	scaleObject('rail2', 1.25, 0.7);

	makeAnimatedLuaSprite('rail1','rail', -410, 666);
		addAnimationByPrefix('rail1','move','rail',24);
	addLuaSprite('rail1', false);
	scaleObject('rail1', 1.25, 0.8);

	makeLuaSprite('dangle','dangle', -730, -150);
	setScrollFactor('dangle', 1, 1);
	addLuaSprite('dangle', false);


	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end


function onBeatHit()
	objectPlayAnim('rail1', 'move', true);

end
