package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

class DeliLoseSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;
	var staticlol:FlxSprite;

	var stageSuffix:String = "";

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (PlayState.SONG.player1)
		{
			case 'bf-pixel':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}

		super();

		//fuck this
		Conductor.songPosition = 0;

		    staticlol = new FlxSprite(-440, -240);
		    staticlol.frames = Paths.getSparrowAtlas('staticlol');
			staticlol.setGraphicSize(Std.int(staticlol.width * 7.2));
		    staticlol.antialiasing = false;
		    staticlol.animation.addByPrefix('move', 'Static', 24);
			staticlol.scrollFactor.set(0, 0);
		    staticlol.animation.play('move');
		    staticlol.updateHitbox();
			staticlol.alpha = 0.7;
			add(staticlol);
			
			FlxG.camera.fade(FlxColor.BLACK, 3, false, function()
			{
				LoadingState.loadAndSwitchState(new PlayState());
			});
			FlxG.sound.play(Paths.sound('voidintro'));

	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

	}

	override function beatHit()
	{
		super.beatHit();

	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd-issac'));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
