
local angleshit = 0.40;
local anglevar = 0.40;

function onGameOver()

    --here lies cool video for death that was scrapped because of the bugs

end

function onCreate()
 if opponentPlay == false then
    makeAnimatedLuaSprite('youplay', 'youplay', -120, -120)
 end
 setPropertyFromClass('GameOverSubstate', 'characterName', 'johndeath');
 setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'deathjohn');
 setPropertyFromClass('GameOverSubstate', 'loopSoundName', 'deathjohn');
end

function onCountdownTick(counter)

    if counter == 4 and opponentPlay == false then
        addAnimationByPrefix('youplay', 'youplay', 'youplay', 20, false)
        objectPlayAnimation('youplay', 'youplay', false)
        
        addLuaSprite('youplay', true)
    end
end


function swapFont()
	setTextFont("scoreTxt","FUCK.ttf");
	setProperty("scoreTxt.size",24);
	setProperty("scoreTxt.y",getProperty("scoreTxt.y") + -8);
	setProperty("scoreTxt.borderSize",2);

	setTextFont("timeTxt","FUCK.ttf");
	setProperty("timeTxt.size",32);
	setProperty("timeTxt.y",getProperty("timeTxt.y") + -10);
	setProperty('timeTxt.antialiasing', false)
end

function onCreatePost()
	swapFont(); --made on purpose btw

    doTweenZoom('camz','camGame',tonumber(0.4),tonumber(1),'sineInOut')
end

function onSongStart()
    if opponentPlay == true then
        objectPlayAnimation('youplay', 'youplay', false)
            
        addLuaSprite('youplay', true)
    end

    noteTweenX('NoteMove1', 6, 30, 1, 'circOut')
    noteTweenX('NoteMove2', 7, 120, 1, 'circOut')
    noteTweenX('NoteMove3', 8, 210, 1, 'circOut')
    noteTweenX('NoteMove4', 9, 300, 1, 'circOut')
    noteTweenX('NoteMove5', 10, 390, 1, 'circOut')
    noteTweenX('NoteMove6', 11, 480, 1, 'circOut')

    noteTweenX('NoteMove7', 0, 705, 1, 'circOut')
    noteTweenX('NoteMove8', 1, 795, 1, 'circOut')
    noteTweenX('NoteMove9', 2, 885, 1, 'circOut')
    noteTweenX('NoteMove10', 3, 975, 1, 'circOut')
    noteTweenX('NoteMove11', 4, 1065, 1, 'circOut')
    noteTweenX('NoteMove12', 5, 1155, 1, 'circOut')

end


function onBeatHit()
		
	if curBeat >= 64 and curBeat <= 192 then
		if curBeat % 2 == 0 then
			angleshit = anglevar;
		else
			angleshit = -anglevar;
		end
		setProperty('camGame.angle',angleshit*3)
		doTweenAngle('tt', 'camGame', angleshit, stepCrochet*0.002, 'circOut')
		--doTweenX('ttrn', 'camGame', -angleshit*8, crochet*0.001, 'linear')
		xOffset = angleshit*16
	else
		cancelTween('tt')
		--cancelTween('ttrn')
		setProperty('camGame.angle',0)
		xOffset = 0
		--setProperty('camGame.x',0)
		--setProperty('camGame.y',0)
	end

    if curBeat == 112 then
          
        for i=0,5 do
           noteTweenAlpha(i+16, i, 0.5, 8, 'QuadOut')
        end
  
        noteTweenX("woah1", 6, 230, 12, 'QuadOut')
        noteTweenX("woah2", 7, 320, 12, 'QuadOut')
        noteTweenX("woah3", 8, 410, 12, 'QuadOut')
        noteTweenX("woah4", 9, 500, 12, 'QuadOut')
        noteTweenX("woah5", 10, 590, 12, 'QuadOut')
        noteTweenX("woah6", 11, 680, 12, 'QuadOut')
        noteTweenX("BF", 0, 800, 12, 'QuadOut')
        noteTweenX("BF2", 1, 890, 12, 'QuadOut')
        noteTweenX("BF3", 2, 980, 12, 'QuadOut')
        noteTweenX("BF4", 3, 1070, 12, 'QuadOut')
        noteTweenX("BF5", 4, 1160, 12, 'QuadOut')
        noteTweenX("BF6", 5, 1250, 12, 'QuadOut')
  
     
  
    end

    if curBeat == 176 then

        for i=0,5 do
            noteTweenAlpha(i+16, i, 1, 2, 'QuadOut')
        end


        noteTweenX("FUCKbf", 6, -20, 2, 'circOut')
        noteTweenX("FUCKbf2", 7, 60, 2, 'circOut')
        noteTweenX("FUCKbf3", 8, 90, 2, 'circOut')
        noteTweenX("FUCKbf4", 9, 120, 2, 'circOut')
        noteTweenX("FUCKbf5", 10, 150, 2, 'circOut')
        noteTweenX("FUCKbf6", 11, 180, 2, 'circOut')
        noteTweenX("SCREAM0", 0, 200, 2, 'circOut')
        noteTweenX("SCREAM1", 1, 300, 2, 'circOut')
        noteTweenX("SCREAM2", 2, 485, 2, 'circOut')
        noteTweenX("SCREAM3", 3, 655, 2, 'circOut')
        noteTweenX("SCREAM4", 4, 835, 2, 'circOut')
        noteTweenX("SCREAM5", 5, 915, 2, 'circOut')
    end

    if curBeat == 182 then

        noteTweenX('NoteMove1', 6, 30, 1, 'circOut')
        noteTweenX('NoteMove2', 7, 120, 1, 'circOut')
        noteTweenX('NoteMove3', 8, 210, 1, 'circOut')
        noteTweenX('NoteMove4', 9, 300, 1, 'circOut')
        noteTweenX('NoteMove5', 10, 390, 1, 'circOut')
        noteTweenX('NoteMove6', 11, 480, 1, 'circOut')
    
        noteTweenX('NoteMove7', 0, 705, 1, 'circOut')
        noteTweenX('NoteMove8', 1, 795, 1, 'circOut')
        noteTweenX('NoteMove9', 2, 885, 1, 'circOut')
        noteTweenX('NoteMove10', 3, 975, 1, 'circOut')
        noteTweenX('NoteMove11', 4, 1065, 1, 'circOut')
        noteTweenX('NoteMove12', 5, 1155, 1, 'circOut')
    end


    if curBeat == 468 then
        setProperty('camGame.alpha', 0)
    end
end

function opponentNoteHit()
    if curBeat >= 176 and opponentPlay == false then



    health = getProperty('health')
    if getProperty('health') > 0.1 then
        setProperty('health', health -0.03);
    end

end
end

function goodNoteHit()
    if curBeat >= 176 and opponentPlay == true then



    health = getProperty('health')
    setProperty('health', health +0.03);
    
    end
end