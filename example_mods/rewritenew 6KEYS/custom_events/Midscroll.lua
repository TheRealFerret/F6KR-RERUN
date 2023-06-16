function onEvent(name, value1, value2)
    if name == "Midscroll" then
        keepScroll = false
        noteTweenX("NoteMove1", 0, 410, 0.5, cubeInOut)
	    noteTweenX("NoteMove2", 1, 520, 0.5, cubeInOut)
	    noteTweenX("NoteMove3", 2, 630, 0.5, cubeInOut)
	    noteTweenX("NoteMove4", 3, 740, 0.5, cubeInOut)
        noteTweenX("NoteMove5", 4, 410, 0.5, cubeInOut)
        noteTweenX("NoteMove6", 5, 520, 0.5, cubeInOut)
        noteTweenX("NoteMove7", 6, 630, 0.5, cubeInOut)
        noteTweenX("NoteMove8", 7, 740, 0.5, cubeInOut)
    end
end
