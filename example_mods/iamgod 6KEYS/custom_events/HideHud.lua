function onEvent(name, value1)
	if name == 'HideHud' then
		setProperty('camHUD.visible', false);
		setProperty('camNotes.visible', false);
	end
end
