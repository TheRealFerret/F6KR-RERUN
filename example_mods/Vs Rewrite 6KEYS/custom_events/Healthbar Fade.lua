function onEvent(name, value1, value2)
	if name == 'Healthbar Fade' then
		duration = tonumber(value1);
		if duration < 0 then
			duration = 0;
		end

		targetAlpha = tonumber(value2);
		if duration == 0 then
			setProperty('healthBar.alpha', targetAlpha);
			setProperty('iconP1.alpha', targetAlpha);
			setProperty('iconP2.alpha', targetAlpha);
		else
			doTweenAlpha('healthBarFadeEventTween', 'healthBar', targetAlpha, duration, 'linear');
			doTweenAlpha('iconP1FadeEventTween', 'iconP1', targetAlpha, duration, 'linear');
			doTweenAlpha('iconP2FadeEventTween', 'iconP2', targetAlpha, duration, 'linear');
		end
		--debugPrint('Event triggered: ', name, duration, targetAlpha);
	end
end