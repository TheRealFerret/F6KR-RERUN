function onEvent(name, value1, value2)
    if name == 'death' then
        setPropertyFromClass('GameOverSubstate', 'characterName', 'rewrite-gameover')
        setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'collect')
        setPropertyFromClass('GameOverSubstate', 'loopSoundName', 'gameOver')
        setPropertyFromClass('GameOverSubstate', 'endSoundName', 'confirmLaugh')
    end
end
