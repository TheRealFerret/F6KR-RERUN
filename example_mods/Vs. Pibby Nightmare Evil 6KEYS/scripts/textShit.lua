--Watermark Script by MasterDirector99
currentDifficulty = '';

function onCreate()

    makeLuaText('songText', songName .. ' - ' .. currentDifficulty .. " - Play Funkscop", 0, 2, 701);
    setTextAlignment('songText', 'left');
    setTextSize('songText', 15);
    setTextBorder('songText', 1, '000000');
    addLuaText('songText');
end

function onUpdate()
    setObjectCamera('songText', 'camOther')

    --currentDifficulty = getProperty('storyDifficultyText');
    --setTextString('songText', songName .. ' ' .. currentDifficulty .. " - PE bobbob - FNF");
    setTextString('songText', songName .. " - Vs Pibby Nightmare Evil");
end