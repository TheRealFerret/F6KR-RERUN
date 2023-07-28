local defaultNotePos = {};
local spin = false;
local arrowMoveX = 12;
local arrowMoveY = 12;
 
--cheeky modchart moment
function onSongStart()
    for i = 0,11 do 
        x = getPropertyFromGroup('strumLineNotes', i, 'x')
        y = getPropertyFromGroup('strumLineNotes', i, 'y')
        table.insert(defaultNotePos, {x,y})
    end
end
function onUpdate(elapsed)
    songPos = getPropertyFromClass('Conductor', 'songPosition');
    currentBeat = (songPos / 1000) * (bpm / 60)
    if spin == true then 
        for i = 0,11 do 
            setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + arrowMoveX * math.sin((currentBeat + i*0.25) * math.pi))
            setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2] + arrowMoveY * math.cos((currentBeat + i*0.25) * math.pi))
        end
    end

    if not pussyMode then
        if curStep == 60 then 
            spin = true
            arrowMoveX = 24
            arrowMoveY = 24
        end
        if curStep == 62 then 
            spin = false
        end
        if curStep == 64 then
            spin = true
            arrowMoveX = 12
            arrowMoveY = 12
        end
        if curStep == 576 then
            arrowMoveX = 6
            arrowMoveY = 6
        end
        if curStep == 704 then
            arrowMoveX = 12
            arrowMoveY = 12
        end
        if curStep == 960 then
            arrowMoveX = 6
            arrowMoveY = 6
        end
        if curStep == 992 then
            arrowMoveX = 12
            arrowMoveY = 12
        end
        if curStep == 1024 then
            arrowMoveX = 6
            arrowMoveY = 6
        end
        if curStep == 1056 then
            arrowMoveX = 12
            arrowMoveY = 12
        end
        if curStep == 1088 then
            arrowMoveX = 6
            arrowMoveY = 6
        end
        if curStep == 1120 then
            arrowMoveX = 12
            arrowMoveY = 12
        end
        if curStep == 1152 then
            arrowMoveX = 6
            arrowMoveY = 6
        end
        if curStep == 1184 then
            arrowMoveX = 12
            arrowMoveY = 12
        end
        if curStep == 1472 then
            arrowMoveX = 1
            arrowMoveY = 1
        end
    end
end