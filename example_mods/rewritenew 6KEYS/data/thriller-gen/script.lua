function onUpdate(elapsed)
-- This is how I do it
-- Alpha is +16
-- X is +0
-- Y is +8
-- Angle is +24

-- Opponent arrows: 0-5
-- Player arrows: 6-11
-- hide and show the opponents arrows
for i=0,5 do
-- Alpha is 0 (0 being invisible)
noteTweenAlpha(i+16, i, math.floor(curStep/9999), 0.3)
noteTweenAlpha(i+16, i, math.floor(curStep/9999), 4-7)
end
end


