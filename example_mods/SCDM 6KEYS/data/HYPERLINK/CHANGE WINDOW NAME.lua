function onCreate()
    setPropertyFromClass("openfl.Lib", "application.window.title",'Ferret\'s 6 Key Recharts: THE SWEET TASTE OF [[NEO]]')
end

function onUpdate()
    if getProperty("health") < 0 then
        setPropertyFromClass("openfl.Lib", "application.window.title",'DARKNESS')
    end
end