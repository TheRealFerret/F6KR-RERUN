function onUpdate(elapsed)
-- This is how I do it
-- Alpha is +16
-- X is +0
-- Y is +8
-- Angle is +24

-- Opponent arrows: 0-3
-- Player arrows: 4-7
-- hide and show the opponents arrows
for i=5,0,-1 do
    noteTweenAlpha('note' .. i .. 'alphatween', i, 0, 0.001, 'linear')
end
end