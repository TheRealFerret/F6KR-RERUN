local shaking = false;

function onCreate()
	if not hideHud or opponentPlay then
		setProperty('iconP2.x', -250)
		setProperty('iconP1.x', -250)
	end
	if not hideHud or not opponentPlay then
	makeAnimatedLuaSprite('icon3', nil, getProperty('iconP2.x'), getProperty('iconP2.y'))
	loadGraphic('icon3', 'icons/icon-'..getProperty('gf.healthIcon'), 150)
	addAnimation('icon3', 'icons/icon-'..getProperty('gf.healthIcon'), {0, 1}, 0, true)
	addAnimation('icon3', 'icons/icon-'..getProperty('gf.healthIcon'), {1, 0}, 0, true)
	addLuaSprite('icon3', true)
	setObjectOrder('icon3', getObjectOrder('iconP2') - 1)
	setObjectCamera('icon3', 'hud')

	makeLuaSprite('red', '', 0, 0);
	makeGraphic('red',1280,720,'ff0000')
	setProperty('red.scale.x',3)
	setProperty('red.scale.y',3)
	setObjectCamera('red', 'game');
	addLuaSprite('red', true);
	setProperty('red.visible', false);
	setObjectOrder('red', 3);

	makeLuaSprite('black', '', 0, 0);
	makeGraphic('black',1280,720,'000000')
	setProperty('black.scale.x',3)
	setProperty('black.scale.y',3)
	setObjectCamera('black', 'hud');
	addLuaSprite('black', false);
	doTweenAlpha('fadeb', 'black', 0, 0.1, 'linear')

	end
end
function onUpdatePost()
	if not hideHud or not opponentPlay then
	setProperty('icon3.y', getProperty('iconP2.y') - 50)
	setProperty('icon3.x', getProperty('iconP2.x') - 50)
	setProperty('icon3.scale.x', getProperty('iconP2.scale.x') - 0.15)
	setProperty('icon3.scale.y', getProperty('iconP2.scale.y') - 0.15)
	setObjectOrder('icon3', getObjectOrder('iconP2') + 1)
	setProperty('icon3.angle', getProperty('iconP2.angle'))
	end
	if getProperty('health') > 1.6 and not opponentPlay then
		setProperty('icon3.animation.curAnim.curFrame', '1')
	else
		setProperty('icon3.animation.curAnim.curFrame', '0')
	end
end
function onBeatHit()
	if curBeat >= 160 then
		setProperty('red.visible', true);
		setProperty('a.visible', false);
		setProperty('huggus.visible', false);
		setProperty('gf.visible', false);
		setProperty('boyfriend.color', getColorFromHex('000000'))
		setProperty('dad.color', getColorFromHex('000000'))
	end
	if curBeat >= 224 then
		setProperty('red.visible', false);
		setProperty('a.visible', true);
		setProperty('huggus.visible', true);
		setProperty('gf.visible', true);
		setProperty('boyfriend.color', getColorFromHex('ffffff'))
		setProperty('dad.color', getColorFromHex('ffffff'))
		shaking = true;
	end
	if curBeat >= 416 and not opponentPlay then
		shaking = false;
		doTweenAlpha('fadeb', 'black', 1, 0.7, 'linear')
		noteTweenAlpha("NoteFade", 0, 0, 0.45, linear)
		noteTweenAlpha("NoteFade2", 1, 0, 0.5, linear)
		noteTweenAlpha("NoteFade3", 2, 0, 0.55, linear)
		noteTweenAlpha("NoteFade4", 3, 0, 0.6, linear)
		noteTweenAlpha("NoteFade5", 4, 0, 0.65, linear)
		noteTweenAlpha("NoteFade6", 5, 0, 0.7, linear)
	end
	if curBeat >= 424 then
		doTweenAlpha('fadeb', 'black', 0, 0.5, 'linear')
	end
	if curBeat >= 488 then
		shaking = true;
	end
	if curBeat >= 612 then
		shaking = false;
	end
	if curBeat >= 632 then
		shaking = true;
	end
	if curBeat >= 680 then
		shaking = false;
		doTweenAlpha('fadeb', 'black', 1, 0.2, 'linear')
	end
end
function opponentNoteHit()

        health = getProperty('health')
        if getProperty('health') > 0.4 then
            setProperty('health', health- 0.02);
        end

		if shaking == true and not opponentPlay then
			triggerEvent('Screen Shake', '0.1, 0.003', '0.1, 0.002');
		end
end
function goodNoteHit()
	if shaking == true and opponentPlay then
		triggerEvent('Screen Shake', '0.1, 0.003', '0.1, 0.002');
	end
end