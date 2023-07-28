local xx2 = 0
local yy2 = 0
local ofs = 45
local x = {}; local y = {}

function onCreatePost()
    addCharacterToList('hxfriendALT', 'dad'); setProperty('iconP2.alpha', 0)

    makeLuaSprite('error', 'error', screenWidth/2, screenHeight/2); setProperty('error.alpha', 0)
    setObjectCamera('error', 'camHud')
    addLuaSprite('error', true)

    setProperty('error.x', getProperty('error.x') - getProperty('error.width')/2)
    setProperty('error.y', getProperty('error.y') - getProperty('error.height')/2)
end

function onStartCountdown()
    setProperty('boyfriend.alpha', 0)
    setProperty('dad.alpha', 0)
	return Function_Continue
end


function onUpdate(elapsed)
    if 1 == 1 then
        if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
          triggerEvent('Camera Follow Pos',xx2-ofs,yy2)
        end
        if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
          triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
        end
        if getProperty('dad.animation.curAnim.name') == 'singUP' then
          triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
        end
        if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
          triggerEvent('Camera Follow Pos',xx2,yy2+0)
        end
        if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
          triggerEvent('Camera Follow Pos',xx2,yy2)
        end
        if getProperty('dad.animation.curAnim.name') == 'idle' then
          triggerEvent('Camera Follow Pos',xx2,yy2)
        end
  else
      triggerEvent('Camera Follow Pos','','')
  end
end

function onStepHit()
    if curStep == 113 then
      doTweenX('errorDis1', 'error.scale', 0, 1.3, 'circInOut'); doTweenY('errorDis2', 'error.scale', 0, 1.2, 'linear'); doTweenAlpha('errorDis3', 'error', 0, 1.3, 'circInOut')
      doTweenAlpha('GFappear1', 'dad', 1, 2.2, 'linear'); doTweenAlpha('GFappear2', 'iconP2', 1, 2.2, 'linear')
    end
    if curStep == 767 or curStep == 1743 or curStep == 1840 then
        triggerEvent('Change Character', 1, 'hxfriendALT')
    end
    if curStep == 896 or curStep == 1808 or curStep == 1871 then
        triggerEvent('Change Character', 1, 'hxfriend')
        --triggerEvent('Play Animation', 'scream', 1)
    end
end

function onSongStart()
    setProperty('error.alpha', 1)
    for i = 0,7 do
        local xA = getPropertyFromGroup('strumLineNotes', i, 'x')
        local yB = getPropertyFromGroup('strumLineNotes', i, 'y')
        x[i] = xA
        y[i] = yB
    end
end