function onEvent(name, value1, value2)
    if name == 'health loss' then
        setProperty('health', getProperty('health') - tonumber(value1))
    end
end