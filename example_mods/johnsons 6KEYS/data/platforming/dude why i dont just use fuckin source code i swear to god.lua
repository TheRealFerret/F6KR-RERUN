function onCreate()
    makeLuaSprite('IrioDeath','IrioDeath', 600, 500);
    setScrollFactor('IrioDeath', 1, 1);
	scaleObject('IrioDeath', 20, 20);

	addLuaSprite('IrioDeath', false);
    setProperty('IrioDeath.alpha', 0)

  function onUpdate()
     if curBeat == 441 then
        setProperty('dad.alpha', 0)
        setProperty('IrioDeath.alpha', 1)
        doTweenY('fuck', 'IrioDeath', getProperty('boyfriend.y') - 200, 1, 'cubeOut')
        noteTweenY("bye1", 0, 50, 1, 'cubeOut')
        noteTweenY("bye2", 1, 50, 1, 'cubeOut')
        noteTweenY("bye3", 2, 50, 1, 'cubeOut')
        noteTweenY("bye4", 3, 50, 1, 'cubeOut')
        noteTweenY("bye5", 4, 50, 1, 'cubeOut')
        noteTweenY("bye6", 5, 50, 1, 'cubeOut')
     end

    end
    function onTweenCompleted(tag)
        if tag == 'fuck' then
            doTweenY('lavafail', 'IrioDeath', getProperty('boyfriend.y') + 1000, 2, 'cubeIn')
            doTweenAngle('lavaspin', 'IrioDeath', 45, 2, 'cubeIn')
            noteTweenY("bye7", 0, 1000, 2, 'cubeIn')
            noteTweenY("bye8", 1, 1000, 2.3, 'cubeIn')
            noteTweenY("bye9", 2, 1000, 1.8, 'cubeIn')
            noteTweenY("bye10", 3, 1000, 2.1, 'cubeIn')
            noteTweenY("bye11", 4, 1000, 1.9, 'cubeIn')
            noteTweenY("bye12", 5, 1000, 2.2, 'cubeIn')
        end
    end

end