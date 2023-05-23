function onCreate()
	-- background shit

	makeAnimatedLuaSprite('ocean','ocean', -450, -200);
		addAnimationByPrefix('ocean','wobble','ocean wobble',15);
		setScrollFactor('ocean', 0.5, 0.3);
	addLuaSprite('ocean', false);

	makeLuaSprite('escuro', '', -1000, 0)
    makeGraphic('escuro', 4000, 2000, '000000')
    addLuaSprite('escuro', false);
	setProperty('escuro.alpha', 0);

	makeLuaSprite('escuro2', '', -1000, 0)
    makeGraphic('escuro2', 4000, 2000, '000000')
    addLuaSprite('escuro2', true);
	setProperty('escuro2.alpha', 0);

	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end

function onBeatHit()

	objectPlayAnim('ocean', 'wobble', false);

end
