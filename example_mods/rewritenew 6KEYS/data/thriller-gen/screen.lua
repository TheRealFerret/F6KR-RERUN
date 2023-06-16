function onCreatePost()
 for i = 0, 5 do
  if not middlescroll then
   setPropertyFromGroup('strumLineNotes', i, 'x', getPropertyFromGroup('strumLineNotes', i, 'x') + 90)
  end
 end
 
 for i = 6, 11 do
  if not middlescroll then
   setPropertyFromGroup('strumLineNotes', i, 'x', getPropertyFromGroup('strumLineNotes', i, 'x') - 70)
  else
   setPropertyFromGroup('strumLineNotes', i, 'x', getPropertyFromGroup('strumLineNotes', i, 'x') + 5)
  end
 end

 for i = 3, 5 do
  if middlescroll then
   setPropertyFromGroup('strumLineNotes', i, 'x', getPropertyFromGroup('strumLineNotes', i, 'x') - 90)
  end
 end

 for i = 0, 2 do
  if middlescroll then
   setPropertyFromGroup('strumLineNotes', i, 'x', getPropertyFromGroup('strumLineNotes', i, 'x') + 100)
  end
 end

 makeLuaSprite('borderLeft', 'border', 0, 0); makeLuaSprite('borderRight', 'border', 1120, 0)
 addLuaSprite('borderLeft', false); addLuaSprite('borderRight', false)
 setProperty('borderLeft.antialiasing', false); setProperty('borderRight.antialiasing', false)
 setObjectCamera('borderLeft', 'camOther'); setObjectCamera('borderRight', 'camOther')
end

--script by KaoyDumb (absolute legend)