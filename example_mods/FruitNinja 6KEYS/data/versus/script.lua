cutscenetriggered = false
function onStartCountdown()

    setProperty('healthBar.alpha', 0)
    setProperty('iconP1.alpha', 0)
    setProperty('iconP2.alpha', 0)
    if cutscenetriggered then
        return Function_Continue
    else
        runTimer('startCutscene', 0.5)
        return Function_Stop
    end

end

function gfGoUp()
    doTweenY('girlfriendUp', 'dad', 320, 1.5, 'cubeOut')
    doTweenY('platformUp', 'gfplatform', 750, 1.5, 'cubeOut')
    playSound('gfGoUp')
end

function onTweenCompleted(tag)
    if tag == 'girlfriendUp' then
        makeAnimatedLuaSprite('animeSplit', 'AnimeSplit', 575, 0)
        addAnimationByPrefix('animeSplit', 'idle', 'AnimeSplit', 12)
        addLuaSprite('animeSplit')
        objectPlayAnimation('animeSplit', 'idle')

        triggerEvent('Screen Shake', '0.15, 0.015', '')
        playSound('epicAnimeSplit')

        runTimer('start', 0.25)
        doTweenAlpha('healthbarshow', 'healthBar', 1, 0.4, 'linear')
        doTweenAlpha('p1iconshow', 'iconP1', 1, 0.4, 'linear')
        doTweenAlpha('p2iconshow', 'iconP2', 1, 0.4, 'linear')
    end
end

function onTimerCompleted(tag, loops, loopsleft)
    if tag == 'start' then
        cutscenetriggered = true
        startCountdown()
    end

    if tag == 'startCutscene' then
        gfGoUp()
    end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
    hp = getProperty('health')
    
    if string.lower(difficultyName) == 'master' then
        if hp - 0.03 > 0 then
            setProperty('health', hp - 0.03)
        end
    else
        if hp - 0.02 > 0 then
            setProperty('health', hp * 0.99)
        end
    end
end