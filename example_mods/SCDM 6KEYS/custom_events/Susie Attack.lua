function onUpdate()

	health = getProperty('health');

end

function onEvent(name, value1, value2)
	if name == "Susie Attack" then
		playSound('defend', 0.55);
		triggerEvent('Screen Shake', '0.7, 0.003', '0.8, 0.0025');

        if getProperty('health') > value1 + 0.1 then
            setProperty('health', health- value1);
        end
    end
end