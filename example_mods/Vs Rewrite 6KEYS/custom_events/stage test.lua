function onCreate()
	makeAnimatedLuaSprite('Red','Red', -90,-90)
	addAnimationByPrefix('Red','Red idle','Red idle',24,true)
	setLuaSpriteScrollFactor('Red', 0.5, 0.5)
end

function onEvent(name, value1, value2)
	if name == 'stage test' then
		addLuaSprite('Red',false)
	end
end
