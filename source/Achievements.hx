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
		["go to the end of freeplay :3","Beat Bopeebo with every modifier\n(excluding Sick Only and invisible notes, opponent play is optional)",'oh_god',false],
		["Dull Fuse",					"Beat Ballistic with at least 95% accuracy.",		'ballistic_95acc',		false],
		["Back Allay Miami",			"Beat Ballistic (HQ) with at least 95% accuracy.",	'ballistichq_95acc',	false],
		["YOU CAN\'T KILL CLOWN!!!",	"Beat Madness with no Misses.",						'madness_fc',			false],
		["CLOWN KILLS YOU!!!",			"Beat Madness on Hell Mode with no Misses.",		'madness_hellfc',		false],
		["EXPURGATED",					"Beat Expurgation with at least 95% accuracy.",		'expurgation_95acc',	false],
		["Damn Brats in My Damn Maze",	"Beat Foolhardy with at least 95% accuracy.",		'foolhardy_95acc',		false],
		["A Worthy Opponent",			"Beat Sporting with at least 95% accuracy.",		'sporting_95acc',		false],
		["you cant run.",				"Beat Run.",										'run_complete',			false],
		["Can\'t Run While You Are Having Fun.","Beat Onslaught with at least 95% accuracy.",'onslaught_95acc',		false],
		["How are you alive???",		"Beat Hard 2 Break with at least 95% accuracy.",	'h2b_95acc',			false],
		["dream vs the rock",			"Beat Bad Eggroll with at least 95% accuracy.",		'eggroll_95acc',		false],
		["absolutely stoned",			"Beat Cornucopia with at least 95% accuracy.",		'cornucopia_95acc',		false],
		["AAAHHHHH",					"Beat Bad Omen with at least 95% accuracy.",		'badomen_95acc',		false],
		["Middle Finger x6",			"Beat Attack with at least 95% accuracy.",			'attack_95acc',			false],
		["Apperently Not Slow Enough",	"Beat Too Slow with at least 95% accuracy.",		'tooslow_95acc',		false],
		["Apperently Still Not Slow Enough","Beat Too Slow Encore with at least 95% accuracy.",'tooslowencore_95acc',false],
		["In the Notepad",				"Beat Too Slow D-Sides with at least 95% accuracy.",'tooslowdside_95acc',	false],
		["I did run",					"Beat You Can\'t Run with at least 95% accuracy.",	'ycr_95acc',			false],
		["like that one sonic game?!?!","Beat Triple Trouble with at least 90% accuracy.",	'tt_90acc',				false],
		["Too Bad Extra Lives Mean Nothing Here","Have all 100 Rings at the end of Triple Trouble.",'ringcollector_100',false],
		["Had to End Eventually",		"Beat Endless with at least 95% accuracy.",			'endless_95acc',		false],
		["Where the Fun Began",			"Beat Old Endless with at least 95% accuracy.",		'oldendless_95acc',		false],
		["Execution is Better",			"Beat Cycles with no Misses.",						'cycles_fc',			false],
		["Cycles is Better",			"Beat Execution with no Misses.",					'execution_fc',			false],
		["Why is It So Dark In Here?",	"Beat Sunshine with at least 95% accuracy.",		'sunshine_95acc',		false],
		["I didn\'t care about being better than the Boyfriend!","Beat Chaos with at least 95% accuracy.",'chaos_95acc',false],
		["Your Jordens are Fake.",		"Beat Faker with no Misses.",						'faker_fc',				false],
		["KILL",						"Beat Black Sun with at least 95% accuracy.",		'blacksun_95acc',		false],
		["That\'s not a homework folder...","Beat Fatality with at least 90% accuracy.",	'fatality_90acc',		false],
		["DEAR GOD THAT IS NOT A DEFINITELY NOT A HOMEWORK FOLDER","Beat Fatality on Hell Mode.",'fatality_hell',	false],
		["Successfully Verified Files", "Beat Epiphany with at least 95% accuracy.",		'epiphany_95acc',		false],
		["Found Cause",					"Beat Lost Cause with at least 95% accuracy.",		'lostcause_95acc',		false],
		["[Freeplay Acheivement]",		"Beat Recursed with no Misses.",					'recursed_fc',			false],
		["im so mad",					"Beat No Villains with at least 95% accuracy.",		'novillains_95acc',		false],
		["i quit",						"Beat No Heroes with at least 95% accuracy.",		'noheroes_95acc',		false],
		["Kablooey",					"Beat Reactor with at least 95% accuracy.",			'reactor_95acc',		false],
		["Against All Odds",			"Beat Double Kill with at least 95% accuracy.",		'doublekill_95acc',		false],
		["Undefeatable",				"Beat Defeat with no Misses.",						'defeat_fc',			false],
		["new friend!!!!",				"Beat Heartbeat with no Misses.",					'heartbeat_fc',			false],
		["Exposed",						"Beat Pretender with no Misses.",					'pretender_fc',			false],
		["merry halloween!!!",			"Beat Spookpostor with at least 95% accuracy.",		'spookpostor_95acc',	false],
		["Peep the Horror",				"Beat Insane Streamer with no Misses.",				'insanestreamer_fc',	false],
		["recreation of achievement from memory","beat idk with no misses.",				'idk_fc',				false],
		["Get Me Out of Here",			"Beat Torture with no Misses.",						'torture_fc',			false],
		["I\'m Tired of These Motherfucking Rappers","Beat Honorbound with at least 95% accuracy.",'honorbound_95acc',false],
		["I Did What I Could!",			"Beat Eyelander with at least 95% accuracy.",		'eyelander_95acc',		false],
		["How Could This Happen?",		"Beat Strongmann with at least 95% accuracy.",		'strongmann_95acc',		false],
		["Good shot mate!",				"Discover and survive to the end of Skill Issue.",	'skillissue_unlock',	false],
		["Bold or Brash",				"Beat Darnell Wet Fart with no Misses.",			'darnellfart_fc',		false],
		["Get Out of My Head",			"Beat Phantasm with least 95% accuracy.",			'phantasm_95acc',		false],
		["Deleted GF Anyway",			"Beat Invincible with least 95% accuracy.",			'invincible_95acc',		false],
		["FUUUUUUUUU-",					"Beat Sage with no Misses.",						'sage_fc',				false],
		["You\'re a Cancer",			"Beat Infitrigger with 2 or less misses.",			'infitrigger_2miss',	false],
		["Ebola Immunity",				"Press at Least 5 Ebloa Notes and Beat Infitrigger.",'ebola_immune',		false],
		["BIG SHOT", 					"Beat Hyperlink Reloaded with at least 95% accuracy.",'hyperlink2_95acc', 	false],
		["The Biggest Shot", 			"Beat Hyperlink Reloaded on Hell Mode with no Misses.",'hyperlink2_hellfc', false],
		["Redemption",					"Beat Acceptance with no Misses.",					'acceptance_fc',		false],
		["Reality Check",				"Beat Delirious with least 95% accuracy.",			'delirious_95acc',		false],
		["Fruit Master",				"Beat Bombastic with at least 95% accuracy.",		'bombastic_95acc',		false],
		["nermal",						"be better than garfield (fc abuse).",				'abuse_fc',				false],
		["it\'s irios",					"Beat Platforming with no Misses.",					'platforming_fc',		false],
		["Guess you\'re not flawed",	"Beat Thriller Gen with no Misses.",				'thriller_fc',			false],
		["The cliche never died.",		"Beat Trinity with at least 90% accuracy.",			'trinity_90acc',		false],
		["Too bad I\'m Atheist.",		"Beat I Am God with at least 95% accuracy.",		'iamgod_95acc',			false],
		["Gotta admit it\'s pretty scary.","Beat Superscare with at least 95% accuracy.",	'superscare_95acc',		false],
		["im sorry grant made me do it","Beat FNFGirl with at least 95% accuracy.",			'fnfgirl_95acc',		true],
		["You\'ll Get There Eventually","Get Blueballed 100 times in one song.",			'blueballed_100',		false],
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