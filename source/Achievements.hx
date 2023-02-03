import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class Achievements {
	public static var achievementsStuff:Array<Dynamic> = [ //Name, Description, Achievement save tag, Hidden achievement
		["Starting Slow",				"Beat Bopeebo with a Perfect Rating.",				'bopeebo_pfc',			false],
		["Dull Fuse",					"Beat Ballistic with at least 98% accuracy.",		'ballistic_98acc',		false],
		["Back Allay Miami",			"Beat Ballistic (HQ) with at least 98% accuracy.",	'ballistichq_98acc',	false],
		["YOU CAN\'T KILL CLOWN!!!",	"Beat Madness with no Misses.",						'madness_fc',			false],
		["EXPURGATED",					"Beat Expurgation with at least 95% accuracy.",		'expurgation_95acc',	false],
		["Damn Brats in My Damn Maze",	"Beat Foolhardy with at least 98% accuracy.",		'foolhardy_98acc',		false],
		["A Worthy Opponent",			"Beat Sporting with at least 95% accuracy.",		'sporting_95acc',		false],
		["im so mad",					"Beat No Villains with at least 98% accuracy.",		'novillains_98acc',		false],
		["Get Out of My Head",			"Beat Phantasm with no Misses.",					'phantasm_fc',			false],
		["Found Cause",					"Beat Lost Cause with at least 95% accuracy.",		'lostcause_95acc',		false],
		["Kablooey",					"Beat Reactor with at least 98% accuracy.",			'reactor_98acc',		false],
		["Against All Odds",			"Beat Double Kill with at least 95% accuracy.",		'doublekill_95acc',		false],
		["Undefeatable",				"Beat Defeat with no Misses.",						'defeat_fc',			false],
		["new friend!!!!",				"Beat Heartbeat with no Misses.",					'heartbeat_fc',			false],
		["Exposed",						"Beat Pretender with no Misses.",					'pretender_fc',			false],
		["Peep the Horror",				"Beat Insane Streamer with no Misses.",				'insanestreamer_fc',	false],
		["recreation of achievement from memory","beat idk with no misses.",				'idk_fc',				false],
		["Get Me Out of Here",			"Beat Torture with no Misses.",						'torture_fc',			false],
		["FUUUUUUUUU-",					"Beat Sage with no Misses.",						'sage_fc',				false],
		["You\'re a Cancer",			"Beat Infitrigger with 2 or less misses.",			'infitrigger_2miss',	false],
		["Ebola Immunity",				"Press at Least 5 Ebloa Notes and Beat Infitrigger.",'ebola_immune',		false],
		["I\'m Tired of These Motherfucking Rappers on this Motherfucking Map","Beat Honorbound with at least 98% accuracy.",'honorbound_98acc',false],
		["I Did What I Could!",			"Beat Eyelander with at least 98% accuracy.",		'eyelander_98acc',		false],
		["How Could This Happen?",		"Beat Strongmann at least 95% accuracy.",			'strongmann_95acc',		false],
		["[Freeplay Acheivement]",		"Beat Recursed with no Misses.",					'recursed_fc',			false],
		["Fruit Master",				"Beat Bombastic with at least 98% accuracy.",		'bombastic_95acc',		false],
		["nermal",						"be better than garfield (fc abuse).",				'abuse_fc',				false],
		["Middle Finger x6",			"Beat Attack with at least 98% accuracy.",			'attack_98acc',			false],
		["You\'ll Get There Eventually","Get Blueballed 100 times in one song.",			'blueballed_100',		true],
		["6 Key Isn\'t For Me",			"Beat Any Song (Except for Bopeebo) While Only Using 4 Keys.",'fourkeyonly',false],
		["insanity",					"Beat Any Song (Except for Bopeebo) With the Follwing Modifiers\n Instakill On Miss, Fade Out, Fade In, Drunk Game, and Pendulum Mode.",'insanity',false]
	];
	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();

	public static var henchmenDeath:Int = 0;
	public static function unlockAchievement(name:String):Void {
		FlxG.log.add('Completed achievement "' + name +'"');
		achievementsMap.set(name, true);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	}

	public static function relockAchievement(name:String):Void {
		FlxG.log.add('Reset achievement "' + name +'"');
		achievementsMap.set(name, false);
	}

	public static function isAchievementUnlocked(name:String) {
		if(achievementsMap.exists(name) && achievementsMap.get(name)) {
			return true;
		}
		return false;
	}

	public static function getAchievementIndex(name:String) {
		for (i in 0...achievementsStuff.length) {
			if(achievementsStuff[i][2] == name) {
				return i;
			}
		}
		return -1;
	}

	public static function loadAchievements():Void {
		if(FlxG.save.data != null) {
			if(FlxG.save.data.achievementsMap != null) {
				achievementsMap = FlxG.save.data.achievementsMap;
			}
			if(henchmenDeath == 0 && FlxG.save.data.henchmenDeath != null) {
				henchmenDeath = FlxG.save.data.henchmenDeath;
			}
		}
	}
}

class AttachedAchievement extends FlxSprite {
	public var sprTracker:FlxSprite;
	private var tag:String;
	public function new(x:Float = 0, y:Float = 0, name:String) {
		super(x, y);

		changeAchievement(name);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function changeAchievement(tag:String) {
		this.tag = tag;
		reloadAchievementImage();
	}

	public function reloadAchievementImage() {
		if(Achievements.isAchievementUnlocked(tag)) {
			loadGraphic(Paths.image('achievements/' + tag));
		} else {
			loadGraphic(Paths.image('achievements/lockedachievement'));
		}
		scale.set(0.7, 0.7);
		updateHitbox();
	}

	override function update(elapsed:Float) {
		if (sprTracker != null)
			setPosition(sprTracker.x - 130, sprTracker.y + 25);

		super.update(elapsed);
	}
}

class AchievementObject extends FlxSpriteGroup {
	public var onFinish:Void->Void = null;
	var alphaTween:FlxTween;
	public function new(name:String, ?camera:FlxCamera = null)
	{
		super(x, y);
		ClientPrefs.saveSettings();

		var id:Int = Achievements.getAchievementIndex(name);
		var achievementBG:FlxSprite = new FlxSprite(60, 50).makeGraphic(420, 120, FlxColor.BLACK);
		achievementBG.scrollFactor.set();

		var achievementIcon:FlxSprite = new FlxSprite(achievementBG.x + 10, achievementBG.y + 10).loadGraphic(Paths.image('achievements/' + name));
		achievementIcon.scrollFactor.set();
		achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
		achievementIcon.updateHitbox();
		achievementIcon.antialiasing = ClientPrefs.globalAntialiasing;

		var achievementName:FlxText = new FlxText(achievementIcon.x + achievementIcon.width + 20, achievementIcon.y + 16, 280, Achievements.achievementsStuff[id][0], 16);
		achievementName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementName.scrollFactor.set();

		var achievementText:FlxText = new FlxText(achievementName.x, achievementName.y + 32, 280, Achievements.achievementsStuff[id][1], 16);
		achievementText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementText.scrollFactor.set();

		add(achievementBG);
		add(achievementName);
		add(achievementText);
		add(achievementIcon);

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) {
			cam = [camera];
		}
		alpha = 0;
		achievementBG.cameras = cam;
		achievementName.cameras = cam;
		achievementText.cameras = cam;
		achievementIcon.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
				startDelay: 2.5,
				onComplete: function(twn:FlxTween) {
					alphaTween = null;
					remove(this);
					if(onFinish != null) onFinish();
				}
			});
		}});
	}

	override function destroy() {
		if(alphaTween != null) {
			alphaTween.cancel();
		}
		super.destroy();
	}
}