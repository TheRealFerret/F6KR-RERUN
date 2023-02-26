package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Options', 'Exit to menu'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	public static var wasInSong:Bool;
	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	//var botplayText:FlxText;

	var lerpOut:Bool = false;
	var poggers:Float = 0;

	var exitStateTimeDelay:Float = 0.5;
	var exitStateTime:FlxTimer;

	public static var songName:String = '';

	public function new(x:Float, y:Float)
	{
		super();
		if(CoolUtil.difficulties.length < 2) menuItemsOG.remove('Change Difficulty'); //No need to change difficulty if there is only one!

		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(5 + num, 'Toggle Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');


		pauseMusic = new FlxSound();
		if(songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		exitStateTimeDelay = 0.5;
		new FlxTimer().start(0.1, function(exitStateTime:FlxTimer)
		{
			exitStateTimeDelay -= 0.11;
		}, 5);
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		if (controls.BACK)
		{
			closeState(0);
			resumin();
		}
		if (controls.RESET)
			{
				if (exitStateTimeDelay <= 0.0)
				{
					PlayState.instance.health = 0;
					close();
				}
			}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted && cantUnpause <= 0)
		{
			if (menuItems == difficultyChoices)
			{
				if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Resume":
					if (exitStateTimeDelay <= 0.0){
						closeState();
						resumin();
					}
				case 'Change Difficulty':
					if (exitStateTimeDelay <= 0.0)
						{
							menuItems = difficultyChoices;
							deleteSkipTimeText();
							regenMenu();
						}
				case 'Toggle Practice Mode':
					if (exitStateTimeDelay <= 0.0)
						{
							PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
							PlayState.changedDifficulty = true;
							practiceText.visible = PlayState.instance.practiceMode;
						}
				case "Restart Song":
					if (exitStateTimeDelay <= 0.0)
						restartSong();
				case "Leave Charting Mode":
					if (exitStateTimeDelay <= 0.0)
						{
							restartSong();
							PlayState.chartingMode = false;
						}
				case 'Skip Time':
					if (exitStateTimeDelay <= 0.0)
						{
							if(curTime < Conductor.songPosition)
							{
								PlayState.startOnTime = curTime;
								restartSong(true);
							}
							else
							{
								if (curTime != Conductor.songPosition)
								{
									PlayState.instance.clearNotesBefore(curTime);
									PlayState.instance.setSongTime(curTime);
								}
								close();
							}
						}
				case "End Song":
					if (exitStateTimeDelay <= 0.0)
						{
							close();
							PlayState.instance.finishSong(true);
						}
				case 'Toggle Botplay':
					if (exitStateTimeDelay <= 0.0)
						{
							PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
							PlayState.changedDifficulty = true;
							PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
							PlayState.instance.botplayTxt.alpha = 1;
							PlayState.instance.botplaySine = 0;
						}
				case 'Options':
					if (exitStateTimeDelay <= 0.0)
						{
							wasInSong = true;
							PlayState.deathCounter = 0;
							PlayState.seenCutscene = false;
							MusicBeatState.switchState(new options.OptionsState());
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
						}
				case "Exit to menu":
					if (exitStateTimeDelay <= 0.0)
						{
							PlayState.deathCounter = 0;
							PlayState.seenCutscene = false;

							WeekData.loadTheFirstEnabledMod();
							if(PlayState.isStoryMode) {
								MusicBeatState.switchState(new StoryMenuState());
							} else {
								MusicBeatState.switchState(new FreeplayState());
							}
							PlayState.cancelMusicFadeTween();
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
							PlayState.changedDifficulty = false;
							PlayState.chartingMode = false;
						}
			}
		}
	}

	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function resumin()
		{
			if (!returning)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				returning = true;
			}
		}
	
	var returning:Bool = false;

	function changeSelection(change:Int = 0):Void
	{
		if (!returning)
		{
			curSelected += change;

			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

			if (curSelected < 0)
				curSelected = menuItems.length - 1;
			if (curSelected >= menuItems.length)
				curSelected = 0;

			var bullShit:Int = 0;

			for (item in grpMenuShit.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;

				item.alpha = 0.6;
				// item.setGraphicSize(Std.int(item.width * 0.8));

				if (item.targetY == 0)
				{
					item.alpha = 1;
					// item.setGraphicSize(Std.int(item.width));

					if(item == skipTimeTracker)
					{
						curTime = Math.max(0, Conductor.songPosition);
						updateSkipTimeText();
					}
				}
			}
		}
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new Alphabet(90, 320, menuItems[i], true);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);

			if(menuItems[i] == 'Skip Time')
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		curSelected = 0;
		changeSelection();
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}

	var startTimer:FlxTimer;

	var daTime:Float = 1;

	function closeState(?custom:Int = null)
	{
		closing = true;
		exitStateTimeDelay = 1;
		new FlxTimer().start(0.3, function(exitStateTime:FlxTimer)
		{
			exitStateTimeDelay -= 0.3;
			trace(exitStateTimeDelay);
		}, 5);

		Conductor.changeBPM(PlayState.SONG.bpm);

		lerpOut = true;
		poggers = 0;

		var da:Int = curSelected;
		if (custom != null)
		{
			da = custom;
		}

		for (i in 0...grpMenuShit.members.length)
		{
			if (i == da)
			{
				FlxFlicker.flicker(grpMenuShit.members[i], 1, 0.06, false, false);
			}
		}

		new FlxTimer().start(daTime, function(tmr:FlxTimer)
		{
			close();
		});
	}

	var closing:Bool = false;
}
