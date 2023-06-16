-- og script by cyn
-- improved by stilic
--[[ setting stuffs ]]
following = true
local offsets = {dad = 26, boyfriend = 26}
local pivot_time = 1.4

function onUpdate()

    if curBeat >= 183 and curBeat <= 311 or curBeat >= 377 and curBeat <= 440 then



--[[ internal stuffs ]]
local anims = {singL = true, singD = false, singU = false, singR = true}
local singing = {dad = false, boyfriend = false}
local resetted_angle = false
local function reset_angle()
    if pivot_time > 0 and getProperty('camGame.angle') > 0 then
        doTweenAngle('follow_angle', 'camGame', 0, pivot_time, 'quadOut')
    end
end
local function follow(char, force_idle)
    if following and not getProperty('isCameraOnForcedPos') then
        resetted_angle = false
        local anim, offset = force_idle and 'idle' or
                                 getProperty(char .. '.animation.curAnim.name'):sub(
                                     1, 5), offsets[char]
        runHaxeCode('game.moveCamera(' .. tostring(char == 'dad') .. ');')
        if anims[anim] ~= nil then
            local pos_clone, horizontal = {
                getProperty('camFollow.x'), getProperty('camFollow.y')
            }, anims[anim]
            local dir_mult
            if horizontal then
                dir_mult = anim == 'singL' and -1 or 1
                pos_clone[1] = pos_clone[1] + offset * dir_mult
                if pivot_time > 0 then
                    doTweenAngle('follow_angle', 'camGame', 2.5 * -dir_mult,
                                 pivot_time, 'quadOut')
                end
            else
                dir_mult = anim == 'singU' and -1 or 1
                pos_clone[2] = pos_clone[2] + offset * dir_mult
                reset_angle()
            end
            setProperty('camFollow.x', pos_clone[1])
            setProperty('camFollow.y', pos_clone[2])
        else
            reset_angle()
        end
    elseif not resetted_angle then
        reset_angle()
        resetted_angle = true
    end
end
function onCreatePost() onSectionHit() end
function onSectionHit() follow(mustHitSection and 'boyfriend' or 'dad') end
local function check_idle(char)
    if singing[char] or getProperty(char .. '.animation.curAnim.name') ~= 'idle' then
        follow(char, true)
        singing[char] = false
    end
end
function onTimerCompleted(tag)
    if mustHitSection then
        if tag == 'follow_boyfriend_idle' then check_idle('boyfriend') end
    elseif tag == 'follow_dad_idle' then
        check_idle('dad')
    end
end
local function follow_note(note_type)
    if note_type ~= 'No Animation' then
        local char = mustHitSection and 'boyfriend' or 'dad'
        follow(char)
        singing[char] = true
        local pitch = getPropertyFromClass('flixel.FlxG', 'sound.music.pitch')
        runTimer('follow_' .. char .. '_idle',
                 stepCrochet *
                     (0.0011 / (type(pitch) == 'number' and pitch or 1)) *
                     getProperty(char .. '.singDuration') / 1.45)
    end
end
function goodNoteHit(id, direction, note_type, sustained) follow_note(note_type) end
function opponentNoteHit(id, direction, note_type, sustained)
    follow_note(note_type)
end
end
end