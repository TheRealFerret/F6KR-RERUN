function onCreate()
	setPropertyFromClass('GameOverSubstate', 'characterName', 'bef'); --Character json file for the death animation
	setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx'); --put in mods/sounds/
	--setPropertyFromClass('GameOverSubstate', 'loopSoundName', 'Gameover'); --put in mods/music/
	--setPropertyFromClass('GameOverSubstate', 'endSoundName', 'gameOverEnd'); --put in mods/music/
end