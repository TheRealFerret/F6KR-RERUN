function onEvent(n,v1,v2)


	if n == 'Flash Camera' then

	   makeLuaSprite('flash', '', 0, 0);
        makeGraphic('flash',1280,720,v2)
	      setLuaSpriteScrollFactor('flash',0,0)
		  addLuaSprite('flash', true);
		  setProperty('flash.scale.y',2)
	      setProperty('flash.scale.x',2)
	      setProperty('flash.alpha',0)
		setProperty('flash.alpha',0)
		doTweenAlpha('flash','flash',1,v1,'linear')
	end



end