function onCreate()
    makeLuaSprite('bg', 'bgstuffs/house', -600, -600)
    scaleObject('bg', 1.6, 1.6)
    --setScrollFactor('bg', 0.9, 0.9)

    addLuaSprite('bg', false)
end

function onUpdate()
    if string.lower(songName) == 'abuse' or string.lower(songName) == 'abuse gayremix' then
        setProperty('gf.visible', false)
    end
end