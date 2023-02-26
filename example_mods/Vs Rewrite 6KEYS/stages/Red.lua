function onCreate()
	-- background
	
	makeAnimatedLuaSprite('Red','Red', 0,0)
	addAnimationByPrefix('Red','Red idle','Red idle',24,true)
	setLuaSpriteScrollFactor('Red', 0.5, 0.5)
	addLuaSprite('Red',false)

	close(true);
end