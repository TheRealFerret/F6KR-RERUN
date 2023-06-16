function onEvent(n,v1,v2)


	if n == 'Two_Flashes' then

	   makeLuaSprite('flash', '', 0, 0);
        makeGraphic('flash',1500,900,v2)
	      setLuaSpriteScrollFactor('flash',0,0)
		  addLuaSprite('flash', true);
		  setProperty('flash.scale.y',2)
	      setProperty('flash.scale.x',2)
	      setProperty('flash.alpha',1)
		setProperty('flash.alpha',1)
		doTweenAlpha('flTw','flash',0,v1,'linear')
	end

 

end