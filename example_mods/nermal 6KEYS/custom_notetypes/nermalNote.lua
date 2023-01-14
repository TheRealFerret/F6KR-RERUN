function onCreate()
    --Iterate over all notes
    for i = 0, getProperty('unspawnNotes.length')-1 do
        --Check if the note is a Nermal Note
        if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'nermalNote' then

            --changes texture based on song
            if dadName == 'garfield' then
                setPropertyFromGroup('unspawnNotes', i, 'texture', 'notes/GARFNOTES'); --Change texture
            else
                setPropertyFromGroup('unspawnNotes', i, 'texture', 'notes/nermalnote'); --Change texture
            end

            if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
                setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true); --Miss has no penalties
            end
        end
    end
    
    --makes the sprite
    makeLuaSprite('nerm1', 'nermal jumpscare', -400, 500)
    scaleObject('nerm1', 2, 0.5)
    setObjectCamera('nerm1', 'other')

    makeLuaSprite('nerm2', 'nermal jumpscare', -400, -570)
    scaleObject('nerm2', 2, 0.5 * -1) --same image just flipped upside down bc of y value * -1
    setObjectCamera('nerm2', 'other')

    makeLuaSprite('garf1', 'garfield note jumpscare', -400, 500)
    scaleObject('garf1', 2, 0.5)
    setObjectCamera('garf1', 'other')
    
    makeLuaSprite('garf2', 'garfield note jumpscare', -400, -570)
    scaleObject('garf2', 2, 0.5 * -1)
    setObjectCamera('garf2', 'other')

    if dadName == 'garfield' then --makes camera shake
        addLuaSprite('garf1', true)
        setProperty('garf1.alpha', 0)
        addLuaSprite('garf2', true)
        setProperty('garf2.alpha', 0)
    else
        addLuaSprite('nerm1', true)
        setProperty('nerm1.alpha', 0)
        addLuaSprite('nerm2', true)
        setProperty('nerm2.alpha', 0)
        end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'nermalNote' then

        --drains the health when hit
		setProperty('health',getProperty('health')-0.18)

        --shakes the camera
		cameraShake('game', 0.10, 0.5);
        cameraShake('hud', 0.10, 0.5);
        cameraShake('other', 0.10, 0.5);

        
        if dadName == 'garfield' then --garfield stuff
            --plays a sound (if it wasn't obvs enough)
            playSound('fard', 1)

            --tweens the items
            doTweenAlpha('garft1', 'garf1', 1, 1, 'bounceOut');
            doTweenAlpha('garft2', 'garf2', 1, 1, 'bounceOut');
        else --nermal stuff
            --plays a sound (if it wasn't obvs enough)
            playSound('wow', 1)

            --tweens the items
            doTweenAlpha('nermt1', 'nerm1', 1, 1, 'bounceOut');
            doTweenAlpha('nermt2', 'nerm2', 1, 1, 'bounceOut');
        end
            
        runTimer('nermalBlock', 10); --starts the timer
        

        --tweens the alphas to 0 once the timer is done
		function onTimerCompleted(tag, l, ll)
			if tag == 'nermalBlock' then
                if dadName == 'garfield' then
                    doTweenAlpha('solonggarf1', 'garf1', 0, 0.5, linear);
                    doTweenAlpha('solonggarf2', 'garf2', 0, 0.5, linear);
                else
                    doTweenAlpha('solongnerm1', 'nerm1', 0, 0.5, 'linear');
                    doTweenAlpha('solongnerm2', 'nerm2', 0, 0.5, 'linear');
                end
			end
		end
	end
end

function onUpdate(elapsed)
    --note stuff
    for i = 0, getProperty('notes.length')-1 do
        if getPropertyFromGroup('notes', i, 'noteType') == 'nermalNote' then
            if getPropertyFromGroup('notes', i, 'strumTime') - 1500 > (curStep * stepCrochet) then
                setPropertyFromGroup('notes', i, 'visible', false)
            else
                setPropertyFromGroup('notes', i, 'visible', true)
            end
            
            --does note tweens on the gay difficulty
            if getProperty('storyDifficultyText') == 'Gay' then
                if dadName == 'garfield' then
                    setPropertyFromGroup('notes', i, 'offsetY', getPropertyFromGroup('notes', i, 'y') / -1 * math.abs(math.sin(getPropertyFromClass('Conductor', 'songPosition') / 100) * 1))
                else
                    setPropertyFromGroup('notes', i, 'offsetY', getPropertyFromGroup('notes', i, 'y') / -1.1)
                end
                
                setPropertyFromGroup('notes', i, 'offsetX', getPropertyFromGroup('notes', i, 'y') * math.sin(getPropertyFromClass('Conductor', 'songPosition') / 100) * 0.3)
            end
        end
    end
end

--script made by slithy and car