--every variable below is a global so you can change or check them without using the event using setGlobalFromScript or getGlobalFromScript functions

camZooming=false
hypno=false--this variable makes it so it behaves like in Hypno's Lullaby
zoomStp=4
mult=1

function onSectionHit()
    if (runHaxeCode('return Paths.formatToSongPath(PlayState.SONG.notes['..getProperty('curSection')..'] != null);')=='true'and getProperty('camZooming') and camZooming)and getPropertyFromClass('ClientPrefs','camZooms')then
        if getProperty('camGame.zoom')<1.35 then setProperty('camGame.zoom',getProperty('camGame.zoom')-(0.015*getProperty('camZoomingMult')))setProperty('camHUD.zoom',getProperty('camHUD.zoom')-(0.03*getProperty('camZoomingMult')))end
    end
end
function onEvent(n,v,w)
    if n=='Camera Zoom Beat'or n=='Camera_Zoom_Beat'then--underscores bcz of how discord names filenames with spaces :skull:
        camZooming=v~=''zoomStp=tonumber(v)mult=(w==''and 1 or tonumber(w))
    end
    if n=='Camera Bop Speed'then--if you want to use this event for a Hypno's Lullaby port, always remember to use the functions at line 1 or change 'hypno' variable to true
        camZooming=w~=''mult=(v==''and 1 or tonumber(v))zoomStp=tonumber(w)
    end
    if n=='Camera Zoom Interval'then--Andromeda Engine compatibility
        camZooming=v~=''zoomStp=tonumber(v)mult=(w==''and 0.02/0.015 or tonumber(w/0.015))
    end
end
function onStepHit()
    if camZooming and getPropertyFromClass('ClientPrefs','camZooms')then
        if curStep%(hypno and 16/zoomStp or zoomStp*4)==0 and getProperty('camGame.zoom')<1.35 then
            setProperty('camGame.zoom',getProperty('camGame.zoom')+(0.015*mult))setProperty('camHUD.zoom',getProperty('camHUD.zoom')+(0.03*mult))
        end
    end
end