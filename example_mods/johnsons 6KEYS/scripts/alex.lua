function onCreatePost()

    uncanny = getRandomInt(1, 5)

if uncanny == 1 then


    function onCountdownTick(counter)

        if counter == 2 then
        
         playSound('alex', 1)

	     makeLuaSprite('alex', 'alex', -450, -100);
	     setScrollFactor('alex', 0.9, 0.9);
	     scaleObject('alex', 1, 1);

         addLuaSprite('alex', true);
        end
    end

end
end
