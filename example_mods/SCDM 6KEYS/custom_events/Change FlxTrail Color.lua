function onEvent(name, value1, value2)

	if name == 'Change FlxTrail Color' then
		
		if value1 == 'default' then
			isDefColorDad = true
		elseif value1 ~= 'default' then
			isDefColorDad = false
		elseif value1 == nil or value1 == '' then
			--colorDad = colorDad
		end
		
		if value2 == 'default' then
			isDefColorBF = true
		elseif value2 ~= 'default' then
			isDefColorBF = false
		elseif value2 == nil or value2 == '' then
			--colorBF = colorBF
		end
		
		colorDad = value1
		colorBF = value2
		
	end
	
end