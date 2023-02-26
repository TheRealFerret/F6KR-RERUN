function onEvent(name, value1, value2)
    if name == "Midscroll" then
        keepScroll = false
        noteTweenX("NoteMove1", 0, 300, 0.5, cubeInOut)
	    noteTweenX("NoteMove2", 1, 410, 0.5, cubeInOut)
	    noteTweenX("NoteMove3", 2, 520, 0.5, cubeInOut)
	    noteTweenX("NoteMove4", 3, 630, 0.5, cubeInOut)
	    noteTweenX("NoteMove5", 4, 740, 0.5, cubeInOut)
	    noteTweenX("NoteMove6", 5, 850, 0.5, cubeInOut)

        noteTweenX("NoteMove7", 6, 300, 0.5, cubeInOut)
	    noteTweenX("NoteMove8", 7, 410, 0.5, cubeInOut)
	    noteTweenX("NoteMove9", 8, 520, 0.5, cubeInOut)
	    noteTweenX("NoteMove10", 9, 630, 0.5, cubeInOut)
	    noteTweenX("NoteMove11", 10, 740, 0.5, cubeInOut)
	    noteTweenX("NoteMove12", 11, 850, 0.5, cubeInOut)
    end
end
