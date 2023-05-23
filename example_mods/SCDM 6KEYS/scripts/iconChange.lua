--iconChange script originally created by Onionring1403.
--Feel free to add/replace characters listed if need be.
--You can find most of the icons at 'iconChange/[charname]/[iconname](-lose)'
--also, download the script by itself at this link: https://drive.google.com/drive/folders/1wH4tzp06w_LbwjJeD7VXHfXdn9F2fHWD?usp=sharing
--as of now, no other official download is posted yet.

local susIconAppeared = false;
local ralIconAppeared = false;
local seamIconAppeared = false;
local starwIconAppeared = false;
local spamIconAppeared = false;

local exIconAppearedP1 = false;
local exIconAppearedP2 = false;
local exIconAppearedP1w = false;
local exIconAppearedP2w = false;
local exIconAppearedP1l = false;
local exIconAppearedP2l = false;

function onCreate()
	makeLuaSprite('exIconP1', 'iconChange/man/no', getProperty('iconP1.x'), getProperty('iconP1.y') - 15)
	setObjectCamera('exIconP1', 'hud')
	addLuaSprite('exIconP1', true)
	setObjectOrder('exIconP1', getObjectOrder('iconP1'))
	setProperty('exIconP1.flipX', true)
	setProperty('exIconP1.visible', false)
	makeLuaSprite('exIconP1-win', 'iconChange/man/no', getProperty('iconP1.x'), getProperty('iconP1.y') - 15)
	setObjectCamera('exIconP1-win', 'hud')
	addLuaSprite('exIconP1-win', true)
	setObjectOrder('exIconP1-win', getObjectOrder('iconP1'))
	setProperty('exIconP1-win.flipX', true)
	setProperty('exIconP1-win.visible', false)
	makeLuaSprite('exIconP1-lose', 'iconChange/man/no', getProperty('iconP1.x'), getProperty('iconP1.y') - 15)
	setObjectCamera('exIconP1-lose', 'hud')
	addLuaSprite('exIconP1-lose', true)
	setObjectOrder('exIconP1-lose', getObjectOrder('iconP1'))
	setProperty('exIconP1-lose.flipX', true)
	setProperty('exIconP1-lose.visible', false)

	makeLuaSprite('exIconP2', 'iconChange/man/no', getProperty('iconP1.x'), getProperty('iconP1.y') - 15)
	setObjectCamera('exIconP2', 'hud')
	addLuaSprite('exIconP2', true)
	setObjectOrder('exIconP2', getObjectOrder('iconP2'))
	setProperty('exIconP2.flipX', false)
	setProperty('exIconP2.visible', false)
	makeLuaSprite('exIconP2-win', 'iconChange/man/no', getProperty('iconP1.x'), getProperty('iconP1.y') - 15)
	setObjectCamera('exIconP2-win', 'hud')
	addLuaSprite('exIconP2-win', true)
	setObjectOrder('exIconP2-win', getObjectOrder('iconP2'))
	setProperty('exIconP2-win.flipX', false)
	setProperty('exIconP2-win.visible', false)
	makeLuaSprite('exIconP2-lose', 'iconChange/man/no', getProperty('iconP1.x'), getProperty('iconP1.y') - 15)
	setObjectCamera('exIconP2-lose', 'hud')
	addLuaSprite('exIconP2-lose', true)
	setObjectOrder('exIconP2-lose', getObjectOrder('iconP2'))
	setProperty('exIconP2-lose.flipX', false)
	setProperty('exIconP2-lose.visible', false)
end


function onUpdate(elapsed)
	if (getPropertyFromClass("flixel.FlxG", "keys.justPressed.F1")) and spamIconAppeared == false and (getProperty('curSong') == 'showstopping' or getProperty('curSong') == 'hyperlink' or getProperty('curSong') == 'all-stars') then
		makeLuaSprite('spamtong', 'iconChange/spamton/neo-lose', getProperty('iconP1.x'), getProperty('iconP1.y') - 15)
		setObjectCamera('spamtong', 'hud')
		setProperty('spamtong.scale.x', getProperty('iconP1.scale.x') / 1.25)
		setProperty('spamtong.scale.y', getProperty('iconP1.scale.y') / 1.25)
		setProperty('spamtong.flipX', true)
		setProperty('spamtong.visible', true)
		setObjectOrder('spamtong', getObjectOrder('iconP1') + 1)
		doTweenAlpha('spamtong', 'spamtong', 0, 1, circOut)
	end

	health = getProperty('health')
	setProperty('exIconP1.x', getProperty('iconP1.x'))
	setProperty('exIconP1.y', getProperty('iconP1.y') - 15)
	setProperty('exIconP1.scale.x', getProperty('iconP1.scale.x'))
	setProperty('exIconP1.scale.y', getProperty('iconP1.scale.y'))
	setObjectOrder('exIconP1', getObjectOrder('iconP1'))
	setProperty('exIconP2.x', getProperty('iconP2.x'))
	setProperty('exIconP2.y', getProperty('iconP2.y') - 15)
	setProperty('exIconP2.scale.x', getProperty('iconP2.scale.x'))
	setProperty('exIconP2.scale.y', getProperty('iconP2.scale.y'))
	setObjectOrder('exIconP2', getObjectOrder('iconP2'))

	setProperty('exIconP1-lose.x', getProperty('iconP1.x'))
	setProperty('exIconP1-lose.y', getProperty('iconP1.y') - 15)
	setProperty('exIconP1-lose.scale.x', getProperty('iconP1.scale.x'))
	setProperty('exIconP1-lose.scale.y', getProperty('iconP1.scale.y'))
	setObjectOrder('exIconP1-lose', getObjectOrder('iconP1'))
	setProperty('exIconP2-lose.x', getProperty('iconP2.x'))
	setProperty('exIconP2-lose.y', getProperty('iconP2.y') - 15)
	setProperty('exIconP2-lose.scale.x', getProperty('iconP2.scale.x'))
	setProperty('exIconP2-lose.scale.y', getProperty('iconP2.scale.y'))
	setObjectOrder('exIconP2-lose', getObjectOrder('iconP2'))

	setProperty('exIconP1-win.x', getProperty('iconP1.x'))
	setProperty('exIconP1-win.y', getProperty('iconP1.y') - 15)
	setProperty('exIconP1-win.scale.x', getProperty('iconP1.scale.x'))
	setProperty('exIconP1-win.scale.y', getProperty('iconP1.scale.y'))
	setObjectOrder('exIconP1-win', getObjectOrder('iconP1'))
	setProperty('exIconP2-win.x', getProperty('iconP2.x'))
	setProperty('exIconP2-win.y', getProperty('iconP2.y') - 15)
	setProperty('exIconP2-win.scale.x', getProperty('iconP2.scale.x'))
	setProperty('exIconP2-win.scale.y', getProperty('iconP2.scale.y'))
	setObjectOrder('exIconP2-win', getObjectOrder('iconP2'))

	setProperty('exIconP1.visible', false)
	setProperty('exIconP2.visible', false)
	setProperty('exIconP1-lose.visible', false)
	setProperty('exIconP2-lose.visible', false)
	setProperty('exIconP1-win.visible', false)
	setProperty('exIconP2-win.visible', false)

	setProperty('iconP1.visible', true)
	setProperty('iconP2.visible', true)
	if exIconAppearedP1 then
		setProperty('iconP1.visible', false)
		setProperty('exIconP1.visible', true)
	end
	if exIconAppearedP2 then
		setProperty('iconP2.visible', false)
		setProperty('exIconP2.visible', true)
	end
	if exIconAppearedP1l then
		if health < 0.4 then
			setProperty('iconP1.visible', false)
			setProperty('exIconP1.visible', false)
			setProperty('exIconP1-lose.visible', true)
		end
	end
	if exIconAppearedP2l then
		if health > 1.6 then
			setProperty('iconP2.visible', false)
			setProperty('exIconP2.visible', false)
			setProperty('exIconP2-lose.visible', true)
		end
	end
	if exIconAppearedP1w then
		if health > 1.6 then
			setProperty('iconP1.visible', false)
			setProperty('exIconP1.visible', false)
			setProperty('exIconP1-win.visible', true)
		end
	end
	if exIconAppearedP2w then
		if health < 0.4 then
			setProperty('iconP2.visible', false)
			setProperty('exIconP2.visible', false)
			setProperty('exIconP2-win.visible', true)
		end
	end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType ~= 'No Animation' and noteType ~= 'shield' and noteType ~= 'Susie Sing neo' and noteType ~= 'Susie Sing' and noteType ~= 'GF Sing' and not gfSection and (susIconAppeared or ralIconAppeared) then
		setProperty('iconP1.visible', true)
		susIconAppeared = false;
		ralIconAppeared = false;
		triggerEvent('Icon Change', 'reset', '');
		triggerEvent('Icon Change-Win', 'reset', '');
		triggerEvent('Icon Change-Lose', 'reset', '');
	end
	if noteType == 'Susie Sing neo' or noteType == 'Susie Sing' and not susIconAppeared then
		susIconAppeared = true;
		triggerEvent('Icon Change', 'susie/sus', '');
		triggerEvent('Icon Change-Win', 'susie/sus', '');
		triggerEvent('Icon Change-Lose', 'susie/sus-lose', '');
		setProperty('iconP1.visible', false)
	end
	if noteType == 'GF Sing' or gfSection then
		if getProperty('gf.curCharacter') == 'ralsei_neo' or getProperty('gf.curCharacter') == 'Ralsei_smile' then
			if not ralIconAppeared then
				ralIconAppeared = true;
				triggerEvent('Icon Change', 'kris/ral', '');
				triggerEvent('Icon Change-Win', 'kris/ral', '');
				triggerEvent('Icon Change-Lose', 'kris/ral-lose', '');
				setProperty('iconP1.visible', false)
			end
		else
			--i dunno
		end
	end
end

function onStepHit()
	if getProperty('curSong') == 'ragdoll-chaos' and curStep > 1303 and not seamIconAppeared then
		triggerEvent('Icon Change', 'seam/seam-hurt', '');
		triggerEvent('Icon Change-Win', 'seam/seam-hurt', '');
		triggerEvent('Icon Change-Lose', 'seam/seam-hurt', '');
		seamIconAppeared = true;
	end
	if getProperty('curSong') == 'astra-perambulis' and not starwIconAppeared then
		triggerEvent('Icon Change', 'man/no', '');
		triggerEvent('Icon Change-Win', 'man/no', '');
		triggerEvent('Icon Change-Lose', 'man/no', '');
		starwIconAppeared = true;
	end
end

function onEvent(name, value1, value2)
	if name == "Icon Change" then
		if value1 ~= '' and value1 ~= 'reset' then
			if value2 ~= 'opponent' and value2 ~= 'dad' then
				exIconAppearedP1 = true;
				setProperty('iconP1.visible', false)
				makeLuaSprite('exIconP1', 'iconChange/'..value1, getProperty('iconP1.x'), getProperty('iconP1.y') - 15)
				setObjectCamera('exIconP1', 'hud')
				addLuaSprite('exIconP1', true)
				setObjectOrder('exIconP1', getObjectOrder('iconP1'))
				setProperty('exIconP1.scale.x', getProperty('iconP1.scale.x'))
				setProperty('exIconP1.scale.y', getProperty('iconP1.scale.y'))
				setProperty('exIconP1.flipX', true)
				setProperty('exIconP1.visible', true)
			else
				exIconAppearedP2 = true;
				setProperty('iconP2.visible', false)
				makeLuaSprite('exIconP2', 'iconChange/'..value1, getProperty('iconP1.x'), getProperty('iconP1.y') - 15)
				setObjectCamera('exIconP2', 'hud')
				addLuaSprite('exIconP2', true)
				setProperty('exIconP2.scale.x', getProperty('iconP2.scale.x'))
				setProperty('exIconP2.scale.y', getProperty('iconP2.scale.y'))
				setObjectOrder('exIconP2', getObjectOrder('iconP2'))
				setProperty('exIconP2.flipX', false)
				setProperty('exIconP2.visible', true)
			end
		else
			exIconAppearedP1 = false;
			exIconAppearedP1l = false;
			exIconAppearedP1w = false;
			setProperty('iconP1.visible', true)
			exIconAppearedP2 = false;
			exIconAppearedP2l = false;
			exIconAppearedP2w = false;
			setProperty('iconP2.visible', true)
		end
	end
	if name == "Icon Change-Lose" then
		health = getProperty('health')
		if value1 ~= '' and value1 ~= 'reset' then
			if value2 ~= 'opponent' and value2 ~= 'dad' then
				exIconAppearedP1l = true;
				makeLuaSprite('exIconP1-lose', 'iconChange/'..value1, getProperty('iconP1.x'), getProperty('iconP1.y') - 15)
				setObjectCamera('exIconP1-lose', 'hud')
				addLuaSprite('exIconP1-lose', true)
				setObjectOrder('exIconP1-lose', getObjectOrder('iconP1'))
				setProperty('exIconP1-lose.scale.x', getProperty('iconP1.scale.x'))
				setProperty('exIconP1-lose.scale.y', getProperty('iconP1.scale.y'))
				setProperty('exIconP1-lose.flipX', true)
				setProperty('exIconP1-lose.visible', health < 0.4)
				setProperty('exIconP1.visible', not health < 0.4)
			else
				exIconAppearedP2l = true;
				makeLuaSprite('exIconP2-lose', 'iconChange/'..value1, getProperty('iconP1.x'), getProperty('iconP1.y') - 15)
				setObjectCamera('exIconP2-lose', 'hud')
				addLuaSprite('exIconP2-lose', true)
				setProperty('exIconP2-lose.scale.x', getProperty('iconP2.scale.x'))
				setProperty('exIconP2-lose.scale.y', getProperty('iconP2.scale.y'))
				setObjectOrder('exIconP2-lose', getObjectOrder('iconP2'))
				setProperty('exIconP2-lose.flipX', false)
				setProperty('exIconP2-lose.visible', health > 1.6)
				setProperty('exIconP2.visible', not health > 1.6)
			end
		else
			exIconAppearedP1l = false;
			exIconAppearedP2l = false;
		end
	end
	if name == "Icon Change-Win" then
		health = getProperty('health')
		if value1 ~= '' and value1 ~= 'reset' then
			if value2 ~= 'opponent' and value2 ~= 'dad' then
				exIconAppearedP1w = true;
				makeLuaSprite('exIconP1-win', 'iconChange/'..value1, getProperty('iconP1.x'), getProperty('iconP1.y') - 15)
				setObjectCamera('exIconP1-win', 'hud')
				addLuaSprite('exIconP1-win', true)
				setProperty('exIconP1-win.scale.x', getProperty('iconP1.scale.x'))
				setProperty('exIconP1-win.scale.y', getProperty('iconP1.scale.y'))
				setObjectOrder('exIconP1-win', getObjectOrder('iconP1'))
				setProperty('exIconP1-win.flipX', true)
				setProperty('exIconP1-win.visible', health > 1.6)
				setProperty('exIconP1.visible', not health > 1.6)
			else
				exIconAppearedP2w = true;
				makeLuaSprite('exIconP2-win', 'iconChange/'..value1, getProperty('iconP1.x'), getProperty('iconP1.y') - 15)
				setObjectCamera('exIconP2-win', 'hud')
				addLuaSprite('exIconP2-win', true)
				setProperty('exIconP2-win.scale.x', getProperty('iconP2.scale.x'))
				setProperty('exIconP2-win.scale.y', getProperty('iconP2.scale.y'))
				setObjectOrder('exIconP2-win', getObjectOrder('iconP2'))
				setProperty('exIconP2-win.flipX', false)
				setProperty('exIconP2-win.visible', health < 0.4)
				setProperty('exIconP2.visible', not health < 0.4)
			end
		else
			exIconAppearedP1w = false;
			exIconAppearedP2w = false;
		end
	end
end