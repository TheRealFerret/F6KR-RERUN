function onEvent(name, value1, value2)
	if name == 'Background Fade' then
		duration = tonumber(value1);
		if duration < 0 then
			duration = 0;
		end

		targetAlpha = tonumber(value2);
		if duration == 0 then
			setProperty('Red.alpha', targetAlpha);
		else
			doTweenAlpha('BackgroundFadeEventTween', 'Red', targetAlpha, duration, 'linear');
		end
	end
end
