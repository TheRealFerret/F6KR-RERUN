function onCreate()

	makeAnimatedLuaSprite('wacky animated icon lol what the fuck not clickbait 3 am', 'icons/NEW_ABOMINATION_HYPNO_ICON', getProperty('iconP1x'), getProperty('iconP1.y'))
	addAnimationByPrefix('wacky animated icon lol what the fuck not clickbait 3 am', 'idle', 'ABOMINATION HYPNO ICON instance 1', 24, false)
	setObjectCamera('wacky animated icon lol what the fuck not clickbait 3 am', 'hud')
	addLuaSprite('wacky animated icon lol what the fuck not clickbait 3 am', true)
	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.alpha', 0)
end

function onUpdate(elapsed)

	setObjectOrder('wacky animated icon lol what the fuck not clickbait 3 am', getObjectOrder('iconP1') + 10)

	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.flipX', false)
	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.x', getProperty('iconP1.x') - 100)
	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.angle', getProperty('iconP1.angle'))
	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.y', getProperty('iconP1.y') - 150)
	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.scale.x', getProperty('iconP1.scale.x') * 0.4)
	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.scale.y', getProperty('iconP1.scale.y') * 0.4)

        objectPlayAnimation('wacky animated icon lol what the fuck not clickbait 3 am','idle');	

end

function onStepHit()
	if curStep == 306 then
		setProperty('wacky animated icon lol what the fuck not clickbait 3 am.alpha', 1)
	end
end

function onGameOver()
	setProperty('wacky animated icon lol what the fuck not clickbait 3 am.alpha', 0)
end