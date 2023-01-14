alive = true
miss = 0
function onCreate()
    setProperty('healthBar.alpha', 0)
    setProperty('iconP1.alpha', 0)
    setProperty('iconP2.alpha', 0)

    makeAnimatedLuaSprite('X1', 'fuckedX', 390, 530)
    setObjectCamera('X1', 'hud')
    scaleObject('X1', 0.35, 0.35)
    addAnimationByPrefix('X1', 'off', 'X off', 1, true)
    addAnimationByPrefix('X1', 'on', 'X on', 1, true)

    makeAnimatedLuaSprite('X2', 'fuckedX', 540, 500)
    setObjectCamera('X2', 'hud')
    scaleObject('X2', 0.45, 0.45)
    addAnimationByPrefix('X2', 'off', 'X off', 1, true)
    addAnimationByPrefix('X2', 'on', 'X on', 1, true)

    makeAnimatedLuaSprite('X3', 'fuckedX', 740, 530)
    setObjectCamera('X3', 'hud')
    scaleObject('X3', 0.35, 0.35)
    addAnimationByPrefix('X3', 'off', 'X off', 1, true)
    addAnimationByPrefix('X3', 'on', 'X on', 1, true)

    makeLuaSprite('pain', 'pain', -200, -100)
    setObjectCamera('pain', 'hud')
	scaleObject('pain', 0.7, 0.7)
	setScrollFactor('pain', 0, 0)

    setProperty('pain.alpha', 0)

    updateHitbox('X1')
    updateHitbox('X2')
    updateHitbox('X3')

    addLuaSprite('X1')
    addLuaSprite('X2')
    addLuaSprite('X3')

    addLuaSprite('pain')

    precacheSound('xMiss')
    precacheSound('threeXDeath')

    onBeatHit()
end

function onSongStart()
    onBeatHit()
end

function onUpdate(elapsed)
    if alive then
        setProperty('health', 1)
    else
        setProperty('health', 0)
    end
end

function noteMiss(id, direction, noteType, isSustainNote)
    miss = miss + 1
    playSound('xMiss')

    xUpdate()
end

function xUpdate()
    if miss == 1 then
        objectPlayAnimation('X1', 'on', true)
        objectPlayAnimation('X2', 'off', true)
        objectPlayAnimation('X3', 'off', true)
        setProperty('pain.alpha', 0.25)
    end
    if miss == 2 then
        objectPlayAnimation('X1', 'on', true)
        objectPlayAnimation('X2', 'on', true)
        objectPlayAnimation('X3', 'off', true)
        setProperty('pain.alpha', 0.75)
    end
    if miss == 3 then
        objectPlayAnimation('X1', 'on', true)
        objectPlayAnimation('X2', 'on', true)
        objectPlayAnimation('X3', 'on', true)
        setProperty('pain.alpha', 1)
        runTimer('goodbyeWorld', 0.1)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'goodbyeWorld' then
        playSound('threeXDeath')
        alive = false
    end
end

function onBeatHit()
    if curBeat % 2 == 0 then
        scaleObject('X1', 0.3, 0.3)
        scaleObject('X2', 0.4, 0.4)
        scaleObject('X3', 0.3, 0.3)

        doTweenY('X1Ytween', 'X1.scale', 0.35, 0.25, 'cubeOut')
        doTweenX('X1Xtween', 'X1.scale', 0.35, 0.25, 'cubeOut')

        doTweenY('X2Ytween', 'X2.scale', 0.45, 0.25, 'cubeOut')
        doTweenX('X2Xtween', 'X2.scale', 0.45, 0.25, 'cubeOut')

        doTweenY('X3Ytween', 'X3.scale', 0.35, 0.25, 'cubeOut')
        doTweenX('X3Xtween', 'X3.scale', 0.35, 0.25, 'cubeOut')
    end
end