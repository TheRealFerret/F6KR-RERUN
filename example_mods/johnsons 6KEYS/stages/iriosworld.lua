function onCreate()
	-- background shit
	makeLuaSprite('irio/lavaBACK', 'irio/lavaBACK', -1500, 800);
	setScrollFactor('irio/lavaBACK', 1.05, 1.05);
	scaleObject('irio/lavaBACK', 2.2, 2.2);

	makeLuaSprite('irio/STAGE', 'irio/STAGE', -700, 700);
	setScrollFactor('irio/STAGE', 1, 1);
	scaleObject('irio/STAGE', 1.7, 3);

	makeLuaSprite('irio/PLATFORMS', 'irio/PLATFORMS', -450, -400);
	setScrollFactor('irio/PLATFORMS', 0.9, 0.9);
	scaleObject('irio/PLATFORMS', 1.4, 1.4);

	makeAnimatedLuaSprite('lavaFRONT', 'lavaFRONT', -1600, 400)
	addAnimationByPrefix('lavaFRONT', 'fathog', 'fathog', 24, true)
	objectPlayAnimation('lavaFRONT', 'fathog', false)
	scaleObject('lavaFRONT', 2.2, 2.2);
	setScrollFactor('lavaFRONT', 1, 1);

	makeLuaSprite('irio/glowLAVA', 'irio/glowLAVA', -900, 700);
	setBlendMode('irio/glowLAVA', 'add')
	scaleObject('irio/glowLAVA', 1.6, 1.6);
	setScrollFactor('irio/glowLAVA', 1, 1);

	makeLuaSprite('irio/glowSTAGE', 'irio/glowSTAGE', -900, 600);
	setBlendMode('irio/glowSTAGE', 'add')
	scaleObject('irio/glowSTAGE', 1.6, 1.6);
	setScrollFactor('irio/glowSTAGE', 1, 1);


	addLuaSprite('irio/PLATFORMS', false);
	addLuaSprite('irio/lavaBACK', false);
	addLuaSprite('irio/STAGE', false);
	addLuaSprite('lavaFRONT', true);
	addLuaSprite('irio/glowSTAGE', true);
	addLuaSprite('irio/glowLAVA', true);
	
end


function onUpdate()
	if curBeat == 176 then
	   doTweenY('platformdeath', 'irio/PLATFORMS', getProperty('irio/PLATFORMS.y') - 100, 1, 'cubeOut')
	end

   end
   function onTweenCompleted(tag)
	   if tag == 'platformdeath' then
		   doTweenY('platformfall', 'irio/PLATFORMS', getProperty('irio/PLATFORMS.y') + 2000, 2, 'cubeIn')
		   doTweenAngle('platformspin', 'irio/PLATFORMS', 45, 5, 'cubeIn')
	   end
   end
