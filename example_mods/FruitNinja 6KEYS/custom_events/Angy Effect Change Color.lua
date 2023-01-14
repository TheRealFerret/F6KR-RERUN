function onEvent(name, value1, value2)
	if name == 'Angy Effect Change Color' then
        doTweenColor('angynesseffectcolor', 'angynesseffect', value1, 0.01, 'linear')
    end
end