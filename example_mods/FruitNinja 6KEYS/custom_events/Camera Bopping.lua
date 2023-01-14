enabled = false
speed = 1

function onEvent(name, value1, value2)
	if name == 'Camera Bopping' then
        if tonumber(value1) == 2 then
            doTweenZoom('zoomBop', 'camGame', 0.9, 0.01, 'linear')
        else
            enabled = not enabled
        end
        speed = tonumber(value2)
    end
end

function onBeatHit()
    x = curBeat
    if enabled and curBeat % speed == 0 then
        doTweenZoom('zoomBop', 'camGame', 0.9, 0.01, 'linear')
    end
end

function onTweenCompleted(tag)
    if tag == 'zoomBop' then
        doTweenZoom('zoomUnbop', 'camGame', 0.8, 0.1, 'cubeOut')
    end
end