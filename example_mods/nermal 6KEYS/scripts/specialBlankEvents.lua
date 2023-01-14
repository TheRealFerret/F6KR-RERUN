function onCreate()
	precacheImage('killbf')
end

function onEvent(name,v1,v2)
	if name == '' then
		if v1 == 'death' then
			makeAnimatedLuaSprite('shootBf','killbf',660,420)
			addAnimationByPrefix('shootBf','shot','BF hit',24,false)
			objectPlayAnimation('shootBf','shot')
			addLuaSprite('shootBf');
			setProperty('boyfriend.visible',false)
		end
	end
end