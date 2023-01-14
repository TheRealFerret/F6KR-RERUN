--creates the sprites
function onCreate()

    --graphic
    makeLuaSprite('black','',-100,0)
	makeGraphic('black',1500,1500,'000000')
    setObjectCamera('black', 'other')   
    
    --images
    makeLuaSprite('mechWarn1', 'mechanicsWarning/nermnoteWarningImage', 850, 200)
	setObjectCamera('mechWarn1','other')
    scaleObject('mechWarn1', 2,2)

    makeLuaSprite('mechWarn2', 'mechanicsWarning/nermnoteWarningText', 0, 0)
	setObjectCamera('mechWarn2','other')
    scaleObject('mechWarn2', 1.3,1.3)

    makeLuaSprite('mechWarn3', 'mechanicsWarning/garfnoteWarningImage', 1000, 400)
	setObjectCamera('mechWarn3','other')
    scaleObject('mechWarn3', 2,2)

    makeLuaSprite('mechWarn4', 'mechanicsWarning/abuseWarningText', 0, 0)
	setObjectCamera('mechWarn4','other')
    scaleObject('mechWarn4', 1.3,1.3)
    
    makeLuaSprite('mechWarn5', 'mechanicsWarning/clickbaitarrow', 825, 475)
	setObjectCamera('mechWarn5','other')
    scaleObject('mechWarn5', 0.5,0.5)

    makeLuaSprite('mechWarn6', 'mechanicsWarning/gayModeWarning', 150, 600)
	setObjectCamera('mechWarn6','other')
    scaleObject('mechWarn6', 0.7, 0.7)

    makeLuaSprite('mechWarn7', 'mechanicsWarning/jumpscareNoteWarning', 850, 100)
	setObjectCamera('mechWarn7','other')
    scaleObject('mechWarn7', 2, 2)

	setProperty('black.alpha', 0)

    addLuaSprite('black', true);

    --adds sprites based on the song
    if string.lower(songName) == 'nermal' or string.lower(songName) == 'nermal gayremix' then --specifies song name
        addLuaSprite('mechWarn1', true)
        addLuaSprite('mechWarn2', true)
        if getProperty('storyDifficultyText') == 'Gay' then --adds the lua sprite on gay difficulty only
            addLuaSprite('mechWarn6', true)
            setProperty('mechWarn6.alpha', 0)
        end
        --sets alphas to 0
        setProperty('mechWarn1.alpha', 0)
        setProperty('mechWarn2.alpha', 0)
    elseif string.lower(songName) == 'abuse' or string.lower(songName) == 'abuse gayremix' then --specifies song name
        addLuaSprite('mechWarn1', true)
            setProperty('mechWarn1.x', 550)
            setProperty('mechWarn1.y', 400)
            setProperty('mechWarn1.scale.x', 1.2)
            setProperty('mechWarn1.scale.y', 1.2)
        addLuaSprite('mechWarn3', true)
            setProperty('mechWarn3.scale.x', 1.2)
            setProperty('mechWarn3.scale.y', 1.2)
        addLuaSprite('mechWarn4', true)
        addLuaSprite('mechWarn5', true)
        addLuaSprite('mechWarn7', true)

        --sets alphas to 0
        setProperty('mechWarn1.alpha', 0)
        setProperty('mechWarn3.alpha', 0)
        setProperty('mechWarn4.alpha', 0)
        setProperty('mechWarn5.alpha', 0)
        setProperty('mechWarn7.alpha', 0)
    end
end

--tweens alpha to 1
function warnAppear()
    doTweenAlpha('hello1', 'black', 0.8, 0.5, 'linear');
    if string.lower(songName) == 'nermal' or string.lower(songName) == 'nermal gayremix' then --specifies song name
        doTweenAlpha('hello2', 'mechWarn1', 1, 0.5, 'linear');
        doTweenAlpha('hello3', 'mechWarn2', 1, 0.5, 'linear');
        if getProperty('storyDifficultyText') == 'Gay' then --specifies difficulty of the song
            doTweenAlpha('hello7', 'mechWarn6', 1, 0.5, 'linear');
        end

    elseif string.lower(songName) == 'abuse' or string.lower(songName) == 'abuse gayremix' then --specifies song name
        doTweenAlpha('hello2', 'mechWarn1', 1, 0.5, 'linear');
        doTweenAlpha('hello4', 'mechWarn3', 1, 0.5, 'linear');
        doTweenAlpha('hello5', 'mechWarn4', 1, 0.5, 'linear');
        doTweenAlpha('hello6', 'mechWarn5', 1, 0.5, 'linear');
        doTweenAlpha('hello8', 'mechWarn7', 1, 0.5, 'linear');
    end
    runTimer('warningScreen', 2.2) --starts a timer
end

--tweens alpha to 0
function warnDie()
    doTweenAlpha('byebye1', 'black', 0, 0.5, 'linear');--thank you M1Aether

    --does tweens based on song name
    if string.lower(songName) == 'nermal' or string.lower(songName) == 'nermal gayremix' then
        doTweenAlpha('byebye2', 'mechWarn1', 0, 0.5, 'linear');
        doTweenAlpha('byebye3', 'mechWarn2', 0, 0.5, 'linear');
        if getProperty('storyDifficultyText') == 'Gay' then
            doTweenAlpha('byebye7', 'mechWarn6', 0, 0.5, 'linear');
        end
    elseif string.lower(songName) == 'abuse' or string.lower(songName) == 'abuse gayremix' then
        doTweenAlpha('byebye2', 'mechWarn1', 0, 0.5, 'linear');
        doTweenAlpha('byebye4', 'mechWarn3', 0, 0.5, 'linear');
        doTweenAlpha('byebye5', 'mechWarn4', 0, 0.5, 'linear');
        doTweenAlpha('byebye6', 'mechWarn5', 0, 0.5, 'linear');
        doTweenAlpha('byebye8', 'mechWarn7', 0, 0.5, 'linear');
    end
end

--removes sprites when tweens are done
function onTweenCompleted(tag) --FOR OPTIMIZATION
    if tag == 'byebye1' then
        removeLuaSprite('black')
    elseif tag == 'byebye2' then
        removeLuaSprite('mechWarn1')
    elseif tag == 'byebye3' then
        removeLuaSprite('mechWarn2')
    elseif tag == 'byebye4' then
        removeLuaSprite('mechWarn3')
    elseif tag == 'byebye5' then
        removeLuaSprite('mechWarn4')
    elseif tag == 'byebye5' then
        removeLuaSprite('mechWarn5')
    elseif tag == 'byebye7' then
        removeLuaSprite('mechWarn6')
    elseif tag == 'byebye8' then
        removeLuaSprite('mechWarn6')
    end
end

function onStepHit()
    if isStoryMode and not seenCutscene then --this means it'll only show once after you load up the song in story mode, these screens will not show up in freeplay 
        if string.lower(songName) == 'nermal' and curBeat == 0 then
            warnAppear()
        elseif string.lower(songName) == 'nermal gayremix' and curBeat == 0 then
            warnAppear()
        elseif string.lower(songName) == 'abuse' and curBeat == 0 then
            warnAppear()
        elseif string.lower(songName) == 'abuse gayremix' and curBeat == 0 then
            warnAppear()
        end
    end
end

--starts a function after timer is completed
function onTimerCompleted(tag, l, ll)
    if tag == 'warningScreen' then
        warnDie() --starts the alpha tweens to 0 after the timer is done
    end
end

--script made by slithy