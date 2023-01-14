function onEvent(name, value1, value2)
	if name == 'Change Overlay Blend' then
        setBlendMode('overlayEffect', value1)
    end
end