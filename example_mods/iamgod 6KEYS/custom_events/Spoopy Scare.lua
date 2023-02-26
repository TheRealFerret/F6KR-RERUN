function onCreate()
	makeAnimatedLuaSprite('jumpscare','jumpscare',50,100)
	addAnimationByPrefix('jumpscare','jumpscare','jumpscare',24,false)
	setScrollFactor('jumpscare', 0, 0);
	setObjectCamera('jumpscare', 'other');
	setProperty('jumpscare.visible',false)
	addLuaSprite('jumpscare',true)
end

function onEvent(name)
    if name == "Spoopy Scare" then
	
	objectPlayAnimation('jumpscare', 'jumpscare', true)
	setProperty('jumpscare.visible',true)

	runTimer('aaaaadies', 1.2);

	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'aaaaadies' then
		setProperty('jumpscare.visible',false)
	end
end