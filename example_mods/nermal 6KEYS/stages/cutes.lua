function onCreatePost()
	makeLuaSprite('bg','bgstuffs/cutes',-230,-240)
	addLuaSprite('bg',false)
	
	makeLuaSprite('sl','scanline',0,0)
	setObjectCamera('sl','other')
	scaleObject('sl',screenWidth/883,screenHeight/600)
	addLuaSprite('sl',true)
end