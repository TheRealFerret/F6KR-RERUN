enabled = false

function onEvent(name, value1, value2)
	if name == '2P Effect' then
        enabled = not enabled
    end
end

function onBeatHit()
    if enabled then
        setProperty('overlayEffect.alpha', 0.5)
        doTweenAlpha('ColorSplitAlphaThing', 'overlayEffect', 0, 0.5, 'cubeOut')
        doTweenZoom('zoomhit', 'camGame', 0.9, 0.01, 'linear')
    else
        setProperty('overlayEffect.alpha', 0)
    end
end

function onTweenCompleted(tag)
    if tag == 'zoomhit' then
        doTweenZoom('zoomback', 'camGame', 0.8, 0.05, 'linear')
    end
end