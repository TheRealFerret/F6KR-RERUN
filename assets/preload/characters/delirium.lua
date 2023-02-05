function onCreate()

	makeAnimatedLuaSprite('wacky animated icon lol what the fuck not clickbait 3 am', 'isaac/void/deliriumicons', getProperty('iconP2'), getProperty('iconP2.y'))
	addAnimationByPrefix('wacky animated icon lol what the fuck not clickbait 3 am', 'idle', 'icon', 24, false)
	setObjectCamera('wacky animated icon lol what the fuck not clickbait 3 am', 'hud')
	addLuaSprite('wacky animated icon lol what the fuck not clickbait 3 am', true)
	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.alpha', 1)
end

function onUpdate(elapsed)

	setObjectOrder('wacky animated icon lol what the fuck not clickbait 3 am', getObjectOrder('iconP2') + 10)

	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.flipX', false)
	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.x', getProperty('iconP2.x') - 170)
	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.angle', getProperty('iconP2.angle'))
	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.y', getProperty('iconP2.y') - 125)
	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.scale.x', getProperty('iconP2.scale.x') * 0.3)
	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.scale.y', getProperty('iconP2.scale.y') * 0.3)

     objectPlayAnimation('wacky animated icon lol what the fuck not clickbait 3 am','idle');	

end

function onStepHit()
	if curStep == 1984 then
		setProperty('wacky animated icon lol what the fuck not clickbait 3 am.alpha', 0)
	end
end

function onGameOver()
	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.alpha', 0)
end