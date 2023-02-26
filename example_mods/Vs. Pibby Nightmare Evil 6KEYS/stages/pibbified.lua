local barScale = 1
local timebarScale = 1
function onCreate()
	-- background shit
	
	makeLuaSprite('bg', 'pibbified/awesomebg', -360, -190);
	addLuaSprite('bg', false);
	scaleObject('bg', 1.35, 1.35);
	
	makeAnimatedLuaSprite('a', 'pibbified/bgevil', 1500, 730);
	addAnimationByPrefix('a', 'bop', 'bg bopper', 24, true);
	objectPlayAnimation('a', 'bop', true)
	addLuaSprite('a', true);
	
	makeAnimatedLuaSprite('pibby', 'pibbified/pibbyshade', 1000, 620);
	addAnimationByPrefix('pibby', 'bop', 'pibby idle', 24, true);
	objectPlayAnimation('pibby', 'bop', true)
	addLuaSprite('pibby', false);

	makeLuaSprite('huggus', 'pibbified/bro_is_dead', -360, -300);
	addLuaSprite('huggus', true);
	scaleObject('huggus', 1.35, 1.35);
	setScrollFactor('huggus', 0.9, 0.85);


end

function onUpdatePost()
		timebarScale = timebarScale + (2.7 - timebarScale) * 0.1

		setProperty('timeBarBG.scale.x', timebarScale)
		setProperty('timeBar.scale.x', timebarScale)


	
		updateHitbox('timeBarBG')
		updateHitbox('timeBar')

	setProperty('timeBarBG.x', (screenWidth * 0.5) - (getProperty('timeBarBG.width') * 0.5))
	setProperty('timeBar.x', (screenWidth * 0.5) - (getProperty('timeBar.width') * 0.5))

		barScale = barScale + (1.65 - barScale) * 0.065
		
		setProperty('healthBarBG.scale.x', barScale)
		setProperty('healthBar.scale.x', barScale)
	
		updateHitbox('healthBarBG')
		updateHitbox('healthBar')
	
	setProperty('healthBarBG.x', (screenWidth * 0.5) - (getProperty('healthBarBG.width') * 0.5))
	setProperty('healthBar.x', (screenWidth * 0.5) - (getProperty('healthBar.width') * 0.5))

end

function onBeatHit()
	if curBeat % 2 == 0 then
			objectPlayAnimation('a', 'bop', true)
			objectPlayAnimation('pibby', 'bop', true)
	end
end
