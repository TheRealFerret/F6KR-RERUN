function onEvent(name, value1, value2)
    if name == 'GF Dance Speed' then
        v1 = tonumber(value1)
        setProperty('dad.danceEveryNumBeats', v1)
    end
end