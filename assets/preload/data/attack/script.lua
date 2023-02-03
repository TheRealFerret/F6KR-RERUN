function opponentNoteHit()
    if pussyMode == false then
        health = getProperty('health')
        if getProperty('health') > 0.1 then
            setProperty('health', health- 0.02);
        end
    end
end