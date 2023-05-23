function opponentNoteHit()
    if not opponentPlay then
        triggerEvent('Screen Shake','1,0.006')
    end
end
function goodNoteHit()
    if opponentPlay then
        triggerEvent('Screen Shake','1,0.006')
    end
end