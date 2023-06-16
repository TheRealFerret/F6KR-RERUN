function opponentNoteHit()
    if hellMode then
        health = getProperty('health')
        if getProperty('health') > 0.1 then
            setProperty('health', health- 0.1);
        end
    end
    if pussyMode == false and hellMode == false then
        health = getProperty('health')
        if getProperty('health') > 0.1 then
            setProperty('health', health- 0.02);
        end
    end
end