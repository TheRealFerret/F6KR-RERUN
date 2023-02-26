--data/'song'/

function onCreate()
    --Sprites mods/characters
    setPropertyFromClass('GameOverSubstate', 'characterName', 'bf-model-dead')
    --Death sound mods/sounds
    setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'deathHit')
    --Dead music mods/music
    setPropertyFromClass('GameOverSubstate', 'loopSoundName', 'deathMusic')
    --Retry sound mods/music
    setPropertyFromClass('GameOverSubstate', 'endSoundName', 'deathPress')
end