function onUpdate(elapsed)
-- This is how I do it
-- Alpha is +16
-- X is +0
-- Y is +8
-- Angle is +24

-- Opponent arrows: 0-5
-- Player arrows: 6-11
-- hide and show the opponents arrows
if opponentPlay then
    for i=11,6,-1 do
        noteTweenAlpha('note' .. i .. 'alphatween', i, 0, 0.001, 'linear')
    end
else
    for i=5,0,-1 do
        noteTweenAlpha('note' .. i .. 'alphatween', i, 0, 0.001, 'linear')
    end
end

end