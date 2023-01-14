function onCreatePost()
	setPropertyFromClass('GameOverSubstate', 'characterName', 'minimum_bf-hqr');
end

function onUpdatePost(elapsed)
	if getProperty('boyfriend.animation.curAnim.finished') then
		if getProperty('boyfriend.animation.curAnim.name') == 'pog start' then
			objectPlayAnimation('boyfriend', 'pog loop', true);
			setProperty('boyfriend.offset.x', -12);
		elseif getProperty('boyfriend.animation.curAnim.name') == 'pog point' then
			objectPlayAnimation('boyfriend', 'pog look', true);
		end
	end
end
