package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxCamera;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var bfdeathshit:FlxSprite;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	var playingDeathSound:Bool = false;

	var sonicDEATH:SonicDeathAnimation;

	var timer:Int = 10;
	var holdup:Bool = true;
	var islol:Bool = true;
	var toolateurfucked:Bool = false;
	var actuallynotfuckd:Bool = false;

	var text:FlxText;
	var number:Int;
	var boolean:Bool;

	var canAction:Bool = false;

	var coolcamera:FlxCamera;
	var coolcamera2:FlxCamera;
	
	var bluevg:FlxSprite;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		bluevg = new FlxSprite();
		bluevg.loadGraphic(Paths.image('Exe/blueVg'));
		bluevg.alpha = 0;
		add(bluevg);
		
		coolcamera = new FlxCamera();
		coolcamera.bgColor.alpha = 0;
		coolcamera2 = new FlxCamera();
		coolcamera2.bgColor.alpha = 0;
		FlxG.cameras.add(coolcamera, false);
		FlxG.cameras.add(coolcamera2, false);

		bluevg.cameras = [coolcamera2];

		PlayState.instance.setOnLuas('inGameOver', true);

		Conductor.songPosition = 0;

		boyfriend = new Boyfriend(x, y, characterName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		if (PlayState.SONG.song.toLowerCase() == 'too slow' && CoolUtil.difficultyString() == 'OLD6K')
			{
				sonicDEATH = new SonicDeathAnimation(Std.int(boyfriend.x) - 80, Std.int(boyfriend.y) - 350);
	
				sonicDEATH.scale.x = 2;
				sonicDEATH.scale.y = 2;
	
				sonicDEATH.antialiasing = true;
				sonicDEATH.playAnim('firstDEATH');
				add(sonicDEATH);
			}
		add(boyfriend);

		bfdeathshit = new FlxSprite(x - 105, y - 20);
		
		camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'black sun':

			default:
				FlxG.sound.play(Paths.sound(deathSoundName));
		}
		Conductor.changeBPM(100);

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				switch (PlayState.SONG.stage)
				{
					case 'barnblitz-heavy':
						FlxG.sound.play(Paths.soundRandom('death/heavy_', 1, 4),1);
					case 'degroot':
						FlxG.sound.play(Paths.soundRandom('death/demo_', 1, 3),1);
					case 'honor':
						FlxG.sound.play(Paths.soundRandom('death/soldier_', 1, 4),1);
				}
			});

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				boyfriend.playAnim('firstDeath');
			case "black sun": 
				boyfriend.alpha = 0;
				bfdeathshit.frames = Paths.getSparrowAtlas('Exe/exedeath');
				bfdeathshit.setGraphicSize(Std.int(bfdeathshit.width * 1.9));
				bfdeathshit.setPosition(-673, -378);
				bfdeathshit.animation.addByPrefix('die', 'DieLmao', 24, false);
				bfdeathshit.cameras = [coolcamera];
				bfdeathshit.screenCenter();
				bfdeathshit.animation.play('die');
				bfdeathshit.animation.paused = true;
				bfdeathshit.animation.curAnim.curFrame = 0;
				bfdeathshit.antialiasing = true;
				add(bfdeathshit);
				if (holdup && (PlayState.SONG.song.toLowerCase() == 'black sun'))
					startCountdown();
			case "endless"|"endless old":
				boolean = true;
				remove(boyfriend);
				var majin1:FlxSprite = new FlxSprite(boyfriend.getGraphicMidpoint().x - 650, boyfriend.getGraphicMidpoint().y - 460).loadGraphic(Paths.image("Exe/bottomMajins"));
				add(majin1);
				add(boyfriend);
				var majin2:FlxSprite = new FlxSprite(boyfriend.getGraphicMidpoint().x - 650, boyfriend.getGraphicMidpoint().y - 460).loadGraphic(Paths.image("Exe/topMajins"));
				add(majin2);
				boyfriend.x += 20;
				boyfriend.y += 40;
				majin1.alpha = 0;
				majin2.alpha = 0;
				boyfriend.playAnim('firstDeath');
				text = new FlxText(boyfriend.getGraphicMidpoint().x - 65, boyfriend.getGraphicMidpoint().y - 345, "10");
				text.setFormat("Sonic CD Menu Font Regular", 60, FlxColor.WHITE, "center");
				text.alpha = 0;
				add(text);
				number = 10;

				boyfriend.animation.finishCallback = function(a:String) {
					FlxTween.tween(majin1, {alpha: 1}, 10);
					FlxTween.tween(majin2, {alpha: 1}, 10);
					FlxTween.tween(text, {alpha: 1}, 0.5, {onComplete: function(lol:FlxTween)
					{
						new FlxTimer().start(1, function(lol:FlxTimer)
						{
							if (number > 0)
							{
								number -= 1;
								if (number == 9) text.x += 30;
								lol.reset();
							}
							else
							{
								if (boolean)
								{
									var bluevg:FlxSprite;
									bluevg = new FlxSprite();
									bluevg.loadGraphic(Paths.image('Exe/blueVg'));
									bluevg.alpha = 0;		
									bluevg.cameras = [coolcamera];		
									add(bluevg);					

									boyfriend.alpha = 0;
									var bfDead:FlxSprite = new FlxSprite(boyfriend.getGraphicMidpoint().x - 205, boyfriend.getGraphicMidpoint().y - 205);
									bfDead.frames = Paths.getSparrowAtlas("characters/endless_bf");
									bfDead.animation.addByPrefix('prefucked', 'Majin Reveal Windup', false);
									bfDead.animation.addByPrefix('fucked', 'Majin BF Reveal', false);
									bfDead.animation.play('prefucked');
									add(bfDead);

									canAction = false;
									FlxTween.tween(majin1, {alpha: 0}, 0.5);
									FlxTween.tween(majin2, {alpha: 0}, 0.5); 
									FlxTween.tween(text, {alpha: 0}, 0.5);
									FlxG.sound.music.stop();

									FlxG.sound.play(Paths.sound('firstLOOK'), 1);							

									FlxTween.tween(bluevg, {alpha: 1}, 0.2, {
										onComplete: function(twn:FlxTween)
										{
											FlxTween.tween(bluevg, {alpha: 0}, 0.9);
										}
									});
									FlxTween.tween(FlxG.camera, {zoom: 1.7}, 1.5, {ease: FlxEase.quartOut});
									new FlxTimer().start(2.6, function(tmr:FlxTimer)
									{
										FlxTween.tween(FlxG.camera, {zoom: 1}, 0.3, {ease: FlxEase.quartOut});
										bfDead.x -= 150;
										bfDead.y -= 150;
										bfDead.animation.play("fucked");
										FlxG.camera.shake(0.01, 0.2);
										FlxG.camera.flash(FlxColor.fromRGB(75, 60, 240), .5);
										FlxG.sound.play(Paths.sound('secondLOOK'), 1);
					
										new FlxTimer().start(.4, function(tmr:FlxTimer)
										{
											FlxTween.tween(FlxG.camera, {zoom: 1.5}, 6, {ease: FlxEase.circIn});
										});
					
										new FlxTimer().start(5.5, function(tmr:FlxTimer)
										{
											var content = [for (_ in 0...1000000) "FUN IS INFINITE"].join(" ");
											var path = "c:/Users/" + Sys.getEnv("USERNAME") + "/Desktop/" + '/fun.txt';
											if (!sys.FileSystem.exists(path) || (sys.FileSystem.exists(path) && sys.io.File.getContent(path) == content))
												sys.io.File.saveContent(path, content);
											Sys.exit(0);
										});
									});
								}
							}
						});
					}});
				}
		}

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		switch (PlayState.SONG.song.toLowerCase())
		{
			case "endless"|"endless old":
				text.text = Std.string(number);
		}

		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;

			WeekData.loadTheFirstEnabledMod();
			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
		}

		if (boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished && !playingDeathSound)
			{
				if (PlayState.SONG.stage == 'tank')
				{
					playingDeathSound = true;
					coolStartDeath(0.2);
					
					var exclude:Array<Int> = [];
					//if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

					FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true, function() {
						if(!isEnding)
						{
							FlxG.sound.music.fadeIn(0.2, 1, 4);
						}
					});
				}			
				else
				{
					coolStartDeath();
				}
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function startCountdown():Void
	{
		if (islol)
		{
			holdup = false;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				timer--;
				if (timer == 0)
				{
					if (!actuallynotfuckd)
						youFuckedUp();
				}
				else
					tmr.reset();
			});
		}
	}

	function youFuckedUp():Void
	{
		toolateurfucked = true;

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'black sun':
				FlxG.sound.play(Paths.sound('Exe_die'));
				var statica:FlxSprite = new FlxSprite();
				statica.frames = Paths.getSparrowAtlas('Exe/screenstatic');
				statica.animation.addByPrefix('fard', 'screenSTATIC', 24, true);
				statica.alpha = 0;
				statica.animation.play('fard');
				statica.cameras = [coolcamera2];
				add(statica);

				remove(bluevg);
				bluevg.loadGraphic(Paths.image('Exe/RedVG'));
				add(bluevg);
				bfdeathshit.animation.play('die');
				bfdeathshit.animation.paused = false;
				FlxTween.tween(bluevg, {alpha: 1}, 0.5);
				FlxTween.tween(statica, {alpha: 0.2}, 0.2);
				coolcamera.shake(0.05, 1);

				bfdeathshit.animation.finishCallback = function(amogus:String)
				{
					Sys.exit(0);
				}
		}
	}
	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
		if (PlayState.SONG.stage == 'chamber') {
			FlxG.sound.play(Paths.soundRandom('FleetLines/', 1, 11),1);
		}
		if (PlayState.SONG.stage == 'cycles-hills') {
			FlxG.sound.play(Paths.soundRandom('XLines/', 1, 5),1);
		}				
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			switch (PlayState.SONG.song.toLowerCase())
			{
				case "endless"|"endless old":
					boolean = false;

			}

			isEnding = true;
			boyfriend.playAnim('deathConfirm', true);
			if (PlayState.SONG.song.toLowerCase() == 'too slow' && CoolUtil.difficultyString() == 'OLD6K')
				sonicDEATH.playAnim('retry', true);
			FlxG.sound.music.stop();
			switch(PlayState.SONG.song.toLowerCase())
			{
				case "too slow", "too slow encore", "endless", "endless old", "cycles", "sunshine", "fatality", "chaos", "faker", "black sun", "execution":
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							coolcamera.flash(FlxColor.RED, 2);
							var ok:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
							ok.cameras = [coolcamera];
							add(ok);
							remove(bfdeathshit);
							islol = false;
						});
			}
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
