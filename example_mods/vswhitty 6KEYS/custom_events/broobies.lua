function onEvent(n,v,b)
	local defaultPos = {defaultOpponentStrumY0, defaultOpponentStrumY1, defaultOpponentStrumY2, defaultOpponentStrumY3, defaultOpponentStrumY4, defaultOpponentStrumY5, defaultPlayerStrumY0, defaultPlayerStrumY1, defaultPlayerStrumY2, defaultPlayerStrumY3, defaultPlayerStrumY4, defaultPlayerStrumY5};
	if n == 'broobies' then
		for i = 0,11,1 do
			setPropertyFromGroup('strumLineNotes', i, 'y', defaultPos[i + 1] + (i % 2 == 0 and 50 or -50));
			noteTweenY('broobies' .. i, i, defaultPos[i + 1], crochet / 500, 'sineOut')
		end
	end
end
