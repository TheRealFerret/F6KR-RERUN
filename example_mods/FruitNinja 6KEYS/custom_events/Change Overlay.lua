function onEvent(name, value1, value2)
	if name == 'Change Overlay' then
        loadGraphic('overlayEffect', 'overlays/' .. value1)
    end
end