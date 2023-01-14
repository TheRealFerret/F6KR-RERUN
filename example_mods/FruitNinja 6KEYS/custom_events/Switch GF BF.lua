
curPlayer = 0

function onEvent(name, value1, value2)
    if name == 'Switch GF BF' then
        if curPlayer == 0 then
            curPlayer = 1
        else
            curPlayer = 0
        end
    end
end

function onUpdate(elapsed)
    if curPlayer == 1 then
        characterPlayAnim('bf', 'coma', true)
        setProperty('gf.specialAnim', true)
    else
        setProperty('gf.specialAnim', false)
    end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if curPlayer == 1 then
        if id == 0 then
            characterPlayAnim('gf', 'singLEFT', true)
        elseif id == 1 then
            characterPlayAnim('gf', 'singDOWN', true)
        elseif id == 2 then
            characterPlayAnim('gf', 'singUP', true)
        elseif id == 3 then
            characterPlayAnim('gf', 'singRIGHT', true)
        end
    end
end