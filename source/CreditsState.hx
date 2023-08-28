package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		#if MODS_ALLOWED
		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var leMods:Array<String> = CoolUtil.coolTextFile(path);
			for (i in 0...leMods.length)
			{
				if(leMods.length > 1 && leMods[0].length > 0) {
					var modSplit:Array<String> = leMods[i].split('|');
					if(!Paths.ignoreModFolders.contains(modSplit[0].toLowerCase()) && !modsAdded.contains(modSplit[0]))
					{
						if(modSplit[1] == '1')
							pushModCreditsToList(modSplit[0]);
						else
							modsAdded.push(modSplit[0]);
					}
				}
			}
		}

		var arrayOfFolders:Array<String> = Paths.getModDirectories();
		arrayOfFolders.push('');
		for (folder in arrayOfFolders)
		{
			pushModCreditsToList(folder);
		}
		#end

		var pisspoop:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			['Ferret\'s 6 Key Recharts'],
			['TheRealFerret', 		't',				'Creator and recharter',			 							'https://www.youtube.com/channel/UCWNMz9fwKjLdQQb2vtSN3nA', 		'7400FF'],
			['Grantwo', 			'grant',			'Charted Heartbeat, two parts of Torture, Darnell Wet Fart, Invincible, Acceptance, Platforming, Thriller Gen, Trinity, I Am God, and Superscare',			 				'https://gamebanana.com/members/1791708', 							'A5004C'],
			['Comedy_Individual', 	't',				'Charted two parts of Torture',			 								'https://www.youtube.com/channel/UCm2n4I1Lx-2CXYfZ618iOYg', 		'7400FF'],
			[''],
			['Psych Engine Extra Keys'],
			['tposejank', 			'tposejank',		'Actitud Positiva',			 									'https://www.youtube.com/channel/UCNdhmFe3BXu-Ff2DZ4loYvQ', 		'B9AF27'],	//mensajes subliminales
			['srPerez', 			'perez', 			'1-9 keys art', 												'https://twitter.com/NewSrPerez', 		'FF9E00'],
			[''],
			['Mods Used'],
			['V.S. Whitty - Definitive Edition','t','Ballistic, Ballistic (HQ)','https://gamebanana.com/mods/354884','7400FF'],

			['The Full-Ass Tricky Mod','t','Madness, Expurgation','https://gamebanana.com/mods/44334','7400FF'],

			['V.S Zardy','t','Foolhardy','https://gamebanana.com/mods/44366','7400FF'],

			['Friday Night Funkin\': Vs Matt','t','Sporting',	'https://gamebanana.com/mods/44511','7400FF'],

			['literally every fnf mod ever (Vs Bob)','t','Run, Onslaught','https://gamebanana.com/mods/285296','7400FF'],

			['VS Cheeky','t','Hard 2 Break, Bad Eggroll, Cornucopia, Bad Omen','https://fridaynightfunking.fandom.com/wiki/VS_Cheeky#Download_Links','7400FF'],

			['Friday Night Funkin\': Vs Selever 2.1','t','Attack','https://gamejolt.com/games/fnf-vs-selever/650777','7400FF'],

			['Vs Sonic.EXE 2.5 / 3.0 INCOMPLETE OFFICIAL RELEASE','t','Too Slow, Too Slow Encore, You Cant Run, Triple Trouble, Endless, Endless (Old), Cycles, Execution, 
			\nSunshine, Chaos, Faker, Black Sun, Fatality','https://gamebanana.com/mods/387978','7400FF'],

			['Friday Night Funkin\' D-Sides','t','Too Slow D-Side','https://gamebanana.com/mods/305122','7400FF'],

			['Friday Night Funkin\': Doki Doki Takeover Plus!','t','Epiphany','https://gamebanana.com/mods/47364','7400FF'],

			['Hypno\'s Lullaby V2','t','Lost Cause','https://fridaynightfunking.fandom.com/wiki/Friday_Night_Funkin%27_Lullaby#Download_Links','7400FF'],

			['Vs. Dave and Bambi','t','Recursed','https://gamebanana.com/mods/43201','7400FF'],

			['Tails Gets Trolled','t','No Villains, No Heroes','https://gamebanana.com/mods/320596','7400FF'],

			['VS IMPOSTOR V4','t','Reactor, Double Kill, Defeat, Defeat (Old), Heartbeat, Pretender, Insane Streamer, Idk, Torture','https://gamebanana.com/mods/55652','7400FF'],
			
			['Wednesday\'s Infidelity [PART 2]','t','Unknown Suffering, Unknown Suffering Remix','https://gamebanana.com/mods/343688','7400FF'],
			
			['Friday Night Fortress Vs Mann Co FULL RELEASE','t','Honorbound, Eyelander, Strongmann, Skill Issue','https://gamebanana.com/mods/322803','7400FF'],

			['Hit Single','t','Darnell Wet Fart','https://gamebanana.com/mods/395039','7400FF'],

			['Chaos Nightmare - Sonic Vs. Fleetway','t','Phantasm','https://gamebanana.com/mods/359046','7400FF'],

			['You Can\'t Delete GF. FNF: Vs GF.hx','t','Invincible','https://gamebanana.com/mods/393169','7400FF'],

			['Vs /v/-tan','t','Sage, Infitrigger','https://fridaynightfunking.fandom.com/wiki/Vs_/v/-tan#Download_Links','7400FF'],

			['SEEK\'S COOL DELTARUNE MOD','t','Hyperlink Reloaded','https://gamebanana.com/mods/377938','7400FF'],

			['Vs. Isaac (Version 2)','t','Acceptance, Delirious','https://gamebanana.com/mods/359071','7400FF'],	

			['Fruit Ninja Mod','t','Bombastic','https://gamebanana.com/mods/361650','7400FF'],

			['Nermal Nermal Nermallin\'','t','Abuse','https://gamebanana.com/mods/390154','7400FF'],

			['Platforming ERECT !!','t','Platforming','https://gamebanana.com/mods/445830','7400FF'],

			['Vs Rewrite (Sonic.exe)','t','Thriller Gen, Trinity','https://gamebanana.com/mods/417560','7400FF'],

			['vs OG SONIC.EXE?! (real) (joke mod)','t','I Am God','https://gamebanana.com/mods/407406','7400FF'],

			['FNF Vs Pibby Nightmare Evil','t','Superscare','https://gamebanana.com/mods/416486','7400FF'],
			
			['FNF Funny Mod','t','FNFGirl (go ask grant for the damn mod i aint giving it to you)','https://cdn.discordapp.com/attachments/1061080750671273994/1133478477543252140/funny.png','7400FF']
		];
		
		for(i in pisspoop){
			creditsStuff.push(i);
		}
	
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if(isSelectable) {
				if(creditsStuff[i][5] != null)
				{
					Paths.currentModDirectory = creditsStuff[i][5];
				}

				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Paths.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
			else optionText.alignment = CENTERED;
		}
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)) {
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}
		
		for (item in grpOptions.members)
		{
			if(!item.bold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if(item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
				}
				else
				{
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
				}
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int =  getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	#if MODS_ALLOWED
	private var modsAdded:Array<String> = [];
	function pushModCreditsToList(folder:String)
	{
		if(modsAdded.contains(folder)) return;

		var creditsFile:String = null;
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
		else creditsFile = Paths.mods('data/credits.txt');

		if (FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
		modsAdded.push(folder);
	}
	#end

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}