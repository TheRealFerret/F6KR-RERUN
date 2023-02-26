function onEvent(name, value1, value2)
    if name == 'Image Flash Instant' then
        makeLuaSprite('imagei', value1, 0, 0);
        addLuaSprite('imagei', true);
        scaleObject('imagei', 0.5, 0.52);
        doTweenColor('helloi', 'image', 'FFFFFFFF', 0.1, 'quartIn');
        setObjectCamera('imagei', 'other');
        runTimer('waiti', value2);
        
        function onTimerCompleted(tag, loops, loopsleft)
            if tag == 'waiti' then
                setProperty('image.alpha', 0);
                removeLuaSprite('imagei', true);
            end
        end
    end
end
