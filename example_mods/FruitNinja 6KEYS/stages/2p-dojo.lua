function onCreate()

	addLuaScript('add_scripts/camera/noteMovement')
	
	-- background shit
	makeLuaSprite('bfplatform', 'platform', 800, 700)
	scaleObject('bfplatform', 0.5, 0.5)

	makeLuaSprite('gfplatform', 'gfplatform', -300, 2450)
	scaleObject('gfplatform', 0.6, 0.5)

	makeLuaSprite('dojobg', 'dojobg', -700, 0)

	makeLuaSprite('angynesseffect', 'angyness_effect', -200, -100)
	scaleObject('angynesseffect', 0.7, 0.7)
	setScrollFactor('angynesseffect', 0, 0)
	setBlendMode('angynesseffect', 'DARKEN')

	makeLuaSprite('overlayEffect', 'overlays/Split', -200, -100)
	scaleObject('overlayEffect', 0.7, 0.7)
	setScrollFactor('overlayEffect', 0, 0)
	setBlendMode('overlayEffect', 'OVERLAY')

	if not lowQuality then
		makeLuaSprite('vignette', 'vignette', -200, -100)
		scaleObject('vignette', 0.7, 0.7)
		setScrollFactor('vignette', 0, 0)
		setBlendMode('vignette', 'OVERLAY')
	end

	addLuaSprite('dojobg', false)
	addLuaSprite('bfplatform', false)
	addLuaSprite('gfplatform', false)
	addLuaSprite('angynesseffect', true)
	addLuaSprite('overlayEffect', true)

	addLuaSprite('vignette', true)

	setProperty('angynesseffect.alpha', 0)
	setProperty('overlayEffect.alpha', 0)
	
	precacheImage('Apple')
	precacheImage('Watermelon')
	precacheImage('Pear')
	precacheImage('Peach')
	precacheImage('AnimeSplit')
	precacheImage('overlays/Red')
	precacheImage('overlays/Split')
	precacheImage('overlays/Erect')
	precacheSound('epicAnimeSplit')
	precacheSound('gfGoUp')
	precacheImage('characters/GF_Katana')
end