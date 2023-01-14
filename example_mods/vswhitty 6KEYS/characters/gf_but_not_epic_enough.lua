-- easter egg that lets u switch to juicy gf instead of sick tricks gf bc im gay

function onUpdatePost(elapsed)
	if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.EIGHT') then
		triggerEvent('Change Character','gf','gf_JUICY')
	end
end
