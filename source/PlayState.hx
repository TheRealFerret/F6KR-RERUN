package;

import GameJolt.GameJoltAPI;
import haxe.Timer;
import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRandom;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import animateatlas.AtlasFrameMaker;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import Conductor.Rating;
import AttachedText;

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if VIDEOS_ALLOWED
import vlc.MP4Handler;
#end

import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.BaseScaleMode;

using StringTools;

class PlayState extends MusicBeatState
{
	var heartsImage:FlxSprite;
	var pinkVignette:FlxSprite;
	var pinkVignette2:FlxSprite;
	var vignetteTween:FlxTween;
	var whiteTween:FlxTween;
	var pinkCanPulse:Bool = false;
	var heartColorShader:ColorShader = new ColorShader(0);
	var heartEmitter:FlxEmitter;

	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var momMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var momMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	public var modchartTexts:Map<String, ModchartText> = new Map();
	public var modchartSaves:Map<String, FlxSave> = new Map();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var MOM_X:Float = 100;
	public var MOM_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var momGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	var vtanSong:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var mom:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	public var flippedHealthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	public static var mania:Int = 0;
	
	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var healthDrain:Float = 0;
	var healthDrainMod:Bool = false;
	public var instakillOnMiss:Bool = false;
	public var sickOnly:Bool = false;
	public var fadeOut:Bool = false;
	var fadeOutBlack:FlxSprite;
	var fadeOutBlack2:FlxSprite;
	public var fadeIn:Bool = false;
	var fadeInBlack:FlxSprite;
	var fadeInBlack2:FlxSprite;
	public var drunkGame:Bool = false;
	public var pussyMode:Bool = false;
	public var hellMode:Bool = false;
	public var pendulumMode:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camNotes:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleSmokes:FlxSpriteGroup;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:FlxSprite;
	var phillyWindowEvent:BGSprite;
	var trainSound:FlxSound;

	var phillyGlowGradient:PhillyGlow.PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlow.PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;
	public var defaultHudCamZoom:Float = 1.0;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;
	var barSongLength:Float = 0;

	private var task:TaskSong;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	var opponent2sing:Bool = false;
	var bothOpponentsSing:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	var precacheList:Map<String, String> = new Map<String, String>();
	
	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	//v-tan
	public var yotsu:FlxSprite = new FlxSprite();
	public var man:FlxSprite = new FlxSprite();
	public var trv:FlxSprite = new FlxSprite();
	public var xtan:FlxSprite = new FlxSprite();
	public var chinkMoot:FlxTypedGroup<FakeMoot>;
	public var vrtan1:FlxSprite = new FlxSprite();
	public var vrtan2:FlxSprite = new FlxSprite();
	public var FUCK:FlxSprite = new FlxSprite();
	public static var noo:Int = 1; 

	public var ebolabitch:FlxSprite = new FlxSprite();
	public var housesmoke:FlxSprite = new FlxSprite();
	public var yotsuPANIC:FlxSprite = new FlxSprite();
	public var r9k:FlxSprite = new FlxSprite();
	public var cat:FlxSprite = new FlxSprite();
	public var blackguy:FlxSprite = new FlxSprite();
	public var unsmile:FlxSprite = new FlxSprite();
	public var scaredyo:FlxSprite = new FlxSprite();
	public var aaaaa:FlxSprite = new FlxSprite();
	public var blackboi:FlxSprite;

	public static var inScene:Bool = true;////to fix the fucked up camera at the intro
	var totalEbolaNotesHit:Int = 0;
	//f6kr
	public var laneunderlay:FlxSprite;
	var gameFont:String;
	var healthBarFlipped:Bool = false;
	var noCountdown:Bool = false;
	//tgt
	var stageCurtains:FlxSprite;

	//zardy
	var zardyBackground:FlxSprite;

	//tricky
	var tstatic:BGSprite;
	var tStaticSound:FlxSound = new FlxSound().loadEmbedded(Paths.sound("staticSound","preload"));
	var MAINLIGHT:FlxSprite;
	var daSign:FlxSprite;
	var gramlan:FlxSprite;
	var exSpikes:FlxSprite;

	public var TrickyLinesSing:Array<String> = ["SUFFER","INCORRECT", "INCOMPLETE", "INSUFFICIENT", "INVALID", "CORRECTION", "MISTAKE", "REDUCE", "ERROR", "ADJUSTING", "IMPROBABLE", "IMPLAUSIBLE", "MISJUDGED"];
	public var ExTrickyLinesSing:Array<String> = ["YOU AREN'T HANK", "WHERE IS HANK", "HANK???", "WHO ARE YOU", "WHERE AM I", "THIS ISN'T RIGHT", "MIDGET", "SYSTEM UNRESPONSIVE", "WHY CAN'T I KILL?????"];
	public var TrickyLinesMiss:Array<String> = ["TERRIBLE", "WASTE", "MISS CALCULTED", "PREDICTED", "FAILURE", "DISGUSTING", "ABHORRENT", "FORESEEN", "CONTEMPTIBLE", "PROGNOSTICATE", "DISPICABLE", "REPREHENSIBLE"];

	//mann co
	var songIsWeird:Bool = false;
	var soldierShake:Bool = false;
	var slashThingie:Bool = false;
	private var shakeCam:Bool = false;
	var tf2Font:Bool = false;
	var chatUsername:String;
	var chatText:String;
	var usernameTxt:FlxText;
	var chatTxt:FlxText;
	var weee:Bool = false;
	var normal:Bool = false;
	var randomUsername:Array<String> = [ //picks a random username to display in chat -heat
		'Shtek543',
		'Bigduck6443',
		'Feetlover5',
		'Taylor',
		'Jurgenchung',
		'Sugmadickus',
		'I-like-ass543',
		'Maurice',
		'heat',
		'TobTheDev',
		'Engineer Gaming',
		'Scout Gaming',
		'Spy Gaming',
		'Heavy gaming',
		'Pyro Gaming',
		'Demo Gaming',
		'Medic Gaming',
		'Soldier Gaming',
		'Sniper gaming',
		'funny engineer',
		'Your Mother',
		'FNF Girlfriend',
		'Medicore cole',
		'Tricky from FNF' // OMG GUYS ITS TRICKY FROM FNF!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! lmao
	];
	var randomText:Array<String> = [ //picks a random message to display in the chat -heat. // ok. -tob
		"I love Children So Much!!!",
		"I hate MrBreast",
		"I love Non-fungible tokens",
		"I play Genshin Impact",
		"Medick from tf2 is so sexy",
		"fuck off",
		"guys anyone got a duped shovel",
		"heavy is dead",
		"pootis",
		"Spy!",
		"Selling unusual for 1 quadrillion keys pls buy",
		"This mod is hard, Im going to compare it to MFM to make myself feel better."
	];

	//daveandbambi
	//recursed

	public var elapsedtime:Float = 0;

	var darkSky:FlxSprite;
	var darkSky2:FlxSprite;
	var darkSkyStartPos:Float = 1280;
	var resetPos:Float = -2560;
	var freeplayBG:BGSprite;
	var charBackdrop:FlxBackdrop;
	var alphaCharacters:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();
	var daveSongs:Array<String> = ['House', 'Insanity', 'Polygonized', 'Bonus Song'];
	var bambiSongs:Array<String> = ['Blocked', 'Corn-Theft', 'Maze', 'Mealie'];
	var tristanSongs:Array<String> = ['Adventure', 'Vs-Tristan'];
	var tristanInBotTrot:BGSprite; 

	var missedRecursedLetterCount:Int = 0;
	var recursedCovers:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var isRecursed:Bool = false;
	var recursedUI:FlxTypedGroup<FlxObject> = new FlxTypedGroup<FlxObject>();

	var timeLeft:Float;
	var timeGiven:Float;
	var timeLeftText:FlxText;

	var noteCount:Int;
	var notesLeft:Int;
	var notesLeftText:FlxText;

	var preRecursedHealth:Float;
	var preRecursedSkin:String;
	var rotateCamToRight:Bool;
	var camRotateAngle:Float = 0;

	var rotatingCamTween:FlxTween;

	//hypno
	var hypnoEntrance:FlxSprite;
	var hypnoJumpscare:FlxSprite;

	public var pendulum:FlxSprite;
	var tranceThing:FlxSprite;
	var tranceDeathScreen:FlxSprite;
	var pendulumShadow:FlxTypedGroup<FlxSprite>;
	var psyshockParticle:FlxSprite;	
	var cameraFlash:FlxSprite;

	public var tranceActive:Bool = false;
	public var tranceNotActiveYet:Bool = false;
	public var fadePendulum:Bool = false;

	public static var flashGraphic:FlxGraphic;
	var tranceSound:FlxSound;
	var tranceCanKill:Bool = true;
	var pendulumOffset:Float = 0;
	var psyshockCooldown:Int = 80;
	var keyboardTimer:Int = 8;
	var keyboard:FlxSprite;
	var skippedFirstPendulum:Bool = false;
	var trance:Float = 0;
	var reducedDrain:Float = 3;

	//sussy
	var flashSprite:FlxSprite;

		//double kill
		var cargoDark:FlxSprite;
		var cargoDarkFG:FlxSprite;
		var cargoAirsip:FlxSprite;
		var cargoDarken:Bool;
		var cargoReadyKill:Bool;
		var showDlowDK:Bool;

		var lightoverlayDK:FlxSprite;
		var mainoverlayDK:FlxSprite;
		var defeatDKoverlay:FlxSprite;
		
		// defeat
		var defeatthing:FlxSprite;
		var defeatblack:FlxSprite;
		var bodiesfront:FlxSprite;
		var bodies2:FlxSprite;
		var bodies:FlxSprite;
		var lightoverlay:FlxSprite;
		var defeatDark:Bool = false;

		// pink
		var cloud1:FlxBackdrop;
		var cloud2:FlxBackdrop;
		var cloud3:FlxBackdrop;
		var cloud4:FlxBackdrop;
		var cloudbig:FlxBackdrop;
		var greymira:FlxSprite;
		var cyanmira:FlxSprite;
		var limemira:FlxSprite;
		var bluemira:FlxSprite;
		var pot:FlxSprite;
		var oramira:FlxSprite;
		var vines:FlxSprite;

		var ventNotSus:FlxSprite;
		var greytender:FlxSprite;
		var pretenderDark:FlxSprite;
		var noootomatomongus:FlxSprite;
		var longfuckery:FlxSprite;

		var gfDeadPretender:FlxSprite;

		// reactor
		var amogus:FlxSprite;
		var dripster:FlxSprite;
		var yellow:FlxSprite;
		var brown:FlxSprite;
		var ass2:FlxSprite;
		var ass3:FlxSprite;
		var orb:FlxSprite = new FlxSprite();
		var toogusorange:FlxSprite;
		var tooguswhite:FlxSprite;
		var toogusblue:FlxSprite;

		// jerma
		var scaryJerma:FlxSprite;

		var noteRows:Array<Array<Array<Note>>> = [[],[]];

		var extraZoom:Float = 0;

		var camBopInterval:Int = 4;
		var camBopIntensity:Float = 1;

		var twistShit:Float = 1;
		var twistAmount:Float = 1;
		var camTwistIntensity:Float = 0;
		var camTwistIntensity2:Float = 3;
		var camTwist:Bool = false;

		// torture
		var ROZEBUD_ILOVEROZEBUD_HEISAWESOME:FlxSprite; // this is the var name and you can't stop me -rzbd
		var torfloor:FlxSprite;
		var torwall:FlxSprite;
		var torglasses:FlxSprite;
		var windowlights:FlxSprite;
		var leftblades:FlxSprite;
		var rightblades:FlxSprite;
		var montymole:FlxSprite;
		var torlight:FlxSprite;
		var startDark:FlxSprite;
		var ziffyStart:FlxSprite;
		var bladeDistance:Float = 120;

	//isaac 
		// blue shit
		var IsaacInChest:FlxSprite;
		var House:FlxSprite;
		var end:FlxSprite;
		var chestidle:FlxSprite;
		var GFdisappointed:FlxSprite;
		var trashitem:FlxSprite;
		var rain:FlxSound;
		public var canhitspace:Bool = false;
		var canblind:Bool = false;
		var songending:Bool = false; 

		// delirium
		var introText:FlxSprite;
		var basementvoid:FlxSprite;
		var chestvoid:FlxSprite;
		var drvoid:FlxSprite;
		var effectTween:FlxTween;
		var effectTween2:FlxTween;
		var effectTween3:FlxTween;
		var delistatic:FlxSprite;
		var portal:FlxSprite;
		var staticlol:FlxSprite;
		var arroweffect:MosaicEffect = new MosaicEffect();

	// vs exe
	public static var isFixedAspectRatio:Bool = false;
	var blackFuck:FlxSprite;
	var blackFuck2:FlxSprite;
	var whiteFuck:FlxSprite;
	var startCircle:FlxSprite;
	var startText:FlxSprite;

	public var ringsNumbers:Array<SonicNumber>=[];
	public var minNumber:SonicNumber;
	public var sonicHUD:FlxSpriteGroup;
	public var scoreNumbers:Array<SonicNumber>=[];
	public var missNumbers:Array<SonicNumber>=[];
	public var secondNumberA:SonicNumber;
	public var secondNumberB:SonicNumber;
	public var millisecondNumberA:SonicNumber;
	public var millisecondNumberB:SonicNumber;

	public var sonicHUDSongs:Array<String> = [
		// "my-horizon",
		// "our-horizon",
		// "prey",
		// "you-cant-run", // for the pixel part in specific
		"fatality",
		// "b4cksl4sh",
	];

	var hudStyle:String = 'sonic2';
	public var sonicHUDStyles:Map<String, String> = [

		"fatality" => "sonic3",
		// "prey" => "soniccd",
		// "you-cant-run" => "sonic1", // because its green hill zone so it should be sonic1
		// "our-horizon" => "chaotix",
		// "my-horizon" => "chaotix"
		// "songName" => "styleName",

		// styles are sonic2 and sonic3
		// defaults to sonic2 if its in sonicHUDSongs but not in here
	];
		// mazin stuff
		var fgmajin:BGSprite;
		var fgmajin2:BGSprite;
		// fatal error shit
		var base:FlxSprite;
		var domain:FlxSprite;
		var domain2:FlxSprite;
		var trueFatal:FlxSprite;
			// mechanic shit + moving funne window for fatal error
			var windowX:Float = Lib.application.window.x;
			var windowY:Float = Lib.application.window.y;
			var Xamount:Float = 0;
			var Yamount:Float = 0;
			var IsWindowMoving:Bool = false;
			var IsWindowMoving2:Bool = false;
			var errorRandom:FlxRandom = new FlxRandom(666); // so that every time you play the song, the error popups are in the same place

		// tails doll
		var flooooor:FlxSprite;
		var flyState:String = '';
		var flyTarg:Character;
		var floaty:Float = 0;
		var floaty2:Float = 0;
		//fleetways shit
		var wall:FlxSprite;
		var porker:FlxSprite;
		var thechamber:FlxSprite;
		var floor:FlxSprite;
		var fleetwaybgshit:FlxSprite;
		var emeraldbeam:FlxSprite;
		var emeraldbeamyellow:FlxSprite;
		var pebles:FlxSprite;
		var warning:FlxSprite;
		var dodgething:FlxSprite;	
		var canDodge:Bool = false;
		var dodging:Bool = false;
		var topBar:FlxSprite;
		var bottomBar:FlxSprite;	
		// sonic.exe
		public var supersuperZoomShit:Bool = false;
		var pickle:FlxSprite;
		var fgTrees:BGSprite;
		var genesis:FlxTypedGroup<FlxSprite>;
		var daNoteStatic:FlxSprite;
		// faker!?!?!
		var fakertransform:FlxSprite;
		var vgblack:FlxSprite;
		var tentas:FlxSprite;
		var heatlhDrop:Float = 0;
		// old x
		var hands:FlxSprite;
		var tree:FlxSprite;
		var eyeflower:FlxSprite;
		//in the notepad
		var fakeTooSlow:BGSprite;
		var urTooSlow:BGSprite;
		var blackFade:FlxSprite;
		public var frozenBF:FlxSprite;
		var indicatorTween:FlxTween;
		var frozenIndicators:FlxSpriteGroup;
		var leftIndicator:FlxSprite;
		var rightIndicator:FlxSprite;
		var freezeCounter:Int = 0;
		var maxFreeze:Int = 4;

	var trintiywarning:FlxText;

	var debugMode:Bool = false;

	var curShader:ShaderFilter;

	override public function create()
	{
		#if debug
		debugMode = true;
		#end

		chatUsername = randomUsername[FlxG.random.int(0, randomUsername.length -1)] + ":";
		chatText = randomText[FlxG.random.int(0, randomText.length -1)];
		
		//trace('Playback Rate: ' + playbackRate);
		Paths.clearStoredMemory();

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		keysArray = EKData.Keybinds.fill();

		resetSpookyText = true;
		var cover:BGSprite = new BGSprite('expurgation/cover', -180, 755, 0.9, 0.9);
		var hole:BGSprite = new BGSprite('expurgation/Spawnhole_Ground_BACK', 50, 530, 0.9, 0.9);
		var converHole:BGSprite = new BGSprite('expurgation/Spawnhole_Ground_COVER', 7,578, 0.9, 0.9);
		TrickyLinesSing = CoolUtil.coolTextFile(Paths.txt('trickySingStrings'));
		TrickyLinesMiss = CoolUtil.coolTextFile(Paths.txt('trickyMissStrings'));
		ExTrickyLinesSing = CoolUtil.coolTextFile(Paths.txt('trickyExSingStrings'));

		trintiywarning = new FlxText(0, 500, FlxG.width, "WARNING:\n Trinity can experience crashes when played on framerates above 60.\n You have been warned.", 32);
		trintiywarning.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		trintiywarning.scrollFactor.set();
		trintiywarning.alpha = 0;
		trintiywarning.borderSize = 2;
		add(trintiywarning);

		fakertransform = new FlxSprite(100 - 10000, 100 - 10000);
		fakertransform.frames = Paths.getSparrowAtlas('Exe/Faker_Transformation');
		fakertransform.animation.addByPrefix('1', 'TransformationRIGHT instance 1');
		fakertransform.animation.addByPrefix('2', 'TransformationLEFT instance 1');
		fakertransform.animation.addByPrefix('3', 'TransformationUP instance 1');
		fakertransform.animation.addByPrefix('4', 'TransformationDOWN instance 1');
		fakertransform.animation.play('1', true);
		fakertransform.animation.play('2', true);
		fakertransform.animation.play('3', true);
		fakertransform.animation.play('4', true);
		fakertransform.alpha = 0;

		//Ratings
		ratingsData.push(new Rating('sick')); //default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		healthDrain = ClientPrefs.getGameplaySetting('healthdrain', 0);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		sickOnly = ClientPrefs.getGameplaySetting('sickonly', false);
		fadeOut = ClientPrefs.getGameplaySetting('fadeout', false);
		fadeIn = ClientPrefs.getGameplaySetting('fadein', false);
		drunkGame = ClientPrefs.getGameplaySetting('drunkgame', false);
		pussyMode = ClientPrefs.getGameplaySetting('pussymode', false);
		hellMode = ClientPrefs.getGameplaySetting('hellmode', false);
		pendulumMode = ClientPrefs.getGameplaySetting('pendulummode', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		if (healthDrain > 0)
			healthDrainMod = true;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camNotes = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camNotes.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camNotes, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;
		missLimited = false;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		mania = SONG.mania;
		if (mania < Note.minMania || mania > Note.maxMania)
			mania = Note.defaultMania;

		trace("song keys: " + (mania + 1) + " / mania value: " + mania);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray[mania].length)
			{
				keysPressed.push(false);
			}

		sonicHUD = new FlxSpriteGroup();
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		var s_termination = "s";
		if (mania == 0) s_termination = "";
		storyDifficultyText = " (" + CoolUtil.difficulties[storyDifficulty] + ", " + (mania + 1) + " key" + s_termination + ")";

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		topBar = new FlxSprite(0, -170).makeGraphic(1280, 170, FlxColor.BLACK);
		bottomBar = new FlxSprite(0, 720).makeGraphic(1280, 170, FlxColor.BLACK);
		blackFuck = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		blackFuck2 = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);

		startCircle = new FlxSprite();
		startText = new FlxSprite();

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		//trace('stage is: ' + curStage);
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				secondopp: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];
		MOM_X = stageData.secondopp[0];
		MOM_Y = stageData.secondopp[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		if (curSong.toLowerCase() == 'honorbound'||curSong.toLowerCase() == 'strongmann'||curSong.toLowerCase() == 'eyelander')
			boyfriendGroup = new FlxSpriteGroup(770, 450);
		else
			boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);

		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);

		momGroup = new FlxSpriteGroup(MOM_X, MOM_Y);

		if (curSong.toLowerCase() == 'honorbound'||curSong.toLowerCase() == 'strongmann'||curSong.toLowerCase() == 'eyelander')
			gfGroup = new FlxSpriteGroup(400, -300);
		else
			gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
				dadbattleSmokes = new FlxSpriteGroup(); //troll'd

			case 'spooky': //Week 2
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
				}
				add(halloweenBG);

				halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				//PRECACHE SOUNDS
				precacheList.set('thunder_1', 'sound');
				precacheList.set('thunder_2', 'sound');

			case 'philly': //Week 3
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}

				var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
				phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
				phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
				phillyWindow.updateHitbox();
				add(phillyWindow);
				phillyWindow.alpha = 0;

				if(!ClientPrefs.lowQuality) {
					var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BGSprite('philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				phillyStreet = new BGSprite('philly/street', -40, 50);
				add(phillyStreet);

			case 'limo': //Week 4
				var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 170, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					//PRECACHE SOUND
					precacheList.set('dancerdeath', 'sound');
				}

				limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BGSprite('limo/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': //Week 5 - Cocoa, Eggnog
				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				precacheList.set('Lights_Shut_off', 'sound');

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': //Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgSky.width * 6);
				if(!ClientPrefs.lowQuality) {
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if(!ClientPrefs.lowQuality) {
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if(!ClientPrefs.lowQuality) {
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': //Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				/*if(!ClientPrefs.lowQuality) { //Does this even do something?
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
				}*/
				var posX = 400;
				var posY = 200;
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}

			case 'tank': //Week 7 - Ugh, Guns, Stress
				var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
				add(sky);

				if(!ClientPrefs.lowQuality)
				{
					var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
					clouds.active = true;
					clouds.velocity.x = FlxG.random.float(5, 15);
					add(clouds);

					var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
					mountains.setGraphicSize(Std.int(1.2 * mountains.width));
					mountains.updateHitbox();
					add(mountains);

					var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
					buildings.setGraphicSize(Std.int(1.1 * buildings.width));
					buildings.updateHitbox();
					add(buildings);
				}

				var ruins:BGSprite = new BGSprite('tankRuins',-200,0,.35,.35);
				ruins.setGraphicSize(Std.int(1.1 * ruins.width));
				ruins.updateHitbox();
				add(ruins);

				if(!ClientPrefs.lowQuality)
				{
					var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
					add(smokeLeft);
					var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
					add(smokeRight);

					tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
					add(tankWatchtower);
				}

				tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5,['BG tank w lighting'], true);
				add(tankGround);

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				var ground:BGSprite = new BGSprite('tankGround', -420, -150);
				ground.setGraphicSize(Std.int(1.15 * ground.width));
				ground.updateHitbox();
				add(ground);
				moveTank();

				foregroundSprites = new FlxTypedGroup<BGSprite>();
				foregroundSprites.add(new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']));
				foregroundSprites.add(new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']));
				foregroundSprites.add(new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']));

			case 'chantown':
					{
						var scrollshit:Float = 0.62;
						//
						var whitebg:FlxSprite = new FlxSprite(-375,-133).loadGraphic(Paths.image('V/whitebg','shared'));
						
						//
						var mountains:FlxSprite = new FlxSprite(-325,27).loadGraphic(Paths.image('V/mountains','shared'));
							mountains.scrollFactor.set(0.4, 0.4);				
						///
						var chantown:FlxSprite = new FlxSprite(-275,64).loadGraphic(Paths.image('V/homes','shared'));
							chantown.scrollFactor.set(0.6, 0.6);		
						///
							chinkMoot = new FlxTypedGroup<FakeMoot>();
						var bigBalls:FakeMoot = new FakeMoot(406,-75);
							bigBalls.scrollFactor.set(0.5, 0.5);			
							//
						var ground:FlxSprite = new FlxSprite(-309,498).loadGraphic(Paths.image('V/ground','shared'));					
							//
						var yotsuba = Paths.getSparrowAtlas('V/Backbros/yotsuba','shared');
							yotsu.frames = yotsuba;
							yotsu.animation.addByPrefix('standing', 'Ystanding' , 24);
							yotsu.animation.addByPrefix('sleeping',"Ysleeping", 24);
							yotsu.animation.addByPrefix('chilling',"Ysitting2", 24);
							//rare sprites 
							yotsu.animation.addByPrefix('sitting',"Ysitting0", 24);
							yotsu.animation.addByPrefix('dead',"ygrave", 24);						
							//
							yotsu.scale.set(0.85,0.85);							
							yotsu.scrollFactor.set(scrollshit, scrollshit);							
							yotsu.antialiasing =true;
							yotsu.updateHitbox();
							//
						var dumbman = Paths.getSparrowAtlas('V/Backbros/man','shared');
							man.frames = dumbman;
							man.animation.addByPrefix('lookaMan', 'man' ,24,false);
							man.scrollFactor.set(scrollshit, scrollshit);
							man.setPosition(145,296);
							man.updateHitbox();					
							//
						var xtanf = Paths.getSparrowAtlas('V/Backbros/xtan','shared');
							xtan.frames = xtanf;
							xtan.animation.addByPrefix('peakan', 'xtans' ,24,false);
							xtan.scrollFactor.set(scrollshit,scrollshit);
							xtan.setPosition(980,260);
							xtan.updateHitbox();
							xtan.scale.set(0.82,0.82);
							
							//
						var trvf = Paths.getSparrowAtlas('V/Backbros/trv','shared');
							trv.frames = trvf;
							trv.animation.addByPrefix('walkan', 'trv' ,24,false);
							trv.scrollFactor.set(scrollshit, scrollshit);
							trv.setPosition(232,280);
							trv.scale.set(0.8,0.8);
							trv.updateHitbox();
						
						///layering						
						add(whitebg);	
						if (SONG.song == 'Sage'){add(trv);}
						add(mountains);				
						add(chinkMoot);
						chinkMoot.add(bigBalls);
						add(chantown);
						add(ground);
						add(yotsu);
						add(man);				
						add(xtan);		
						
						var choosesprite = FlxG.random.int(1,10);//rare ?

						if (SONG.song == 'Sage')
							{															
						
								if (choosesprite == 5){yotsu.animation.play("sitting");	yotsu.setPosition(600,295);	}
								else{yotsu.animation.play("chilling");yotsu.setPosition(600,309);}																									
						
							}
						
						var fuu =  Paths.getSparrowAtlas('V/v/fuck','shared');
							FUCK.frames = fuu;
							FUCK.animation.addByPrefix('FFFFUU','vrage_ffff',24,false);
						
						var vr1 = Paths.getSparrowAtlas('V/Backbros/vr','shared');
							vrtan1.frames = vr1;
							vrtan1.animation.addByPrefix('walkan', 'vr', 24, false);					
							vrtan1.setPosition(-300,350);
							vrtan1.scale.set(1.3,1.3);
						var vr2 = Paths.getSparrowAtlas('V/Backbros/vr2','shared');
							vrtan2.frames = vr2;
							vrtan2.animation.addByPrefix('funkan', 'vr2', 24, true);					
							vrtan2.setPosition(vrtan1.x,vrtan1.y);
							vrtan2.scale.set(1.3,1.3);
						
					
					}
			case 'hillzoneSonic':
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('chapter2/sky'));
				bg.scrollFactor.set(0.4, 0.4);
				bg.active = false;
				add(bg);
				
				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('chapter2/grass'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);
				
				stageCurtains = new FlxSprite(-450, -150).loadGraphic(Paths.image('chapter2/foreground'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.87));
				stageCurtains.updateHitbox();
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;
			case 'zardy':
				zardyBackground = new FlxSprite(-600, -200);
				zardyBackground.frames = Paths.getSparrowAtlas('zardy/Maze');
				zardyBackground.animation.addByPrefix('Maze','Stage', 16);
				zardyBackground.antialiasing = ClientPrefs.globalAntialiasing;
				zardyBackground.scrollFactor.set(0.9, 0.9);
				zardyBackground.animation.play('Maze');
				add(zardyBackground);
			case 'boxing':
				var bg:FlxSprite = new FlxSprite(-400, -220).loadGraphic(Paths.image('boxing/bg_boxn'));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.scrollFactor.set(0.8, 0.8);
				bg.active = false;
				add(bg);
		
				var bg_r:FlxSprite = new FlxSprite(-810, -380).loadGraphic(Paths.image('boxing/bg_boxr'));
				bg_r.antialiasing = ClientPrefs.globalAntialiasing;
				bg_r.scrollFactor.set(1, 1);
				bg_r.active = false;
				add(bg_r);
			case 'bonus':
				defaultCamZoom = 0.95;
				//
				var whitebg:FlxSprite = new FlxSprite(-246,-181).loadGraphic(Paths.image('bonus/whitebg','shared'));
				//
				var mountains:FlxSprite = new FlxSprite(-120,-86).loadGraphic(Paths.image('bonus/mountains','shared'));			
				mountains.scrollFactor.set(0.5,0.5);
											
				//
				var house = Paths.getSparrowAtlas('bonus/house','shared');
				housesmoke.frames = house;
				housesmoke.animation.addByPrefix('house', 'house' ,24,true);
				housesmoke.animation.play('house');
				housesmoke.setPosition(382,-225);
				housesmoke.scrollFactor.set(0.9,0.9);
				//
				var ground:FlxSprite = new FlxSprite(-220,475).loadGraphic(Paths.image('bonus/base','shared'));
			
				///
				var yotsobaa = Paths.getSparrowAtlas('bonus/misc/yo','shared');
				scaredyo.frames = yotsobaa;
				scaredyo.animation.addByPrefix('aaaa', 'yotsuscaled' ,24,false);
				scaredyo.setPosition(housesmoke.x-150,ground.y-87);
						
						
						
						
				var botbro = Paths.getSparrowAtlas('bonus/misc/r9k','shared');
					r9k.frames = botbro;
					r9k.animation.addByPrefix('ded', 'r9k' ,24,false);
						
					r9k.setPosition(-150,0);					
				var blackbro = Paths.getSparrowAtlas('bonus/misc/black','shared');
					blackguy.frames = blackbro;
					blackguy.animation.addByPrefix('ded', 'black' ,24,false);
					blackguy.scale.set(1.2,1.2);
							
					blackguy.setPosition(-10,-10);					   									
				var smilebro = Paths.getSparrowAtlas('bonus/misc/smile','shared');
					unsmile.frames = smilebro;
					unsmile.animation.addByPrefix('ded', 'crawling' ,24,false);						
							
					unsmile.setPosition(-50,290);
				var catbro = Paths.getSparrowAtlas('bonus/misc/cat','shared');
					cat.frames = catbro;
					cat.animation.addByPrefix('ded', 'runnigcat' ,24,false);
					cat.scale.set(1.2,1.2);
							
					cat.setPosition(-60,-10);
				var autistic = Paths.getSparrowAtlas('bonus/can/scream','shared');	
					aaaaa.frames = autistic;			 
					aaaaa.animation.addByPrefix('aaaaaaaa','cancer_scream',24,false);
					aaaaa.scale.set(0.92,0.92);                
							
				    //layering
					add(whitebg);
					add(mountains);									
					add(housesmoke);													
					add(scaredyo);													
					add(ground);

			case 'nevada':
				tstatic = new BGSprite('expurgation/TrickyStatic', 320, 180, 0, 0);
				tstatic.setGraphicSize(Std.int(tstatic.width * 8.3));
				tstatic.animation.add('static', [0, 1, 2], 24, true);
				tstatic.animation.play('static');
	
				tstatic.alpha = 0;

				var bg:FlxSprite = new FlxSprite(-350, -300).loadGraphic(Paths.image('tricky/red','shared'));
				// bg.setGraphicSize(Std.int(bg.width * 2.5));
				// bg.updateHitbox();
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.scrollFactor.set(0.9, 0.9);

				var stageFront:FlxSprite = new FlxSprite(-1100, -460).loadGraphic(Paths.image('tricky/island_but_rocks_float'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.4));
				stageFront.antialiasing = ClientPrefs.globalAntialiasing;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);

				MAINLIGHT = new FlxSprite(-470, -150).loadGraphic(Paths.image('tricky/hue','shared'));
				MAINLIGHT.alpha - 0.3;
				MAINLIGHT.setGraphicSize(Std.int(MAINLIGHT.width * 0.9));
				MAINLIGHT.blend = "screen";
				MAINLIGHT.updateHitbox();
				MAINLIGHT.antialiasing = ClientPrefs.globalAntialiasing;
				MAINLIGHT.scrollFactor.set(1.2, 1.2);
			case 'barnblitz-heavy':
				var bg:FlxSprite = new FlxSprite(-400, -175).loadGraphic(Paths.image('fortress/bg/barnblitz2'));
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);
			case 'degroot':
				var bg:FlxSprite = new FlxSprite(-425, -155).loadGraphic(Paths.image('fortress/bg/degroot'));
				bg.screenCenter(); // dont know how to position your bg? simple! just use Bg.screenCenter()!
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);
			case 'freeplay':
				darkSky = new FlxSprite(darkSkyStartPos, 0, Paths.image('recursed/darkSky'));
				darkSky.scale.set((1 / defaultCamZoom) * 2, 1 / defaultCamZoom);
				darkSky.updateHitbox();
				darkSky.y = (FlxG.height - darkSky.height) / 2;
				add(darkSky);
				
				darkSky2 = new FlxSprite(darkSky.x - darkSky.width, 0, Paths.image('recursed/darkSky'));
				darkSky2.scale.set((1 / defaultCamZoom) * 2, 1 / defaultCamZoom);
				darkSky2.updateHitbox();
				darkSky2.x = darkSky.x - darkSky.width;
				darkSky2.y = (FlxG.height - darkSky2.height) / 2;
				add(darkSky2);

				freeplayBG = new BGSprite('recursed/backgrounds/Aadsta', 0, 0, 0, 0, true);
				freeplayBG.setGraphicSize(Std.int(freeplayBG.width * 2));
				freeplayBG.updateHitbox();
				freeplayBG.screenCenter();
				freeplayBG.color = FlxColor.multiply(0xFF4965FF, FlxColor.fromRGB(44, 44, 44));
				freeplayBG.alpha = 0;
				add(freeplayBG);
				
				charBackdrop = new FlxBackdrop(Paths.image('recursed/daveScroll'), 1, 1, true, true);
				charBackdrop.scale.set(2, 2);
				charBackdrop.screenCenter();
				charBackdrop.color = FlxColor.multiply(charBackdrop.color, FlxColor.fromRGB(44, 44, 44));
				charBackdrop.alpha = 0;
				add(charBackdrop);

				initAlphabet(daveSongs);

			case 'cave':
				var resizeBG:Float = 1;
				var background:FlxSprite = new FlxSprite(-450, -400);
				background.loadGraphic(Paths.image('hypno/cave/cave'));
				background.setGraphicSize(Std.int(background.width * resizeBG));
				background.updateHitbox();
				add(background);

				hypnoEntrance = new FlxSprite(585, -155);
				hypnoEntrance.frames = Paths.getSparrowAtlas('characters/hypno/ABOMINATION_HYPNO_ENTRANCE');
				hypnoEntrance.animation.addByPrefix('Entrance instance', "Entrance instance", 24, false);		
				add(hypnoEntrance);
				hypnoEntrance.visible = false;	
			
				hypnoJumpscare = new FlxSprite(75, -400);
				hypnoJumpscare.frames = Paths.getSparrowAtlas('characters/hypno/hypno_ending_sequence');
				hypnoJumpscare.animation.addByPrefix('ending', "Ending instance 1", 24, false);	
				hypnoJumpscare.setGraphicSize(Std.int(hypnoJumpscare.width * 0.67));	
				add(hypnoJumpscare);
				hypnoJumpscare.visible = false;	
			
			case 'defeat':
				GameOverSubstate.characterName = 'bf-defeat-dead';
				GameOverSubstate.deathSoundName = 'defeat_kill_sfx';
				GameOverSubstate.loopSoundName = 'gameover_v4_LOOP';
				GameOverSubstate.endSoundName = 'gameover_v4_End';

				defeatthing = new FlxSprite(-400, -150);
				defeatthing.frames = Paths.getSparrowAtlas('amogus/defeat/defeat');
				defeatthing.animation.addByPrefix('bop', 'defeat', 24, false);
				defeatthing.animation.play('bop');
				defeatthing.setGraphicSize(Std.int(defeatthing.width * 1.3));
				defeatthing.antialiasing = true;
				defeatthing.scrollFactor.set(0.8, 0.8);
				defeatthing.active = true;
				add(defeatthing);

				bodies2 = new FlxSprite(-500, 150).loadGraphic(Paths.image('amogus/defeat/lol thing'));
				bodies2.antialiasing = true;
				bodies2.setGraphicSize(Std.int(bodies2.width * 1.3));
				bodies2.scrollFactor.set(0.9, 0.9);
				bodies2.active = false;
				bodies2.alpha = 0;
				add(bodies2);

				bodies = new FlxSprite(-2760, 0).loadGraphic(Paths.image('amogus/defeat/deadBG'));
				bodies.setGraphicSize(Std.int(bodies.width * 0.4));
				bodies.antialiasing = true;
				bodies.scrollFactor.set(0.9, 0.9);
				bodies.active = false;
				bodies.alpha = 0;
				add(bodies);

				defeatblack = new FlxSprite().makeGraphic(FlxG.width * 4, FlxG.height + 700, FlxColor.BLACK);
				defeatblack.alpha = 0;
				defeatblack.screenCenter(X);
				defeatblack.screenCenter(Y);
				add(defeatblack);

				
				mainoverlayDK = new FlxSprite(250, 125).loadGraphic(Paths.image('amogus/defeat/defeatfnf'));
				mainoverlayDK.antialiasing = true;
				mainoverlayDK.scrollFactor.set(1, 1);
				mainoverlayDK.active = false;
				mainoverlayDK.setGraphicSize(Std.int(mainoverlayDK.width * 2));
				mainoverlayDK.alpha = 0;
				add(mainoverlayDK);
				

				bodiesfront = new FlxSprite(-2830, 0).loadGraphic(Paths.image('amogus/defeat/deadFG'));
				bodiesfront.setGraphicSize(Std.int(bodiesfront.width * 0.4));
				bodiesfront.antialiasing = true;
				bodiesfront.scrollFactor.set(0.5, 1);
				bodiesfront.active = false;
				bodiesfront.alpha = 0;

				missLimited = true;

			case 'defeatold':
				GameOverSubstate.characterName = 'bf-defeat-dead-old';
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-defeat';
				GameOverSubstate.loopSoundName = 'gameOver-defeat';
				GameOverSubstate.endSoundName = 'gameOverEnd-defeat';

				mainoverlayDK = new FlxSprite(250, 125).loadGraphic(Paths.image('amogus/defeat/defeatfnf'));
				mainoverlayDK.antialiasing = true;
				mainoverlayDK.scrollFactor.set(1, 1);
				mainoverlayDK.setGraphicSize(Std.int(mainoverlayDK.width * 2));
				add(mainoverlayDK);

				missLimited = true;

			case 'auditorHell':
				// GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				// GameOverSubstate.loopSoundName = 'gameOver-pixel';
				// GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				// GameOverSubstate.characterName = 'bf-pixel-dead';

				tstatic = new BGSprite('expurgation/TrickyStatic', 320, 180, 0, 0);
				tstatic.setGraphicSize(Std.int(tstatic.width * 8.3));
				tstatic.animation.add('static', [0, 1, 2], 24, true);
				tstatic.animation.play('static');
	
				tstatic.alpha = 0;

				var bg:BGSprite = new BGSprite('expurgation/bg', -10, -10, 1, 1);
				bg.setGraphicSize(Std.int(bg.width * 4));
				add(bg);
	
				var energyWall:BGSprite = new BGSprite('expurgation/Energywall', 1350, -690, 1, 1);
				add(energyWall);

				var stageFront:BGSprite = new BGSprite('expurgation/daBackground', -350, -355, 1, 1);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.55));
				add(stageFront);

				cover.setGraphicSize(Std.int(cover.width * 1.55));

				hole.setGraphicSize(Std.int(hole.width * 1.55));

				converHole.setGraphicSize(Std.int(converHole.width * 1.3));

				exSpikes = new FlxSprite(-350,-150);
				exSpikes.frames = Paths.getSparrowAtlas('expurgation/FloorSpikes','shared');
				exSpikes.visible = false;

				exSpikes.animation.addByPrefix('spike','Floor Spikes', 24, false);

				daSign = new FlxSprite(0,0);

				daSign.frames = Paths.getSparrowAtlas('expurgation/Sign_Post_Mechanic');

				daSign.setGraphicSize(Std.int(daSign.width * 0.67));
				add(daSign);
				remove(daSign);

				gramlan = new FlxSprite(0,0);

				gramlan.frames = Paths.getSparrowAtlas('expurgation/HP GREMLIN');

				gramlan.setGraphicSize(Std.int(gramlan.width * 0.76));
				add(gramlan);
				remove(gramlan);

			case 'honor':
				var bg:FlxSprite = new FlxSprite(-400, 0).loadGraphic(Paths.image('fortress/bg/honor'));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.screenCenter(); // dont know how to position your bg? simple! just use Bg.screenCenter()!
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

			case 'pretender': // pink stage
				GameOverSubstate.characterName = 'pretender';
				GameOverSubstate.loopSoundName = 'gameover_v4_LOOP';
				GameOverSubstate.endSoundName = 'gameover_v4_End';
				var bg:FlxSprite = new FlxSprite(-1500, -800).loadGraphic(Paths.image('amogus/mira/pretender/bg sky'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				var bg:FlxSprite = new FlxSprite(-1300, -100).loadGraphic(Paths.image('amogus/mira/pretender/cloud fathest'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				var bg:FlxSprite = new FlxSprite(-1300, 0).loadGraphic(Paths.image('amogus/mira/pretender/cloud front'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				cloud1 = new FlxBackdrop(Paths.image('amogus/mira/pretender/cloud 1'), 1, 1, true, true);
				cloud1.setPosition(0, -1000);
				cloud1.updateHitbox();
				cloud1.antialiasing = true;
				cloud1.scrollFactor.set(1, 1);
				add(cloud1);

				cloud2 = new FlxBackdrop(Paths.image('amogus/mira/pretender/cloud 2'), 1, 1, true, true);
				cloud2.setPosition(0, -1200);
				cloud2.updateHitbox();
				cloud2.antialiasing = true;
				cloud2.scrollFactor.set(1, 1);
				add(cloud2);

				cloud3 = new FlxBackdrop(Paths.image('amogus/mira/pretender/cloud 3'), 1, 1, true, true);
				cloud3.setPosition(0, -1400);
				cloud3.updateHitbox();
				cloud3.antialiasing = true;
				cloud3.scrollFactor.set(1, 1);
				add(cloud3);

				cloud4 = new FlxBackdrop(Paths.image('amogus/mira/pretender/cloud 4'), 1, 1, true, true);
				cloud4.setPosition(0, -1600);
				cloud4.updateHitbox();
				cloud4.antialiasing = true;
				cloud4.scrollFactor.set(1, 1);
				add(cloud4);

				cloudbig = new FlxBackdrop(Paths.image('amogus/mira/pretender/bigcloud'), 1, 1, true, true);
				cloudbig.setPosition(0, -1200);
				cloudbig.updateHitbox();
				cloudbig.antialiasing = true;
				cloudbig.scrollFactor.set(1, 1);
				add(cloudbig);

				var bg:FlxSprite = new FlxSprite(-1200, -750).loadGraphic(Paths.image('amogus/mira/pretender/ground'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				var bg:FlxSprite = new FlxSprite(0, -650).loadGraphic(Paths.image('amogus/mira/pretender/front plant'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				var bg:FlxSprite = new FlxSprite(1000, 230).loadGraphic(Paths.image('amogus/mira/pretender/knocked over plant'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				var bg:FlxSprite = new FlxSprite(-800, 260).loadGraphic(Paths.image('amogus/mira/pretender/knocked over plant 2'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				var deadmungus:FlxSprite = new FlxSprite(950, 250).loadGraphic(Paths.image('amogus/mira/pretender/tomatodead'));
				deadmungus.antialiasing = true;
				deadmungus.scrollFactor.set(1, 1);
				deadmungus.active = false;
				add(deadmungus);

				gfDeadPretender = new FlxSprite(0, 100);
				gfDeadPretender.frames = Paths.getSparrowAtlas('amogus/mira/pretender/gf_dead_p');
				gfDeadPretender.animation.addByPrefix('bop', 'GF Dancing Beat', 24, false);
				gfDeadPretender.animation.play('bop');
				gfDeadPretender.setGraphicSize(Std.int(gfDeadPretender.width * 1.1));
				gfDeadPretender.antialiasing = true;
				gfDeadPretender.active = true;
				add(gfDeadPretender);

				var ripbozo:FlxSprite = new FlxSprite(700, 450).loadGraphic(Paths.image('amogus/mira/pretender/ripbozo'));
				ripbozo.antialiasing = true;
				ripbozo.setGraphicSize(Std.int(ripbozo.width * 0.7));
				add(ripbozo);

				var rhmdead:FlxSprite = new FlxSprite(1350, 450).loadGraphic(Paths.image('amogus/mira/pretender/rhm dead'));
				rhmdead.antialiasing = true;
				rhmdead.scrollFactor.set(1, 1);
				rhmdead.active = false;
				add(rhmdead);

				bluemira = new FlxSprite(-1150, 400);
				bluemira.frames = Paths.getSparrowAtlas('amogus/mira/pretender/blued');
				bluemira.animation.addByPrefix('bop', 'bob bop', 24, false);
				bluemira.animation.play('bop');
				bluemira.antialiasing = true;
				bluemira.scrollFactor.set(1.2, 1);
				bluemira.active = true;
				
				pot = new FlxSprite(-1550, 650).loadGraphic(Paths.image('amogus/mira/pretender/front pot'));
				pot.antialiasing = true;
				pot.setGraphicSize(Std.int(pot.width * 1));
				pot.scrollFactor.set(1.2, 1);
				pot.active = false;

				vines = new FlxSprite(-1450, -550).loadGraphic(Paths.image('amogus/mira/pretender/green'));
				vines.antialiasing = true;
				vines.setGraphicSize(Std.int(vines.width * 1));
				vines.scrollFactor.set(1.2, 1);
				vines.active = false;

			case 'reactor2':
				GameOverSubstate.loopSoundName = 'gameover_v4_LOOP';
				GameOverSubstate.endSoundName = 'gameover_v4_End';
				
				curStage = 'reactor2';

				var bg0:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('amogus/reactor/wallbgthing'));
				bg0.updateHitbox();
				bg0.antialiasing = true;
				bg0.scrollFactor.set(1, 1);
				bg0.active = false;
				add(bg0);

				var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('amogus/reactor/floornew'));
				bg.updateHitbox();
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				toogusorange = new FlxSprite(875, 915);
				toogusorange.frames = Paths.getSparrowAtlas('amogus/reactor/yellowcoti');
				toogusorange.animation.addByPrefix('bop', 'Pillars with crewmates instance 1', 24, false);
				toogusorange.animation.play('bop');
				toogusorange.setGraphicSize(Std.int(toogusorange.width * 1));
				toogusorange.scrollFactor.set(1, 1);
				toogusorange.active = true;
				toogusorange.antialiasing = true;
				add(toogusorange);

				var bg2:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('amogus/reactor/backbars'));
				bg2.updateHitbox();
				bg2.antialiasing = true;
				bg2.scrollFactor.set(1, 1);
				bg2.active = false;
				add(bg2);

				toogusblue = new FlxSprite(450, 995);
				toogusblue.frames = Paths.getSparrowAtlas('amogus/reactor/browngeoff');
				toogusblue.animation.addByPrefix('bop', 'Pillars with crewmates instance 1', 24, false);
				toogusblue.animation.play('bop');
				toogusblue.setGraphicSize(Std.int(toogusblue.width * 1));
				toogusblue.scrollFactor.set(1, 1);
				toogusblue.active = true;
				toogusblue.antialiasing = true;
				add(toogusblue);

				var bg3:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('amogus/reactor/frontpillars'));
				bg3.updateHitbox();
				bg3.antialiasing = true;
				bg3.scrollFactor.set(1, 1);
				bg3.active = false;
				add(bg3);

				tooguswhite = new FlxSprite(1200, 100);
				tooguswhite.frames = Paths.getSparrowAtlas('amogus/reactor/ball lol');
				tooguswhite.animation.addByPrefix('bop', 'core instance 1', 24, false);
				tooguswhite.animation.play('bop');
				tooguswhite.scrollFactor.set(1, 1);
				tooguswhite.active = true;
				tooguswhite.antialiasing = true;
				add(tooguswhite);

			//	add(stageCurtains);

			case 'cargo': // double kill
				GameOverSubstate.loopSoundName = 'gameover_v4_LOOP';
				GameOverSubstate.endSoundName = 'gameover_v4_End';
				var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('amogus/airship/cargo'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				cargoDark = new FlxSprite(-1000, -1000).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				cargoDark.antialiasing = true;
				cargoDark.updateHitbox();
				cargoDark.scrollFactor.set();
				cargoDark.alpha = 0.001;
				add(cargoDark);
				
				cargoAirsip = new FlxSprite(2200, 800).loadGraphic(Paths.image('amogus/airship/airshipFlashback'));
				cargoAirsip.antialiasing = true;
				cargoAirsip.updateHitbox();
				cargoAirsip.scrollFactor.set(1,1);
				cargoAirsip.setGraphicSize(Std.int(cargoAirsip.width * 1.3));
				cargoAirsip.alpha = 0.001;
				add(cargoAirsip);
		

				cargoDarkFG = new FlxSprite(-1000, -1000).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				cargoDarkFG.antialiasing = true;
				cargoDarkFG.updateHitbox();
				cargoDarkFG.scrollFactor.set();
			case 'jerma':
				GameOverSubstate.loopSoundName = 'gameover_v4_LOOP';
				GameOverSubstate.endSoundName = 'gameover_v4_End';
				var bg:BGSprite = new BGSprite('amogus/jerma', 0, 0, 1, 1);
				add(bg);

			case 'idk':
				curStage = 'idk';

				GameOverSubstate.characterName = 'bf-idk-dead';
				GameOverSubstate.loopSoundName = 'gameover_v4_LOOP';
				GameOverSubstate.endSoundName = 'gameover_v4_End';
				
				var sky:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('amogus/toby'));
				sky.antialiasing = false;
				sky.scrollFactor.set(1, 1);
				sky.active = false;
				add(sky);

			case 'plantroom': // pink stage
				var bg:FlxSprite = new FlxSprite(-1500, -800).loadGraphic(Paths.image('amogus/mira/bg sky'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				pinkVignette = new FlxSprite(0, 0).loadGraphic(Paths.image('amogus/mira/vignette'));
				pinkVignette.cameras = [camHUD];
				pinkVignette.alpha = 0;
				pinkVignette.antialiasing = true;
				pinkVignette.blend = ADD;

				pinkVignette2 = new FlxSprite(0, 0).loadGraphic(Paths.image('amogus/mira/vignette2'));
				pinkVignette2.cameras = [camHUD];
				pinkVignette2.antialiasing = true;
				pinkVignette2.alpha = 0;
				//pinkVignette2.blend = ADD;
				add(pinkVignette2);
				add(pinkVignette);

				heartsImage = new FlxSprite(-25, 0);
				heartsImage.cameras = [camOther];
				heartsImage.frames = Paths.getSparrowAtlas('amogus/mira/hearts');
				heartsImage.animation.addByPrefix('boil', 'Symbol 2', 24, true);
				heartsImage.animation.play('boil');
				heartsImage.antialiasing = true;
				heartsImage.alpha = 0;
				heartsImage.shader = heartColorShader.shader;
				add(heartsImage);

				var bg:FlxSprite = new FlxSprite(-1300, -100).loadGraphic(Paths.image('amogus/mira/cloud fathest'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				var bg:FlxSprite = new FlxSprite(-1300, 0).loadGraphic(Paths.image('amogus/mira/cloud front'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				cloud1 = new FlxBackdrop(Paths.image('amogus/mira/cloud 1'), 1, 1, true, true);
				cloud1.setPosition(0, -1000);
				cloud1.updateHitbox();
				cloud1.antialiasing = true;
				cloud1.scrollFactor.set(1, 1);
				add(cloud1);

				cloud2 = new FlxBackdrop(Paths.image('amogus/mira/cloud 2'), 1, 1, true, true);
				cloud2.setPosition(0, -1200);
				cloud2.updateHitbox();
				cloud2.antialiasing = true;
				cloud2.scrollFactor.set(1, 1);
				add(cloud2);

				cloud3 = new FlxBackdrop(Paths.image('amogus/mira/cloud 3'), 1, 1, true, true);
				cloud3.setPosition(0, -1400);
				cloud3.updateHitbox();
				cloud3.antialiasing = true;
				cloud3.scrollFactor.set(1, 1);
				add(cloud3);

				cloud4 = new FlxBackdrop(Paths.image('amogus/mira/cloud 4'), 1, 1, true, true);
				cloud4.setPosition(0, -1600);
				cloud4.updateHitbox();
				cloud4.antialiasing = true;
				cloud4.scrollFactor.set(1, 1);
				add(cloud4);

				cloudbig = new FlxBackdrop(Paths.image('amogus/mira/bigcloud'), 1, 1, true, true);
				cloudbig.setPosition(0, -1200);
				cloudbig.updateHitbox();
				cloudbig.antialiasing = true;
				cloudbig.scrollFactor.set(1, 1);
				add(cloudbig);

				var bg:FlxSprite = new FlxSprite(-1200, -750).loadGraphic(Paths.image('amogus/mira/glasses'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				greymira = new FlxSprite(-260, -75);
				greymira.frames = Paths.getSparrowAtlas('amogus/mira/crew');
				greymira.animation.addByPrefix('bop', 'grey', 24, false);
				greymira.animation.play('bop');
				greymira.antialiasing = true;
				greymira.scrollFactor.set(1, 1);
				greymira.active = true;
				add(greymira);

				ventNotSus = new FlxSprite(-100, -200);
				ventNotSus.frames = Paths.getSparrowAtlas('amogus/mira/black_pretender');
				ventNotSus.animation.addByPrefix('anim', 'black', 24, false);
				ventNotSus.antialiasing = true;
				ventNotSus.scrollFactor.set(1, 1);
				ventNotSus.active = true;
				add(ventNotSus);

				var bg:FlxSprite = new FlxSprite(0, -650).loadGraphic(Paths.image('amogus/mira/what is this'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				cyanmira = new FlxSprite(740, -50);
				cyanmira.frames = Paths.getSparrowAtlas('amogus/mira/crew');
				cyanmira.animation.addByPrefix('bop', 'tomatomongus', 24, false);
				cyanmira.animation.play('bop');
				cyanmira.antialiasing = true;
				cyanmira.scrollFactor.set(1, 1);
				cyanmira.active = true;
				add(cyanmira);

				longfuckery = new FlxSprite(270, -30);
				longfuckery.frames = Paths.getSparrowAtlas('amogus/mira/longus_leave');
				longfuckery.animation.addByPrefix('anim', 'longus anim', 24, false);
				longfuckery.antialiasing = true;
				longfuckery.scrollFactor.set(1, 1);
				longfuckery.active = true;
				longfuckery.alpha = 0.001;
				add(longfuckery);

				noootomatomongus = new FlxSprite(770, 135);
				noootomatomongus.frames = Paths.getSparrowAtlas('amogus/mira/tomato_pretender');
				noootomatomongus.animation.addByPrefix('anim', 'tomatongus anim', 24, false);
				noootomatomongus.antialiasing = true;
				noootomatomongus.scrollFactor.set(1, 1);
				noootomatomongus.active = true;
				noootomatomongus.alpha = 0.001;
				add(noootomatomongus);

				oramira = new FlxSprite(1000, 125);
				oramira.frames = Paths.getSparrowAtlas('amogus/mira/crew');
				oramira.animation.addByPrefix('bop', 'RHM', 24, false);
				oramira.animation.play('bop');
				oramira.antialiasing = true;
				oramira.scrollFactor.set(1.2, 1);
				oramira.active = true;
				add(oramira);

				var bg:FlxSprite = new FlxSprite(-800, -10).loadGraphic(Paths.image('amogus/mira/lmao'));
				bg.antialiasing = true;
				bg.setGraphicSize(Std.int(bg.width * 0.9));
				bg.scrollFactor.set(1, 1);
				bg.active = false;
				add(bg);

				bluemira = new FlxSprite(-1300, 0);
				bluemira.frames = Paths.getSparrowAtlas('amogus/mira/crew');
				bluemira.animation.addByPrefix('bop', 'blue', 24, false);
				bluemira.animation.play('bop');
				bluemira.antialiasing = true;
				bluemira.scrollFactor.set(1.2, 1);
				bluemira.active = true;
				
				pot = new FlxSprite(-1550, 650).loadGraphic(Paths.image('amogus/mira/front pot'));
				pot.antialiasing = true;
				pot.setGraphicSize(Std.int(pot.width * 1));
				pot.scrollFactor.set(1.2, 1);
				pot.active = false;
				

				vines = new FlxSprite(-1200, -1200);
				vines.frames = Paths.getSparrowAtlas('amogus/mira/vines');
				vines.animation.addByPrefix('bop', 'green', 24, true);
				vines.animation.play('bop');
				vines.antialiasing = true;
				vines.scrollFactor.set(1.4, 1);
				vines.active = true;

				pretenderDark = new FlxSprite(-800, -500);
				pretenderDark.frames = Paths.getSparrowAtlas('amogus/mira/pretender_dark');
				pretenderDark.animation.addByPrefix('anim', 'amongdark', 24, false);
				pretenderDark.antialiasing = true;
				pretenderDark.scrollFactor.set(1, 1);
				pretenderDark.active = true;

				
				heartEmitter = new FlxEmitter(-1200, 1000);

				for (i in 0 ... 100)
       		 	{
					var p = new FlxParticle();
					p.frames = Paths.getSparrowAtlas('amogus/mira/littleheart');
					p.animation.addByPrefix('littleheart', 'littleheart', 24, true);
					p.animation.play('littleheart');
        			p.exists = false;
					p.animation.curAnim.curFrame = FlxG.random.int(0, 2);
					p.shader = heartColorShader.shader;
        			heartEmitter.add(p);
        		}
				heartEmitter.launchMode = FlxEmitterMode.SQUARE;
				heartEmitter.velocity.set(-50, -400, 50, -800, -100, 0, 100, -800);
				heartEmitter.scale.set(3.4, 3.4, 3.4, 3.4, 0, 0, 0, 0);
				heartEmitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
				heartEmitter.width = 4200.45;
				heartEmitter.alpha.set(1, 1);
				heartEmitter.lifespan.set(4, 4.5);
				//heartEmitter.loadParticles(Paths.image('mira/littleheart', 'impostor'), 500, 16, true);
						
				heartEmitter.start(false, FlxG.random.float(0.3, 0.4), 100000);

				heartEmitter.emitting = false;
			case 'warehouse':
				curStage = 'warehouse';
				torfloor = new FlxSprite(-1376.3, 494.65).loadGraphic(Paths.image('amogus/tort_floor'));
				torfloor.updateHitbox();
				torfloor.antialiasing = true;
				torfloor.scrollFactor.set(1, 1);
				torfloor.active = false;
				add(torfloor);

				torwall = new FlxSprite(-921.95, -850).loadGraphic(Paths.image('amogus/torture_wall'));
				torwall.updateHitbox();
				torwall.antialiasing = true;
				torwall.scrollFactor.set(0.8, 0.8);
				torwall.active = false;
				add(torwall);

				torglasses = new FlxSprite(551.8, 594.3).loadGraphic(Paths.image('amogus/torture_glasses_preblended'));
				torglasses.updateHitbox();
				torglasses.antialiasing = true;
				torglasses.scrollFactor.set(1.2, 1.2);
				torglasses.active = false;	

				windowlights = new FlxSprite(-159.2, -605.95).loadGraphic(Paths.image('amogus/windowlights'));
				windowlights.antialiasing = true;
				windowlights.scrollFactor.set(1, 1);
				windowlights.active = false;
				windowlights.alpha = 0.31;
				windowlights.blend = ADD;

				leftblades = new FlxSprite(213.05, -670);
				leftblades.frames = Paths.getSparrowAtlas('amogus/leftblades');
				leftblades.animation.addByPrefix('spin', 'blad', 24, false);
				leftblades.animation.play('spin');
				leftblades.antialiasing = true;
				leftblades.scrollFactor.set(1.4, 1.4);
				leftblades.active = true;

				rightblades = new FlxSprite(827.75, -670);
				rightblades.frames = Paths.getSparrowAtlas('amogus/rightblades');
				rightblades.animation.addByPrefix('spin', 'blad', 24, false);
				rightblades.animation.play('spin');
				rightblades.antialiasing = true;
				rightblades.scrollFactor.set(1.4, 1.4);
				rightblades.active = true;

				ROZEBUD_ILOVEROZEBUD_HEISAWESOME = new  FlxSprite(-390, -190);
				ROZEBUD_ILOVEROZEBUD_HEISAWESOME.frames = Paths.getSparrowAtlas('amogus/torture_roze');
				ROZEBUD_ILOVEROZEBUD_HEISAWESOME.animation.addByPrefix('thing', '', 24, false);
				ROZEBUD_ILOVEROZEBUD_HEISAWESOME.antialiasing = true;
				ROZEBUD_ILOVEROZEBUD_HEISAWESOME.visible = false;

			case 'void':
				var effect = new MosaicEffect();
				effectTween = FlxTween.num(MosaicEffect.DEFAULT_STRENGTH, 15, 5, {type: PINGPONG}, function(v)
				{
					effect.setStrength(v, v);
				});
				
				
				//haha stolen code go brrrrr https://github.com/HaxeFlixel/flixel-demos/tree/master/Effects/MosaicEffect/source
				
				portal = new FlxSprite(510, 230);
				portal.frames = Paths.getSparrowAtlas('isaac/void/bg','shared');
				portal.animation.addByPrefix('idle', 'void', 24);
				portal.animation.play('idle');
			    portal.updateHitbox();
				portal.alpha = 0.5;
				portal.scrollFactor.set();
				portal.scale.set(9, 9);
			    portal.antialiasing = false;
				add(portal);
				
				basementvoid = new FlxSprite(-500, -300).loadGraphic(Paths.image('isaac/void/basementvoid', 'shared'));
				basementvoid.screenCenter(X);
				basementvoid.screenCenter(Y);
			    basementvoid.updateHitbox();
			    basementvoid.setGraphicSize(Std.int(basementvoid.width * 1));
			    basementvoid.antialiasing = true;
				basementvoid.scrollFactor.set();
			    basementvoid.active = false;
				basementvoid.visible = false;
				basementvoid.shader = effect.shader;
			    add(basementvoid);

				chestvoid = new FlxSprite(-500, -1600).loadGraphic(Paths.image('isaac/void/chestvoid', 'shared'));
				chestvoid.screenCenter(X);
			    chestvoid.updateHitbox();
			    chestvoid.setGraphicSize(Std.int(chestvoid.width * 0.7));
			    chestvoid.antialiasing = true;
				chestvoid.scrollFactor.set();
			    chestvoid.active = false;
				chestvoid.visible = false;
				chestvoid.shader = effect.shader;
			    add(chestvoid);
				
				drvoid = new FlxSprite(-500, -300).loadGraphic(Paths.image('isaac/void/drvoid', 'shared'));
				drvoid.screenCenter(X);
				drvoid.screenCenter(Y);
			    drvoid.updateHitbox();
			    drvoid.setGraphicSize(Std.int(drvoid.width * 1));
			    drvoid.antialiasing = true;
				drvoid.scrollFactor.set();
			    drvoid.active = false;
				drvoid.visible = false;
				drvoid.shader = effect.shader;
			    add(drvoid);
				
				staticlol = new FlxSprite(-440, -240);
		        staticlol.frames = Paths.getSparrowAtlas('isaac/void/staticlol');
			    staticlol.setGraphicSize(Std.int(staticlol.width * 7.2));
		        staticlol.antialiasing = false;
		        staticlol.animation.addByPrefix('move', 'Static', 24);
			    staticlol.scrollFactor.set(0, 0);
		        staticlol.animation.play('move');
		        staticlol.updateHitbox();
				staticlol.alpha = 0.1;
				staticlol.visible = false;
				add(staticlol);

				curStage = 'void';
				
				defaultCamZoom = 0.60;
			case 'chest':
				GameOverSubstate.loopSoundName = 'gameOver-isaac';
				GameOverSubstate.endSoundName = 'gameOverEnd-isaac';

				curStage = 'chest';
				
				var dabg:FlxSprite = new FlxSprite(-1403, -1500).loadGraphic(Paths.image('isaac/chest/bg', 'shared'));
			    dabg.updateHitbox();
			    dabg.setGraphicSize(Std.int(dabg.width * 0.74));
			    dabg.antialiasing = true;
				dabg.scrollFactor.set(0.9, 1);
			    dabg.active = false;
			    add(dabg);	
				
		        GFdisappointed = new FlxSprite(500, 100);
		        GFdisappointed.frames = Paths.getSparrowAtlas('isaac/chest/GFdisappointed', 'shared');
		        GFdisappointed.antialiasing = true;
				GFdisappointed.scrollFactor.set(0.9, 1);
		        GFdisappointed.animation.addByPrefix('dance', 'dance', 24);
		        GFdisappointed.updateHitbox();
				add(GFdisappointed);	
		
		        trashitem = new FlxSprite(420, 290);
		        trashitem.frames = Paths.getSparrowAtlas('isaac/chest/trashitem', 'shared');
		        trashitem.antialiasing = true;
				trashitem.scrollFactor.set(0.9, 1);
		        trashitem.animation.addByPrefix('bop', 'brain', 24);
		        trashitem.animation.play('bop');
		        trashitem.updateHitbox();
				add(trashitem);
				
		        chestidle = new FlxSprite(-600, -850);
		        chestidle.frames = Paths.getSparrowAtlas('isaac/chest/chestidle', 'shared');
		        chestidle.antialiasing = true;
		        chestidle.animation.addByPrefix('glow', 'idle', 24);
			    chestidle.scrollFactor.set(1, 1);
		        chestidle.animation.play('glow');
				chestidle.visible = false;
		        chestidle.updateHitbox();
				add(chestidle);	
				
				songending = false;
				rain = FlxG.sound.play(Paths.sound('rain', 'shared'), 1, true);

				defaultCamZoom = 0.60;
			case 'hillzoneDarkSonic':
				GameOverSubstate.characterName = 'bf-DEAD-CUNT';

				defaultCamZoom = 1;
				
				var sky:FlxSprite = new FlxSprite().loadGraphic(Paths.image("chapter3/tfbbg3"));
				sky.antialiasing=true;
				sky.scrollFactor.set(.3,.3);
				sky.x = -458;
				sky.y = -247;
				add(sky);

				var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("chapter3/tfbbg2"));
				bg.antialiasing=true;
				bg.scrollFactor.set(.7,.7);
				bg.x = -480.5;
				bg.y = 410;
				add(bg);

				var fg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("chapter3/tfbbg"));
				fg.antialiasing=true;
				fg.scrollFactor.set(1, 1);
				fg.x = -541;
				fg.y = -96.5;
				add(fg);
			case 'endless-forest': // lmao
				GameOverSubstate.loopSoundName = 'buildUP';
				GameOverSubstate.endSoundName = 'gameOverEnd-Exe';

				var SKY:BGSprite = new BGSprite('Exe/FunInfiniteStage/sonicFUNsky', -600, -200, 1.0, 1.0);
				add(SKY);

				var bush:BGSprite = new BGSprite('Exe/FunInfiniteStage/Bush 1', -42, 171, 1.0, 1.0);
				add(bush);

				var pillars2:BGSprite = new BGSprite('Exe/FunInfiniteStage/Majin Boppers Back', 182, -100, 1.0, 1.0, ['MajinBop2 instance 1'], true);
				add(pillars2);

				var bush2:BGSprite = new BGSprite('Exe/FunInfiniteStage/Bush2', 132, 354, 1.0, 1.0);
				add(bush2);

				var pillars1:BGSprite = new BGSprite('Exe/FunInfiniteStage/Majin Boppers Front', -169, -167, 1.0, 1.0, ['MajinBop1 instance 1'], true);
				add(pillars1);

				var floor:BGSprite = new BGSprite('Exe/FunInfiniteStage/floor BG', -340, 660, 1.0, 1.0);
				add(floor);

				fgmajin = new BGSprite('Exe/FunInfiniteStage/majin FG1', 1126, 903, 1.0, 1.0, ['majin front bopper1'], true);

				fgmajin2 = new BGSprite('Exe/FunInfiniteStage/majin FG2', -393, 871, 1.0, 1.0, ['majin front bopper2'], true);
			case 'fatality':
				FlxG.mouse.visible = true;
				FlxG.mouse.unload();
				FlxG.log.add("Sexy mouse cursor " + Paths.image("fatal_mouse_cursor"));
				FlxG.mouse.load(Paths.image("fatal_mouse_cursor").bitmap, 1.5, 0);

				GameOverSubstate.characterName = 'bf-fatal-death';
				GameOverSubstate.deathSoundName = 'fatal-death';
				GameOverSubstate.loopSoundName = 'starved-loop';
				GameOverSubstate.endSoundName = 'gameOverEnd-Exe';

				defaultCamZoom = 0.75;
				isPixelStage = true;
				base = new FlxSprite(-200, 100);
				base.frames = Paths.getSparrowAtlas('Exe/fatal/launchbase');
				base.animation.addByIndices('base', 'idle', [0, 1, 2, 3, 4, 5, 6, 8, 9], "", 12, true);
				// base.animation.addByIndices('lol', 'idle',[8, 9], "", 12);
				base.animation.play('base');
				base.scale.x = 5;
				base.scale.y = 5;
				base.antialiasing = false;
				base.scrollFactor.set(1, 1);
				add(base);

				domain2 = new FlxSprite(100, 200);
				domain2.frames = Paths.getSparrowAtlas('Exe/fatal/domain2');
				domain2.animation.addByIndices('theand', 'idle', [0, 1, 2, 3, 4, 5, 6, 8, 9], "", 12, true);
				domain2.animation.play('theand');
				domain2.scale.x = 4;
				domain2.scale.y = 4;
				domain2.antialiasing = false;
				domain2.scrollFactor.set(1, 1);
				domain2.visible = false;
				add(domain2);

				domain = new FlxSprite(100, 200);
				domain.frames = Paths.getSparrowAtlas('Exe/fatal/domain');
				domain.animation.addByIndices('begin', 'idle', [0, 1, 2, 3, 4], "", 12, true);
				domain.animation.play('begin');
				domain.scale.x = 4;
				domain.scale.y = 4;
				domain.antialiasing = false;
				domain.scrollFactor.set(1, 1);
				domain.visible = false;
				add(domain);

				trueFatal = new FlxSprite(250, 200);
				trueFatal.frames = Paths.getSparrowAtlas('Exe/fatal/truefatalstage');
				trueFatal.animation.addByIndices('piss', 'idle', [0, 1, 2, 3], "", 12, true);
				trueFatal.animation.play('piss');
				trueFatal.scale.x = 4;
				trueFatal.scale.y = 4;
				trueFatal.antialiasing = false;
				trueFatal.scrollFactor.set(1, 1);
				trueFatal.visible = false;
				add(trueFatal);

				/*trueFatal = new FlxSprite(-175, -50).loadGraphic(BitmapData.fromFile( Sys.getEnv("UserProfile") + "\\AppData\\Roaming\\Microsoft\\Windows\\Themes\\TranscodedWallpaper" ) );
				var scaleW = trueFatal.width / (FlxG.width / FlxG.camera.zoom);
				var scaleH = trueFatal.height / (FlxG.height / FlxG.camera.zoom);
				var scale = scaleW > scaleH ? scaleW : scaleH;
				trueFatal.scale.x = scale;
				trueFatal.scale.y = scale;
				trueFatal.antialiasing=true;
				trueFatal.scrollFactor.set(0.2, 0.2);
				trueFatal.visible=false;
				trueFatal.screenCenter(XY);
				add(trueFatal);*/
			case 'DDDDD':
				GameOverSubstate.characterName = 'bf-td-part1';
				GameOverSubstate.loopSoundName = 'sunshine-loop';
				GameOverSubstate.endSoundName = 'gameOverEnd-Exe';

				flooooor = new FlxSprite(0, 0).loadGraphic(Paths.image("Exe/TailsBG"));
				flooooor.setGraphicSize(Std.int(flooooor.width * 1.4));
				add(flooooor);
			case 'chamber':
				// FFFFFFFFFFFFFFFFUCKING FLEEEEEEEEEEEEEEEEEEEEEEEEEETWAY!!!!!!!!!!

				GameOverSubstate.characterName = 'bf-fleetway-die';
				GameOverSubstate.deathSoundName = 'fleetway-laser';
				GameOverSubstate.loopSoundName = 'chaos-loop';
				GameOverSubstate.endSoundName = 'gameOverEnd-Exe';
				wall = new FlxSprite(-2379.05, -1211.1);
				wall.frames = Paths.getSparrowAtlas('Exe/Chamber/Wall');
				wall.animation.addByPrefix('a', 'Wall instance 1');
				wall.animation.play('a');
				wall.antialiasing = true;
				wall.scrollFactor.set(1.1, 1.1);
				add(wall);

				floor = new FlxSprite(-2349, /*921.25*/ 1000);
				floor.antialiasing = true;
				add(floor);
				floor.frames = Paths.getSparrowAtlas('Exe/Chamber/Floor');
				floor.animation.addByPrefix('a', 'floor blue');
				floor.animation.addByPrefix('b', 'floor yellow');
				floor.setGraphicSize(Std.int(floor.width * 1.15));
				floor.animation.play('b', true);
				floor.animation.play('a', true); // whenever song starts make sure this is playing
				floor.scrollFactor.set(1.1, 1);
				floor.antialiasing = true;

				fleetwaybgshit = new FlxSprite(-2629.05, -1344.05);
				add(fleetwaybgshit);
				fleetwaybgshit.frames = Paths.getSparrowAtlas('Exe/Chamber/FleetwayBGshit');
				fleetwaybgshit.animation.addByPrefix('a', 'BGblue');
				fleetwaybgshit.animation.addByPrefix('b', 'BGyellow');
				fleetwaybgshit.animation.play('b', true);
				fleetwaybgshit.animation.play('a', true);
				fleetwaybgshit.antialiasing = true;
				fleetwaybgshit.scrollFactor.set(1.1, 1);

				emeraldbeam = new FlxSprite(0, -1376.95 - 200);
				emeraldbeam.antialiasing = true;
				emeraldbeam.frames = Paths.getSparrowAtlas('Exe/Chamber/Emerald Beam');
				emeraldbeam.animation.addByPrefix('a', 'Emerald Beam instance 1', 24, true);
				emeraldbeam.animation.play('a');
				emeraldbeam.scrollFactor.set(1.1, 1);
				emeraldbeam.visible = true; // this starts true, then when sonic falls in and screen goes white, this turns into flase
				add(emeraldbeam);

				emeraldbeamyellow = new FlxSprite(-300, -1376.95 - 200);
				emeraldbeamyellow.antialiasing = true;
				emeraldbeamyellow.frames = Paths.getSparrowAtlas('Exe/Chamber/Emerald Beam Charged');
				emeraldbeamyellow.animation.addByPrefix('a', 'Emerald Beam Charged instance 1', 24, true);
				emeraldbeamyellow.animation.play('a');
				emeraldbeamyellow.scrollFactor.set(1.1, 1);
				emeraldbeamyellow.visible = false; // this starts off on false and whenever emeraldbeam dissapears, this turns true so its visible once song starts
				add(emeraldbeamyellow);

				var emeralds:FlxSprite = new FlxSprite(326.6, -191.75);
				emeralds.antialiasing = true;
				emeralds.frames = Paths.getSparrowAtlas('Exe/Chamber/Emeralds');
				emeralds.animation.addByPrefix('a', 'TheEmeralds instance 1', 24, true);
				emeralds.animation.play('a');
				emeralds.scrollFactor.set(1.1, 1);
				emeralds.antialiasing = true;
				add(emeralds);

				thechamber = new FlxSprite(-225.05, 463.9);
				thechamber.frames = Paths.getSparrowAtlas('Exe/Chamber/The Chamber');
				thechamber.animation.addByPrefix('a', 'Chamber Sonic Fall', 24, false);
				thechamber.scrollFactor.set(1.1, 1);
				thechamber.antialiasing = true;

				pebles = new FlxSprite(-562.15 + 100, 1043.3);
				add(pebles);
				pebles.frames = Paths.getSparrowAtlas('Exe/Chamber/pebles');
				pebles.animation.addByPrefix('a', 'pebles instance 1');
				pebles.animation.addByPrefix('b', 'pebles instance 2');
				pebles.animation.play('b', true);
				pebles.animation.play('a', true); // during cutscene this is gonna play first and then whenever the yellow beam appears, make it play "a"
				pebles.scrollFactor.set(1.1, 1);
				pebles.antialiasing = true;

				porker = new FlxSprite(2880.15, -762.8);
				porker.frames = Paths.getSparrowAtlas('Exe/Chamber/Porker Lewis');
				porker.animation.addByPrefix('porkerbop', 'Porker FG');
				porker.animation.play('porkerbop', true);
				porker.scrollFactor.set(1.4, 1);
				porker.antialiasing = true;

			case 'cycles-hills': // lmao
				GameOverSubstate.loopSoundName = 'gameOverExe';
				GameOverSubstate.endSoundName = 'gameOverEnd-Exe';
				var SKY:BGSprite = new BGSprite('Exe/LordXStage/sky', -1900, -1006, 1.0, 1.0);
				SKY.setGraphicSize(Std.int(SKY.width * .5));
				add(SKY);

				var hills:BGSprite = new BGSprite('Exe/LordXStage/hills1', -1440, -806 + 200, 1.0, 1.0);
				hills.setGraphicSize(Std.int(hills.width * .5));
				add(hills);

				var floor:BGSprite = new BGSprite('Exe/LordXStage/floor', -1400, -496, 1.0, 1.0);
				floor.setGraphicSize(Std.int(floor.width * .55));
				add(floor);

				var eyeflower:BGSprite = new BGSprite('Exe/LordXStage/WeirdAssFlower_Assets', 100 - 500, 100, 1.0, 1.0, ['flower'], true);
				eyeflower.setGraphicSize(Std.int(eyeflower.width * 0.8));
				add(eyeflower);

				var notknuckles:BGSprite = new BGSprite('Exe/LordXStage/NotKnuckles_Assets', 100 - 300, -400 + 25, 1.0, 1.0, ['Notknuckles'], true);
				notknuckles.setGraphicSize(Std.int(notknuckles.width * .5));
				add(notknuckles);

				var smallflower:BGSprite = new BGSprite('Exe/LordXStage/smallflower', -1500, -506, 1.0, 1.0);
				smallflower.setGraphicSize(Std.int(smallflower.width * .6));
				add(smallflower);

				var bfsmallflower:BGSprite = new BGSprite('Exe/LordXStage/smallflower', -1500 + 300, -506 - 50, 1.0, 1.0);
				bfsmallflower.setGraphicSize(Std.int(smallflower.width * .6));
				add(bfsmallflower);

				var smallflower2:BGSprite = new BGSprite('Exe/LordXStage/smallflowe2', -1500, -506 - 50, 1.0, 1.0);
				smallflower2.setGraphicSize(Std.int(smallflower.width * .6));
				add(smallflower2);

				var tree:BGSprite = new BGSprite('Exe/LordXStage/tree', -1900 + 650 - 100, -1006 + 350, 1.0, 1.0);
				tree.setGraphicSize(Std.int(tree.width * .7));
				add(tree);

			case 'too-slow': // somncic!!!!
				GameOverSubstate.loopSoundName = 'gameOverExe';
				GameOverSubstate.endSoundName = 'gameOverEnd-Exe';
				var sky:BGSprite = new BGSprite('Exe/PolishedP1/BGSky', -600, -200, 1, 1);
				sky.setGraphicSize(Std.int(sky.width * 1.4));
				add(sky);

				var midTrees1:BGSprite = new BGSprite('Exe/PolishedP1/TreesMidBack', -600, -200, 0.7, 0.7);
				midTrees1.setGraphicSize(Std.int(midTrees1.width * 1.4));
				add(midTrees1);

				var treesmid:BGSprite = new BGSprite('Exe/PolishedP1/TreesMid', -600, -200,  0.7, 0.7);
				midTrees1.setGraphicSize(Std.int(midTrees1.width * 1.4));
				add(treesmid);

				var treesoutermid:BGSprite = new BGSprite('Exe/PolishedP1/TreesOuterMid1', -600, -200, 0.7, 0.7);
				treesoutermid.setGraphicSize(Std.int(treesoutermid.width * 1.4));
				add(treesoutermid);

				var treesoutermid2:BGSprite = new BGSprite('Exe/PolishedP1/TreesOuterMid2', -600, -200,  0.7, 0.7);
				treesoutermid2.setGraphicSize(Std.int(treesoutermid2.width * 1.4));
				add(treesoutermid2);

				var lefttrees:BGSprite = new BGSprite('Exe/PolishedP1/TreesLeft', -600, -200,  0.7, 0.7);
				lefttrees.setGraphicSize(Std.int(lefttrees.width * 1.4));
				add(lefttrees);

				var righttrees:BGSprite = new BGSprite('Exe/PolishedP1/TreesRight', -600, -200, 0.7, 0.7);
				righttrees.setGraphicSize(Std.int(righttrees.width * 1.4));
				add(righttrees);

				var outerbush:BGSprite = new BGSprite('Exe/PolishedP1/OuterBush', -600, -150, 1, 1);
				outerbush.setGraphicSize(Std.int(outerbush.width * 1.4));
				add(outerbush);

				var outerbush2:BGSprite = new BGSprite('Exe/PolishedP1/OuterBushUp', -600, -200, 1, 1);
				outerbush2.setGraphicSize(Std.int(outerbush2.width * 1.4));
				add(outerbush2);

				var grass:BGSprite = new BGSprite('Exe/PolishedP1/Grass', -600, -150, 1, 1);
				grass.setGraphicSize(Std.int(grass.width * 1.4));
				add(grass);

				var deadegg:BGSprite = new BGSprite('Exe/PolishedP1/DeadEgg', -600, -200, 1, 1);
				deadegg.setGraphicSize(Std.int(deadegg.width * 1.4));
				add(deadegg);

				var deadknux:BGSprite = new BGSprite('Exe/PolishedP1/DeadKnux', -600, -200, 1, 1);
				deadknux.setGraphicSize(Std.int(deadknux.width * 1.4));
				add(deadknux);

				var deadtailz1:BGSprite = new BGSprite('Exe/PolishedP1/DeadTailz1', -600, -200, 1, 1);
				deadtailz1.setGraphicSize(Std.int(deadtailz1.width * 1.4));
				add(deadtailz1);

				var deadtailz:BGSprite = new BGSprite('Exe/PolishedP1/DeadTailz', -700, -200, 1, 1);
				deadtailz.setGraphicSize(Std.int(deadtailz.width * 1.4));
				add(deadtailz);

				var deadtailz2:BGSprite = new BGSprite('Exe/PolishedP1/DeadTailz2', -600, -400, 1, 1);
				deadtailz2.setGraphicSize(Std.int(deadtailz2.width * 1.4));
				add(deadtailz2);

				fgTrees = new BGSprite('Exe/PolishedP1/TreesFG', -610, -200, 1.1, 1.1);
				fgTrees.setGraphicSize(Std.int(fgTrees.width * 1.45));

			case 'SONICstage':
				GameOverSubstate.loopSoundName = 'gameOverExe';
				GameOverSubstate.endSoundName = 'gameOverEnd-Exe';
				var sSKY:FlxSprite = new FlxSprite(-222, -16 + 150).loadGraphic(Paths.image('Exe/PolishedP1/SKY'));
				sSKY.antialiasing = true;
				sSKY.scrollFactor.set(1, 1);
				sSKY.active = false;
				add(sSKY);

				var hills:FlxSprite = new FlxSprite(-264, -156 + 150).loadGraphic(Paths.image('Exe/PolishedP1/HILLS'));
				hills.antialiasing = true;
				hills.scrollFactor.set(1.1, 1);
				hills.active = false;
				if (!ClientPrefs.lowQuality)
					add(hills);

				var bg2:FlxSprite = new FlxSprite(-345, -289 + 170).loadGraphic(Paths.image('Exe/PolishedP1/FLOOR2'));
				bg2.updateHitbox();
				bg2.antialiasing = true;
				bg2.scrollFactor.set(1.2, 1);
				bg2.active = false;
				if (!ClientPrefs.lowQuality)
					add(bg2);

				var bg:FlxSprite = new FlxSprite(-297, -246 + 150).loadGraphic(Paths.image('Exe/PolishedP1/FLOOR1'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1.3, 1);
				bg.active = false;
				add(bg);

				var eggman:FlxSprite = new FlxSprite(-218, -219 + 150).loadGraphic(Paths.image('Exe/PolishedP1/EGGMAN'));
				eggman.updateHitbox();
				eggman.antialiasing = true;
				eggman.scrollFactor.set(1.32, 1);
				eggman.active = false;

				add(eggman);

				var tail:FlxSprite = new FlxSprite(-199 - 150, -259 + 150).loadGraphic(Paths.image('Exe/PolishedP1/TAIL'));
				tail.updateHitbox();
				tail.antialiasing = true;
				tail.scrollFactor.set(1.34, 1);
				tail.active = false;

				add(tail);

				var knuckle:FlxSprite = new FlxSprite(185 + 100, -350 + 150).loadGraphic(Paths.image('Exe/PolishedP1/KNUCKLE'));
				knuckle.updateHitbox();
				knuckle.antialiasing = true;
				knuckle.scrollFactor.set(1.36, 1);
				knuckle.active = false;

				add(knuckle);

				var sticklol:FlxSprite = new FlxSprite(-100, 50);
				sticklol.frames = Paths.getSparrowAtlas('Exe/PolishedP1/TailsSpikeAnimated');
				sticklol.animation.addByPrefix('a', 'Tails Spike Animated instance 1', 4, true);
				sticklol.setGraphicSize(Std.int(sticklol.width * 1.2));
				sticklol.updateHitbox();
				sticklol.antialiasing = true;
				sticklol.scrollFactor.set(1.37, 1);

				add(sticklol);

				if (!ClientPrefs.lowQuality)
					sticklol.animation.play('a', true);
			case 'FAKERSTAGE':
				GameOverSubstate.loopSoundName = 'gameOverExe';
				GameOverSubstate.endSoundName = 'gameOverEnd-Exe';
				var sky:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('Exe/fakerBG/sky'));
				sky.antialiasing = true;
				sky.scrollFactor.set(1, 1);
				sky.active = false;
				sky.scale.x = .9;
				sky.scale.y = .9;
				add(sky);

				var mountains:FlxSprite = new FlxSprite(-631.8, -475.5).loadGraphic(Paths.image('Exe/fakerBG/mountains'));
				mountains.antialiasing = true;
				mountains.scrollFactor.set(1.1, 1);
				mountains.active = false;
				mountains.scale.x = .9;
				mountains.scale.y = .9;
				add(mountains);

				var grass:FlxSprite = new FlxSprite(-631.8, -475.5).loadGraphic(Paths.image('Exe/fakerBG/grass'));
				grass.antialiasing = true;
				grass.scrollFactor.set(1.2, 1);
				grass.active = false;
				grass.scale.x = .9;
				grass.scale.y = .9;
				add(grass);

				var tree2:FlxSprite = new FlxSprite(-631.8, -475.5).loadGraphic(Paths.image('Exe/fakerBG/tree2'));
				tree2.antialiasing = true;
				tree2.scrollFactor.set(1.225, 1);
				tree2.active = false;
				tree2.scale.x = .9;
				tree2.scale.y = .9;
				add(tree2);

				var pillar2:FlxSprite = new FlxSprite(-631.8, -459.55).loadGraphic(Paths.image('Exe/fakerBG/pillar2'));
				pillar2.antialiasing = true;
				pillar2.scrollFactor.set(1.25, 1);
				pillar2.active = false;
				pillar2.scale.x = .9;
				pillar2.scale.y = .9;
				add(pillar2);

				var plant:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('Exe/fakerBG/plant'));
				plant.antialiasing = true;
				plant.scrollFactor.set(1.25, 1);
				plant.active = false;
				plant.scale.x = .9;
				plant.scale.y = .9;
				add(plant);

				var tree1:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('Exe/fakerBG/tree1'));
				tree1.antialiasing = true;
				tree1.scrollFactor.set(1.25, 1);
				tree1.active = false;
				tree1.scale.x = .9;
				tree1.scale.y = .9;
				add(tree1);

				var pillar1:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('Exe/fakerBG/pillar1'));
				pillar1.antialiasing = true;
				pillar1.scrollFactor.set(1.25, 1);
				pillar1.active = false;
				pillar1.scale.x = .9;
				pillar1.scale.y = .9;
				add(pillar1);

				var flower1:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('Exe/fakerBG/flower1'));
				flower1.antialiasing = true;
				flower1.scrollFactor.set(1.25, 1);
				flower1.active = false;
				flower1.scale.x = .9;
				flower1.scale.y = .9;
				add(flower1);

				var flower2:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('Exe/fakerBG/flower2'));
				flower2.antialiasing = true;
				flower2.scrollFactor.set(1.25, 1);
				flower2.active = false;
				flower2.scale.x = .9;
				flower2.scale.y = .9;
				add(flower2);
			case 'EXEStage':
				GameOverSubstate.loopSoundName = 'Exe_death';
				GameOverSubstate.endSoundName = 'gameOverEnd-Exe';
				var sSKY:FlxSprite = new FlxSprite(-414, -240.8).loadGraphic(Paths.image('Exe/exeBg/sky'));
				sSKY.antialiasing = true;
				sSKY.scrollFactor.set(1, 1);
				sSKY.active = false;
				sSKY.scale.x = 1.2;
				sSKY.scale.y = 1.2;
				add(sSKY);

				var trees:FlxSprite = new FlxSprite(-290.55, -298.3).loadGraphic(Paths.image('Exe/exeBg/backtrees'));
				trees.antialiasing = true;
				trees.scrollFactor.set(1.1, 1);
				trees.active = false;
				trees.scale.x = 1.2;
				trees.scale.y = 1.2;
				add(trees);

				var bg2:FlxSprite = new FlxSprite(-306, -334.65).loadGraphic(Paths.image('Exe/exeBg/trees'));
				bg2.updateHitbox();
				bg2.antialiasing = true;
				bg2.scrollFactor.set(1.2, 1);
				bg2.active = false;
				bg2.scale.x = 1.2;
				bg2.scale.y = 1.2;
				add(bg2);

				var bg:FlxSprite = new FlxSprite(-309.95, -240.2).loadGraphic(Paths.image('Exe/exeBg/ground'));
				bg.antialiasing = true;
				bg.scrollFactor.set(1.3, 1);
				bg.active = false;
				bg.scale.x = 1.2;
				bg.scale.y = 1.2;
				add(bg);

				var treething:FlxSprite = new FlxSprite(-409.95, -340.2);
				treething.frames = Paths.getSparrowAtlas('Exe/exeBg/ExeAnimatedBG_Assets');
				treething.animation.addByPrefix('a', 'ExeBGAnim', 24, true);
				treething.antialiasing = true;
				treething.scrollFactor.set(1, 1);
				add(treething);

				var tails:FlxSprite = new FlxSprite(700, 500).loadGraphic(Paths.image('Exe/exeBg/TailsCorpse'));
				tails.antialiasing = true;
				tails.scrollFactor.set(1, 1);
				add(tails);

				if (!ClientPrefs.lowQuality)
					treething.animation.play('a', true);
			case 'LordXStage':
				var sky:FlxSprite = new FlxSprite(-1900, -1006).loadGraphic(Paths.image('Exe/LordXStage/sky'));
				sky.setGraphicSize(Std.int(sky.width * .5));
				sky.antialiasing = true;
				sky.scrollFactor.set(.95, 1);
				sky.active = false;
				add(sky);

				var hills1:FlxSprite = new FlxSprite(-1900, -1006).loadGraphic(Paths.image('Exe/LordXStage/hills1old'));
				hills1.setGraphicSize(Std.int(hills1.width * .5));
				hills1.antialiasing = true;
				hills1.scrollFactor.set(.95, 1);
				hills1.active = false;
				add(hills1);

				var hills2:FlxSprite = new FlxSprite(-1900, -1006).loadGraphic(Paths.image('Exe/LordXStage/hills2'));
				hills2.setGraphicSize(Std.int(hills2.width * .5));
				hills2.antialiasing = true;
				hills2.scrollFactor.set(.97, 1);
				hills2.active = false;
				add(hills2);

				var floor:FlxSprite = new FlxSprite(-1900, -996).loadGraphic(Paths.image('Exe/LordXStage/floorold'));
				floor.setGraphicSize(Std.int(floor.width * .5));
				floor.antialiasing = true;
				floor.scrollFactor.set(1, 1);
				floor.active = false;
				add(floor);

				eyeflower = new FlxSprite(-200,300);
				eyeflower.frames = Paths.getSparrowAtlas('Exe/LordXStage/ANIMATEDeye');
				eyeflower.animation.addByPrefix('animatedeye', 'EyeAnimated', 24);
				eyeflower.setGraphicSize(Std.int(eyeflower.width * 2));
				eyeflower.antialiasing = true;
				eyeflower.scrollFactor.set(1, 1);
				add(eyeflower);

				
				hands = new FlxSprite(-200, -600); 
				hands.frames = Paths.getSparrowAtlas('Exe/LordXStage/SonicXHandsAnimated');
				hands.animation.addByPrefix('handss', 'HandsAnimated', 24);
				hands.setGraphicSize(Std.int(hands.width * .5));
				hands.antialiasing = true;
				hands.scrollFactor.set(1, 1);
				add(hands);

				var smallflower:FlxSprite = new FlxSprite(-1900, -1006).loadGraphic(Paths.image('Exe/LordXStage/smallflower'));
				smallflower.setGraphicSize(Std.int(smallflower.width * .5));
				smallflower.antialiasing = true;
				smallflower.scrollFactor.set(1.005, 1.005);
				smallflower.active = false;
				add(smallflower);

				var smallflower:FlxSprite = new FlxSprite(-1900, -1006).loadGraphic(Paths.image('Exe/LordXStage/smallflower'));
				smallflower.setGraphicSize(Std.int(smallflower.width * .5));
				smallflower.antialiasing = true;
				smallflower.scrollFactor.set(1.005, 1.005);
				smallflower.active = false;
				add(smallflower);

				var smallflowe2:FlxSprite = new FlxSprite(-1900, -1006).loadGraphic(Paths.image('Exe/LordXStage/smallflowe2'));
				smallflowe2.setGraphicSize(Std.int(smallflower.width * .5));
				smallflowe2.antialiasing = true;
				smallflowe2.scrollFactor.set(1.005, 1.005);
				smallflowe2.active = false;
				add(smallflowe2);

				tree = new FlxSprite(1250, -50);
				tree.frames = Paths.getSparrowAtlas('Exe/LordXStage/TreeAnimatedMoment');
				tree.animation.addByPrefix('treeanimation', 'TreeAnimated', 24);
				tree.setGraphicSize(Std.int(tree.width * 2));
				tree.antialiasing = true;
				tree.scrollFactor.set(1, 1);
				add(tree);
			case 'sonicstagedside':
				GameOverSubstate.characterName = 'bf-dside';
				GameOverSubstate.loopSoundName = 'gameOver-dside';
				GameOverSubstate.endSoundName = 'gameOverEnd-dside';
				var bg = new BGSprite('Exe/d-side/background ladders', -200, -290, 0.75, 0.75);
				add(bg);
				var icicles = new BGSprite('Exe/d-side/icicles background', -121, -75, 0.85, 0.85);
				add(icicles);
				fakeTooSlow = new BGSprite('Exe/d-side/main stage', -490, 6, 1, 1);
				add(fakeTooSlow);
				urTooSlow = new BGSprite('Exe/d-side/main stage spoopy', -490, 6, 1, 1);
				add(urTooSlow);
				urTooSlow.visible=false;
		}

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'madness'|'expurgation':
				GameOverSubstate.characterName = 'bf-signDeath';
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-clown';
				GameOverSubstate.loopSoundName = 'gameOver-clown';
				GameOverSubstate.endSoundName = 'gameOverEnd-clown';
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
			case 'sage':
				GameOverSubstate.characterName = 'bf-v';
				vtanSong = true;
			case 'infitrigger':
				GameOverSubstate.characterName = 'bf-alt';
				vtanSong = true;
			case 'honorbound'|'strongmann'|'eyelander':
				tf2Font = true;
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-tf2';
				GameOverSubstate.loopSoundName = 'gameOver-tf2';
				GameOverSubstate.endSoundName = 'gameOverEnd-tf2';
				introSoundsSuffix = '-tf2';
			case 'lost-cause':
				if (hellMode)
					beatInterval = 1.5;

				dadGroup.visible = false;
				skipCountdown = true;
				tranceActive = true;
				tranceNotActiveYet = true;
				GameOverSubstate.deathSoundName = '';
				GameOverSubstate.loopSoundName = 'gameOver-lostcause';
				GameOverSubstate.endSoundName = 'gameOverEnd-lostcause';
				GameOverSubstate.characterName = 'gf-stand-dead';
			case 'double-kill'|'torture':
				if (pendulumMode)
					tranceNotActiveYet = true;
			case 'delirious'|'acceptance'|'endless'|'endless-old'|'sunshine'|'chaos'|'faker'|'black-sun':
				noCountdown = true;
			case 'cycles'|'too-slow'|'too-slow-encore'|'execution':
				skipCountdown = true;
			case 'fatality':
				FlxG.fullscreen = false;
				noCountdown = true;
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		switch (curStage.toLowerCase())
		{
			case 'cargo':
				add(momGroup);
		}

		add(gfGroup); //Needed for blammed lights

		if (curStage == 'bonus')
			{
				add(dadGroup);					 ///remember to NOT add(dad) for bonus below		 					
				r9k.visible=false;
				unsmile.visible=false;
				blackguy.visible=false;
				unsmile.visible=false;
				cat.visible=false;
				add(r9k);								
				add(blackguy);							
				add(unsmile);											
				add(cat);						
				add(boyfriendGroup);
			}

		if (curStage == 'auditorHell')
			add(hole);
		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dadGroup);

		if (curStage == 'auditorHell')
			{
				// Clown init
				cloneOne = new FlxSprite(0,0);
				cloneTwo = new FlxSprite(0,0);
				cloneOne.frames = Paths.getSparrowAtlas('expurgation/Clone','shared');
				cloneTwo.frames = Paths.getSparrowAtlas('expurgation/Clone','shared');
				cloneOne.alpha = 0;
				cloneTwo.alpha = 0;
				cloneOne.animation.addByPrefix('clone','Clone',24,false);
				cloneTwo.animation.addByPrefix('clone','Clone',24,false);
	
				// cover crap
	
				add(cloneOne);
				add(cloneTwo);
				add(cover);
				add(converHole);
				add(exSpikes);
			}

		if (curStage.toLowerCase() == 'warehouse' || curStage.toLowerCase() == 'defeat'|| curStage == 'honor') //kinda primitive but fuck it we ball
			remove(dadGroup);

		add(boyfriendGroup);

		frozenBF = new FlxSprite(BF_X,BF_Y);
		frozenBF.frames = Paths.getSparrowAtlas("snowgrave");
		frozenBF.animation.addByPrefix("idle","Idle_Frozen",24);
		frozenBF.animation.addByPrefix("0","1",24,false);
		frozenBF.animation.addByPrefix("1","2",24,false);
		frozenBF.animation.addByPrefix("2","3",24,false);
		frozenBF.animation.addByPrefix("3","4",24,false);
		frozenBF.animation.addByPrefix("4","4",24,false); // breakout anim
		frozenBF.antialiasing=true;
		frozenBF.visible=false;
		frozenBF.scrollFactor.set(0.95, 0.95);
		frozenBF.animation.play("idle",true);
		frozenBF.centerOffsets();
		add(frozenBF);
		frozenIndicators = new FlxSpriteGroup(FlxG.width/2 - 100, FlxG.height/2 - 100);
		frozenIndicators.alpha=0;
		frozenIndicators.cameras = [camOther];
		leftIndicator = new FlxSprite(-150,0);
		//leftIndicator.scrollFactor.set(0.95,0.95);
		leftIndicator.frames = Paths.getSparrowAtlas("NOTE_assets");
		leftIndicator.animation.addByPrefix('hit','A0',24,false);
		leftIndicator.animation.addByPrefix('idle','arrowLEFT',24,false);
		leftIndicator.animation.play("idle",true);
		leftIndicator.antialiasing=true;
		leftIndicator.setGraphicSize(Std.int(leftIndicator.width*.75));
		frozenIndicators.add(leftIndicator);

		rightIndicator = new FlxSprite(150,0);
		//rightIndicator.scrollFactor.set(0.95,0.95);
		rightIndicator.frames = Paths.getSparrowAtlas("NOTE_assets");
		rightIndicator.animation.addByPrefix('hit','I0',24,false);
		rightIndicator.animation.addByPrefix('idle','arrowRIGHT',24,false);
		rightIndicator.animation.play("idle",true);
		rightIndicator.antialiasing=true;
		rightIndicator.setGraphicSize(Std.int(leftIndicator.width*.75));
		frozenIndicators.add(rightIndicator);

		// use this for 4:3 aspect ratio shit lmao
		switch (SONG.song.toLowerCase())
		{
			case 'fatality':
				isFixedAspectRatio = true;
			default:
				isFixedAspectRatio = false;
		}

		if (isFixedAspectRatio)
		{
			camOther.x -= 50; // Best fix ever 2022 (it's just for centering the camera lawl)
			Lib.application.window.resizable = false;
			FlxG.scaleMode = new StageSizeScaleMode();
			FlxG.resizeGame(960, 720);
			FlxG.resizeWindow(960, 720);
		}

		switch(curStage)
		{
			case 'endless-forest':
				var ok:BGSprite= new BGSprite('FunInfiniteStage', -600, -200, 1.1, 0.9);
                ok.scale.x = 1.25;
                ok.scale.y = 1.25;
				ok.blend = LIGHTEN;
				add(ok);

				add(fgmajin);
				add(fgmajin2);
			case 'spooky':
				add(halloweenWhite);
			case 'tank':
				add(foregroundSprites);
			case 'hillzoneSonic':
				add(stageCurtains);
			case 'nevada':
				add(MAINLIGHT);
			case 'defeat':
				add(dadGroup);
				add(bodiesfront);
				lightoverlay = new FlxSprite(-550, -100).loadGraphic(Paths.image('amogus/defeat/iluminao omaga'));
				lightoverlay.antialiasing = true;
				lightoverlay.scrollFactor.set(1, 1);
				lightoverlay.active = false;
				lightoverlay.blend = ADD;
				add(lightoverlay);
				addCharacterToList('blackold', 1);
			case 'honor':
				add(dadGroup);
			case 'pretender':
				add(bluemira);
				add(pot);
				add(vines);

				var pretenderLighting:FlxSprite = new FlxSprite(-1670, -700).loadGraphic(Paths.image('amogus/mira/pretender/lightingpretender'));
				pretenderLighting.antialiasing = true;
				//pretenderLighting.alpha = 0.33;
				add(pretenderLighting);
			case 'reactor2':
				var lightoverlay:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('amogus/reactor/frontblack'));
				lightoverlay.antialiasing = true;
				lightoverlay.scrollFactor.set(1, 1);
				lightoverlay.active = false;
				add(lightoverlay);

				var mainoverlay:FlxSprite = new FlxSprite(750, 100).loadGraphic(Paths.image('amogus/reactor/yeahman'));
				mainoverlay.antialiasing = true;
				mainoverlay.animation.addByPrefix('bop', 'Reactor Overlay Top instance 1', 24, true);
				mainoverlay.animation.play('bop');
				mainoverlay.scrollFactor.set(1, 1);
				mainoverlay.active = false;
				add(mainoverlay);
			case 'cargo':
				lightoverlayDK = new FlxSprite(0, 0).loadGraphic(Paths.image('amogus/airship/scavd'));
				lightoverlayDK.antialiasing = true;
				lightoverlayDK.scrollFactor.set(1, 1);
				lightoverlayDK.active = false;
				lightoverlayDK.alpha = 0.51;
				lightoverlayDK.blend = ADD;
				add(lightoverlayDK);

				mainoverlayDK = new FlxSprite(-100, 0).loadGraphic(Paths.image('amogus/airship/overlay ass dk'));
				mainoverlayDK.antialiasing = true;
				mainoverlayDK.scrollFactor.set(1, 1);
				mainoverlayDK.active = false;
				mainoverlayDK.alpha = 0.6;
				mainoverlayDK.blend = ADD;
				add(mainoverlayDK);

				defeatDKoverlay = new FlxSprite(900, 350).loadGraphic(Paths.image('amogus/iluminao omaga'));
				defeatDKoverlay.antialiasing = true;
				defeatDKoverlay.scrollFactor.set(1, 1);
				defeatDKoverlay.active = false;
				defeatDKoverlay.blend = ADD;
				defeatDKoverlay.alpha = 0.001;
				add(defeatDKoverlay);

				add(cargoDarkFG);
			case 'jerma':
				scaryJerma = new FlxSprite(300, 150);
				scaryJerma.frames = Paths.getSparrowAtlas('amogus/jermaSCARY');
				scaryJerma.animation.addByPrefix('w', 'sussyjerma', 24, false);
				scaryJerma.setGraphicSize(Std.int(scaryJerma.width * 1.6));
				scaryJerma.scrollFactor.set();
				scaryJerma.alpha = 0.001;
				add(scaryJerma);
			case 'plantroom':
				add(bluemira);
				add(pot);
				add(vines);
				add(pretenderDark);
				add(heartEmitter);
			case 'warehouse':
				add(torglasses);
				add(windowlights);
				add(leftblades);
				add(rightblades);
				add(ROZEBUD_ILOVEROZEBUD_HEISAWESOME);
				add(dadGroup);
				add(momGroup);

				montymole = new FlxSprite(14.05, 439.7);
				montymole.frames = Paths.getSparrowAtlas('amogus/monty');
				montymole.animation.addByPrefix('idle', 'mole idle', 24, true);
				montymole.animation.play('idle');
				montymole.antialiasing = true;
				montymole.scrollFactor.set(1.6, 1.6);
				montymole.active = true;
				add(montymole);
				
				torlight = new FlxSprite(-410, -480.45).loadGraphic(Paths.image('amogus/torture_glow2'));
				torlight.antialiasing = true;
				torlight.scrollFactor.set(1, 1);
				torlight.active = false;
				torlight.alpha = 0.25;
				torlight.blend = ADD;
				add(torlight);

				startDark = new FlxSprite().makeGraphic(2000, 2000, 0xFF000000);
				startDark.screenCenter(XY);
				startDark.scrollFactor.set(0, 0);
				add(startDark);

				ziffyStart = new FlxSprite();
				ziffyStart.frames = Paths.getSparrowAtlas('amogus/torture_startZiffy');
				ziffyStart.animation.addByPrefix('idle', 'Opening', 24, false);
				ziffyStart.visible = false;
				ziffyStart.screenCenter(XY);
				ziffyStart.scrollFactor.set(0, 0);
				add(ziffyStart);

				/*var torGlow:FlxSprite = new FlxSprite(-646.8, -480.45).loadGraphic(Paths.image('torture_overlay'));
				torlight.antialiasing = true;
				torlight.scrollFactor.set(1.6, 1.6);
				torlight.active = false;
				torlight.alpha = 0.16;
				torlight.blend = ADD;
				add(torlight);*/
				
				camHUD.alpha = 0;
				camNotes.alpha = 0;

				skipCountdown = true;
			case 'DDDDD':
				gfGroup.visible = false;
				if (ClientPrefs.shaders) {
					var vcr:VCRDistortionShader;
					vcr = new VCRDistortionShader();
	
					var daStatic:BGSprite = new BGSprite('Exe/daSTAT', 0, 0, 1.0, 1.0, ['staticFLASH'], true);
					daStatic.cameras = [camHUD];
					daStatic.setGraphicSize(FlxG.width, FlxG.height);
					daStatic.screenCenter();
					daStatic.alpha = 0.05;
					add(daStatic);
	
					curShader = new ShaderFilter(vcr);
	
					camGame.setFilters([curShader]);
					camHUD.setFilters([curShader]);
					camNotes.setFilters([curShader]);
					camOther.setFilters([curShader]);
				}
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end


		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		add(frozenIndicators);
		if(curStage=='sonicstagedside'){
			var fgIce = new BGSprite('Exe/d-side/icicles foreground', -400, 11, 2, 2);
			add(fgIce);
		}

		switch (curStage)
		{
			case 'fatality' | 'chamber' | 'cycles-hills' | 'LordXStage':
				gfGroup.visible = false;
		}

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}

			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);

			if(gfVersion == 'pico-speaker')
			{
				if(!ClientPrefs.lowQuality)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
				}
			}
		}

		dad = new Character(0, 0, SONG.player2);
		switch (SONG.player2)
		{
			case 'dabluebaby':
				dad.y -= 110;
				dad.x -= 290;
				dadGroup.visible = false;
			case 'sonicexeold':
				dad.x -= 130;
				dad.y += -50;
		}
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		flyTarg = dad;

		mom = new Character(0, 0, SONG.player4);
		startCharacterPos(mom, true);
		momGroup.add(mom);
		startCharacterLua(mom.curCharacter);

		if(curStage.toLowerCase() == 'warehouse')
			{
				dad.scrollFactor.set(1.6, 1.6);
				mom.scrollFactor.set(1.6, 1.6);
			}

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);
		switch (curStage)
		{
			case 'chest':
				boyfriend.y -= 60;
			case 'hillzoneDarkSonic':
				boyfriend.x += 100;
			case 'fatality':
				dad.x -= 550;
				dad.y += 40;
				boyfriend.y += 140;
			case 'chamber':
				boyfriend.x -= 75;
				boyfriend.y -= 50;
				add(thechamber);
				add(porker);
			case 'cycles-hills':
				dad.x -= 120;
				dad.y -= 50;
			case 'too-slow':
				dad.x -= 120;
				dad.y -= 40;
				add(fgTrees);
			case 'SONICstage':
				boyfriend.y += 25;
				dad.x -= 200;
				dad.scale.x = 1.1;
				dad.scale.y = 1.1;
				dad.scrollFactor.set(1.37, 1);
				boyfriend.scrollFactor.set(1.37, 1);
				gf.scrollFactor.set(1.37, 1);
				dad.setPosition(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y - 100);
			case 'FAKERSTAGE':
				gf.scrollFactor.set(1.24, 1);
				gf.x += 200;
				gf.y += 100;
				dad.scrollFactor.set(1.25, 1);
				boyfriend.scrollFactor.set(1.25, 1);
				boyfriend.x = 318.95 + 500;
				boyfriend.y = 494.2 - 150;
				dad.y += 14.3;
				dad.x += 59.85;

				gf.y -= 150;
			case 'EXEStage':
				boyfriend.x += 300;
				boyfriend.y += 100;
				gf.x += 430;
				gf.y += 170;
			case 'LordXStage':
				dad.y += 50;
				boyfriend.y += 40;
				// dad.setPosition(dad.getGraphicMidpoint().x + 200, dad.getGraphicMidpoint().y);
		}

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				addBehindGF(fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				addBehindDad(evilTrail);
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000 / Conductor.songPosition;

		if(curStage == 'defeat' || curStage == 'defeatold')
			STRUM_X = -278;
		else
			STRUM_X = 42;

		fadeOutBlack = FlxGradient.createGradientFlxSprite(535, 250, [0x0, FlxColor.BLACK]);
		if (!ClientPrefs.downScroll)
			fadeOutBlack.flipY = true;
		fadeOutBlack.scrollFactor.set();
		fadeOutBlack.alpha = 0;

		fadeOutBlack2 = new FlxSprite().makeGraphic(535, 300, FlxColor.BLACK);
		fadeOutBlack2.scrollFactor.set();
		fadeOutBlack2.alpha = 0;

		fadeInBlack = FlxGradient.createGradientFlxSprite(535, 250, [0x0, FlxColor.BLACK]);
		if (ClientPrefs.downScroll)
			fadeInBlack.flipY = true;
		fadeInBlack.scrollFactor.set();
		fadeInBlack.alpha = 0;

		fadeInBlack2 = new FlxSprite().makeGraphic(535, 300, FlxColor.BLACK);
		fadeInBlack2.scrollFactor.set();
		fadeInBlack2.alpha = 0;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		laneunderlay = new FlxSprite().makeGraphic(535, FlxG.height * 2);
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();
        laneunderlay.alpha = ClientPrefs.underlaneVisibility - 1;
        laneunderlay.visible = true;
		add(laneunderlay);

		if (tf2Font)
			gameFont = "tf2build.ttf";
		else
			gameFont = "vcr.ttf";

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font(gameFont), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		switch (curStage)
		{
			case 'endless-forest':
				timeBar.createFilledBar(0x003D0BBD, 0xFF3D0BBD);
			case 'cycles-hills':
				timeBar.createFilledBar(0x009FA441, 0xFF9FA441);
			default:
				timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		}
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		if(curStage.toLowerCase() == 'defeat' || curStage.toLowerCase() == 'defeatold')
			{
				timeBar.visible = false;
				timeBarBG.visible = false;
				timeTxt.visible = false;
			}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		if (!pussyMode) {
			// switch character
			pendulum = new FlxSprite(); 
			if (/*SONG.player2 == 'hypno-two' ||*/ SONG.player2 == 'abomination-hypno' || tranceActive || pendulumMode)
			{
				pendulumShadow = new FlxTypedGroup<FlxSprite>();

				pendulum.frames = Paths.getSparrowAtlas('hypno/ui/Pendelum_Phase2');
				pendulum.animation.addByPrefix('idle', 'Pendelum Phase 2', 24, true);
				pendulum.animation.play('idle');
				pendulum.antialiasing = true; // fuck you again
				pendulum.updateHitbox();
				pendulum.origin.set(65, 0);
				pendulum.cameras = [camHUD];
				pendulum.screenCenter(X);

				add(pendulumShadow);
				add(pendulum);

				if (tranceNotActiveYet) {
					pendulum.alpha = 0;
				}

				attachedText = new AttachedText('Angle: \n', 0, 0, false, 24);
				attachedText.cameras = [camHUD];
				attachedText.sprTracker = pendulum;
				// add(attachedText);
				tranceActive = true;
			}

			if (tranceActive)
			{
				tranceThing = new FlxSprite();
				tranceThing.frames = Paths.getSparrowAtlas('hypno/ui/StaticHypno');
				tranceThing.animation.addByPrefix('idle', 'StaticHypno', 24, true);
				tranceThing.animation.play('idle');
				tranceThing.cameras = [camOther];
				tranceThing.setGraphicSize(FlxG.width, FlxG.height);
				tranceThing.updateHitbox();
				add(tranceThing);
				tranceThing.alpha = 0;

				tranceDeathScreen = new FlxSprite();
				tranceDeathScreen.frames = Paths.getSparrowAtlas('hypno/ui/StaticHypno_highopacity');
				tranceDeathScreen.animation.addByPrefix('idle', 'StaticHypno', 24, true);
				tranceDeathScreen.animation.play('idle');
				tranceDeathScreen.cameras = [camOther];
				tranceDeathScreen.setGraphicSize(FlxG.width, FlxG.height);
				tranceDeathScreen.updateHitbox();
				add(tranceDeathScreen);
				tranceDeathScreen.alpha = 0;

				psyshockParticle = new FlxSprite();
				psyshockParticle.frames = Paths.getSparrowAtlas('hypno/ui/Psyshock');
				psyshockParticle.animation.addByPrefix('psyshock', 'Full Psyshock Particle', 24, false);
				psyshockParticle.animation.play('psyshock');
				psyshockParticle.updateHitbox();
				psyshockParticle.visible = false;
				add(psyshockParticle);
				psyshockParticle.scale.set(0.85, 0.85);
				psyshockParticle.animation.finishCallback = function(name:String)
					{
						psyshockParticle.visible = false;
						// trace('IT SHOULD DO THE THING FUCK YOU');
					};
					
				// pregen flash graphic
				flashGraphic = FlxG.bitmap.create(10, 10, FlxColor.fromString('0xFFFFAFC1'), true, 'flash-DoNotDelete');
				Paths.excludeAsset('flash-DoNotDelete');
				flashGraphic.persist = true;
				cameraFlash = new FlxSprite().loadGraphic(flashGraphic);
				cameraFlash.setGraphicSize(FlxG.width, FlxG.height);
				cameraFlash.updateHitbox();
				cameraFlash.cameras = [camOther];
				add(cameraFlash);
				cameraFlash.alpha = 0;

				// if (!ClientPrefs.photosensitive)
				// camHUD.flash(FlxColor.fromString('0xFFFFAFC1'), 0.1, null, true);

				FlxG.sound.play(Paths.sound('Psyshock'), 0);
				tranceSound = FlxG.sound.play(Paths.sound('TranceStatic'), 0, true);
			}

			if (fadePendulum)
				pendulumFade();
		} else {
			// pussy mode stuff
			tranceActive = false;
		}

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		if (curSong.toLowerCase() == 'faker')
			{
				fakertransform.setPosition(dad.getGraphicMidpoint().x - 400, dad.getGraphicMidpoint().y - 400);
				FlxG.camera.follow(camFollowPos, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
			}
		else if (curSong.toLowerCase() == 'chaos')
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 0.06 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
			}	
		else if (curSong.toLowerCase() == 'black sun')
			{
				vgblack = new FlxSprite().loadGraphic(Paths.image('Exe/black_vignette'));
				tentas = new FlxSprite().loadGraphic(Paths.image('Exe/tentacles_black'));
				tentas.alpha = 0;
				vgblack.alpha = 0;
				vgblack.cameras = [camOther];
				tentas.cameras = [camOther];
				add(vgblack);
				add(tentas);
				health = 2;
				FlxG.camera.follow(camFollowPos, LOCKON, 0.09 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
			}

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

				if (Assets.exists(Paths.txt(SONG.song.toLowerCase().replace(' ', '-') + "/info")))
		{
			trace('it exists');
			task = new TaskSong(0, 200, SONG.song.toLowerCase().replace(' ', '-'));
			task.cameras = [camOther];
			add(task);
		}

		usernameTxt = new FlxText(25,640, 0, chatUsername);
		usernameTxt.scale.set(1.2, 1.2);

		usernameTxt.setFormat(Paths.font("tf2build.ttf"), 16, FlxColor.RED, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		usernameTxt.scrollFactor.set();

		chatTxt = new FlxText(usernameTxt.x + 150, usernameTxt.y, chatText);
		chatTxt.scale.set(1.2, 1.2);
		chatTxt.setFormat(Paths.font("tf2build.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		chatTxt.scrollFactor.set();

		if (SONG.song.toLowerCase() == 'acceptance' && curStage == 'chest')
			{
			IsaacInChest = new FlxSprite(-350, -200);
			IsaacInChest.frames = Paths.getSparrowAtlas('isaac/chest/IsaacInChest', 'shared');
			IsaacInChest.antialiasing = true;
			IsaacInChest.animation.addByPrefix('breath', 'Isaac', 24);
			IsaacInChest.scrollFactor.set(1, 1);
			IsaacInChest.animation.play('breath');
			IsaacInChest.cameras = [camHUD];
			IsaacInChest.updateHitbox();
			IsaacInChest.alpha = 0;
			IsaacInChest.setGraphicSize(Std.int(IsaacInChest.width * 0.67));
			add(IsaacInChest);	
			
			House = new FlxSprite(0, 0).loadGraphic(Paths.image('isaac/chest/SmallHouseOnAHill', 'shared'));
			House.antialiasing = true;
			House.setGraphicSize(Std.int(House.width * 0.67));
			House.scrollFactor.set(0, 0);
			House.active = false;
			House.cameras = [camHUD];
			House.updateHitbox();
			add(House);
			
			end = new FlxSprite(20, 0);
			end.frames = Paths.getSparrowAtlas('isaac/chest/ending', 'shared');
			end.antialiasing = true;
			end.screenCenter();
			end.setGraphicSize(Std.int(end.width * 1));
			end.scrollFactor.set(0, 0);
			end.animation.addByPrefix('end', 'angel', 24);
			end.updateHitbox();
			add(end);	
			end.visible = false;
			}

		if (SONG.song.toLowerCase() == 'delirious')
			{
				delistatic = new FlxSprite(-440, -240);
				delistatic.frames = Paths.getSparrowAtlas('isaac/void/staticlol');
				delistatic.setGraphicSize(Std.int(delistatic.width * 7.2));
				delistatic.antialiasing = false;
				delistatic.cameras = [camOther];
				delistatic.animation.addByPrefix('move', 'Static', 24);
				delistatic.scrollFactor.set(0, 0);
				delistatic.animation.play('move');
				delistatic.updateHitbox();
				delistatic.alpha = 0;
				add(delistatic);
			}

		var bgSize:Float = 1;
		var bgSkin:String = 'healthBar';
		if (curStage == 'fatality')
		{
			bgSkin = "fatalHealth";
			bgSize = 1.5;
		}

		healthBarBG = new AttachedSprite(bgSkin);
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.setGraphicSize(Std.int(healthBarBG.width * bgSize));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		flippedHealthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, LEFT_TO_RIGHT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
		'health', 0, 2);
		flippedHealthBar.scrollFactor.set();
		// healthBar
		flippedHealthBar.visible = !ClientPrefs.hideHud;
		flippedHealthBar.alpha = 0;
		add(flippedHealthBar);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
		'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);

		if (curStage == 'defeatold'){
			healthBarBG.alpha = 0;
			healthBar.alpha = 0;
			iconP1.alpha = 0;
			iconP2.alpha = 0;
		}

		reloadHealthBarColors();

		usernameTxt.alpha = 0;
		chatTxt.alpha = 0;
		
		add(usernameTxt);
		add(chatTxt);

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font(gameFont), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font(gameFont), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		flashSprite = new FlxSprite(0, 0).makeGraphic(1920, 1080, 0xFFb30000);
		add(flashSprite);
		flashSprite.alpha = 0;

		if (SONG.song.toLowerCase() == 'chaos')
			{
				/*warning = new FlxSprite();
				warning.frames = Paths.getSparrowAtlas('Warning', 'exe');
				warning.cameras = [camHUD];
				warning.scale.set(0.5, 0.5);
				warning.screenCenter();
				warning.animation.addByPrefix('a', 'Warning Flash', 24, false);
				add(warning);*/

				dodgething = new FlxSprite(0, 600);
				dodgething.frames = Paths.getSparrowAtlas('Exe/spacebar_icon');
				dodgething.animation.addByPrefix('a', 'spacebar', 24, false, true);
				//dodgething.flipX = true;
				dodgething.scale.x = .5;
				dodgething.scale.y = .5;
				dodgething.screenCenter();
				dodgething.x -= 60;

				//warning.visible = false;
				dodgething.visible = false;

				add(dodgething);
			}

		if(sonicHUDStyles.exists(SONG.song.toLowerCase()))hudStyle = sonicHUDStyles.get(SONG.song.toLowerCase());
		var hudFolder = hudStyle;
		if(hudStyle == 'soniccd')hudFolder = 'sonic1';
		var scoreLabel:FlxSprite = new FlxSprite(15, 25).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/score"));
		scoreLabel.setGraphicSize(Std.int(scoreLabel.width * 3));
		scoreLabel.updateHitbox();
		scoreLabel.x = 15;
		scoreLabel.antialiasing = false;
		scoreLabel.scrollFactor.set();
		sonicHUD.add(scoreLabel);

		var timeLabel:FlxSprite = new FlxSprite(15, 70).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/time"));
		timeLabel.setGraphicSize(Std.int(timeLabel.width * 3));
		timeLabel.updateHitbox();
		timeLabel.x = 15;
		timeLabel.antialiasing = false;
		timeLabel.scrollFactor.set();
		sonicHUD.add(timeLabel);

		var ringsLabel:FlxSprite = new FlxSprite(15, 115).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/rings"));
		ringsLabel.setGraphicSize(Std.int(ringsLabel.width * 3));
		ringsLabel.updateHitbox();
		ringsLabel.x = 15;
		ringsLabel.antialiasing = false;
		ringsLabel.scrollFactor.set();

		var missLabel:FlxSprite = new FlxSprite(15, 115).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/misses"));
		missLabel.setGraphicSize(Std.int(missLabel.width * 3));
		missLabel.updateHitbox();
		missLabel.x = 15;
		missLabel.antialiasing = false;
		missLabel.scrollFactor.set();
		sonicHUD.add(missLabel);

		// score numbers
		if(hudFolder=='sonic3'){
			for(i in 0...7){
				var number = new SonicNumber(0, 0, 0);
				number.folder = hudFolder;
				number.setGraphicSize(Std.int(number.width*3));
				number.updateHitbox();
				number.x = scoreLabel.x + scoreLabel.width + ((9 * i) * 3);
				number.y = scoreLabel.y;
				scoreNumbers.push(number);
				sonicHUD.add(number);
			}
		}else{
			for(i in 0...7){
				var number = new SonicNumber(0, 0, 0);
				number.folder = hudFolder;
				number.setGraphicSize(Std.int(number.width*3));
				number.updateHitbox();
				number.x = scoreLabel.x + scoreLabel.width + ((9 * i) * 3);
				number.y = scoreLabel.y;
				scoreNumbers.push(number);
				sonicHUD.add(number);
			}
		}

		// ring numbers
		for(i in 0...3){
			var number = new SonicNumber(0, 0, 0);
			number.folder = hudFolder;
			number.setGraphicSize(Std.int(number.width*3));
			number.updateHitbox();
			number.x = ringsLabel.x + ringsLabel.width + (6*3) + ((9 * i) * 3);
			number.y = ringsLabel.y;
			ringsNumbers.push(number);
		}

		// miss numbers
		for(i in 0...4){
			var number = new SonicNumber(0, 0, 0);
			number.folder = hudFolder;
			number.setGraphicSize(Std.int(number.width*3));
			number.updateHitbox();
			number.x = missLabel.x + missLabel.width + (6*3) + ((9 * i) * 3);
			number.y = ringsLabel.y;
			missNumbers.push(number);
			sonicHUD.add(number);
		}


		// time numbers
		minNumber = new SonicNumber(0, 0, 0);
		minNumber.folder = hudFolder;
		minNumber.setGraphicSize(Std.int(minNumber.width*3));
		minNumber.updateHitbox();
		minNumber.x = timeLabel.x + timeLabel.width;
		minNumber.y = timeLabel.y;
		sonicHUD.add(minNumber);

		var timeColon:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/colon"));
		timeColon.setGraphicSize(Std.int(timeColon.width * 3));
		timeColon.updateHitbox();
		timeColon.x = 170;
		timeColon.y = timeLabel.y;
		timeColon.antialiasing = false;
		timeColon.scrollFactor.set();
		sonicHUD.add(timeColon);

		secondNumberA = new SonicNumber(0, 0, 0);
		secondNumberA.folder = hudFolder;
		secondNumberA.setGraphicSize(Std.int(secondNumberA.width*3));
		secondNumberA.updateHitbox();
		secondNumberA.x = 186;
		secondNumberA.y = timeLabel.y;
		sonicHUD.add(secondNumberA);

		secondNumberB = new SonicNumber(0, 0, 0);
		secondNumberB.folder = hudFolder;
		secondNumberB.setGraphicSize(Std.int(secondNumberB.width*3));
		secondNumberB.updateHitbox();
		secondNumberB.x = 213;
		secondNumberB.y = timeLabel.y;
		sonicHUD.add(secondNumberB);

		var timeQuote:FlxSprite = new FlxSprite(0, 0);
		if(hudFolder=='chaotix'){
			timeQuote.loadGraphic(Paths.image("sonicUI/" + hudFolder + "/quote"));
			timeQuote.setGraphicSize(Std.int(timeQuote.width * 3));
			timeQuote.updateHitbox();
			timeQuote.x = secondNumberB.x + secondNumberB.width;
			timeQuote.y = timeLabel.y;
			timeQuote.antialiasing = false;
			timeQuote.scrollFactor.set();
			sonicHUD.add(timeQuote);

			millisecondNumberA = new SonicNumber(0, 0, 0);
			millisecondNumberA.folder = hudFolder;
			millisecondNumberA.setGraphicSize(Std.int(millisecondNumberA.width*3));
			millisecondNumberA.updateHitbox();
			millisecondNumberA.x = timeQuote.x + timeQuote.width + (2*3);
			millisecondNumberA.y = timeLabel.y;
			sonicHUD.add(millisecondNumberA);

			millisecondNumberB = new SonicNumber(0, 0, 0);
			millisecondNumberB.folder = hudFolder;
			millisecondNumberB.setGraphicSize(Std.int(millisecondNumberB.width*3));
			millisecondNumberB.updateHitbox();
			millisecondNumberB.x = millisecondNumberA.x + millisecondNumberA.width + 3;
			millisecondNumberB.y = timeLabel.y;
			sonicHUD.add(millisecondNumberB);
		}

		switch(hudFolder){
			case 'chaotix':
				minNumber.x = timeLabel.x + timeLabel.width + (4*3);
				timeColon.x = minNumber.x + minNumber.width + (2*3);
				secondNumberA.x = timeColon.x + timeColon.width + (4*3);
				secondNumberB.x = secondNumberA.x + secondNumberA.width + 3;
				timeQuote.x = secondNumberB.x + secondNumberB.width;
				millisecondNumberA.x = timeQuote.x + timeQuote.width + (2*3);
				millisecondNumberB.x = millisecondNumberA.x + millisecondNumberA.width + 3;
			default:

		}

		if(!ClientPrefs.downScroll){
			for(member in sonicHUD.members){
				member.y = FlxG.height-member.height-member.y;
			}
		}

		if(sonicHUDSongs.contains(SONG.song.toLowerCase())){
			scoreTxt.visible=false;
			timeBar.visible=false;
			timeTxt.visible=false;
			timeBarBG.visible=false;
			add(sonicHUD);
		}

		updateSonicScore();
		updateSonicMisses();

		strumLineNotes.cameras = [camNotes];
		grpNoteSplashes.cameras = [camNotes];
		notes.cameras = [camNotes];
		flashSprite.cameras = [camOther];
		healthBar.cameras = [camHUD];
		flippedHealthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camNotes];
		usernameTxt.cameras = [camHUD];
		chatTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		if (SONG.song.toLowerCase() == 'chaos')
			{
				//warning.cameras = [camHUD];
				dodgething.cameras = [camHUD];
			}
		doof.cameras = [camHUD];
		laneunderlay.cameras = [camNotes];
		fadeOutBlack.cameras = [camNotes];
		fadeOutBlack2.cameras = [camNotes];
		fadeInBlack.cameras = [camNotes];
		fadeInBlack2.cameras = [camNotes];
		sonicHUD.cameras = [camHUD];
		startCircle.cameras = [camOther];
		startText.cameras = [camOther];
		blackFuck.cameras = [camOther];
		topBar.cameras = [camOther];
		bottomBar.cameras = [camOther];

		blackFade = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
		blackFade.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.BLACK);
		blackFade.alpha = 0;
		blackFade.cameras = [camGame];
		add(blackFade);

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		
		switch (curSong.toLowerCase())
		{
			case 'delirious':
							
				introText = new FlxSprite(-750, 200);
				introText.frames = Paths.getSparrowAtlas('IntroText/deli','shared');
				introText.animation.addByPrefix('shit','del',24,false);
				introText.animation.play('shit');
				introText.setGraphicSize(Std.int(introText.width * 1));
				introText.cameras = [camHUD];
				add(introText);
				FlxG.sound.play(Paths.sound('whoop'));
				introText.animation.finishCallback = function(name:String) {
					remove(introText);	
				}
				FlxG.sound.play(Paths.sound('voidintro'));
				FlxG.sound.play(Paths.sound('death_card_mix'));
				new FlxTimer().start(0.3, function(dstatictimer:FlxTimer)
				{
					if (paused)
					{
						delistatic.alpha += 0;
						dstatictimer.reset();
					}
					else
					{
					if (delistatic.alpha > 0)
					{
						delistatic.alpha -= 0.05;
					}
					dstatictimer.reset();
					}
				});
				startCountdown();
		}

		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		for (event in eventPushedMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_events/' + event + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) + '/' ));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		if (curStage == 'nevada' || curStage == 'auditorHell')
			{
				add(tstatic);
				tstatic.alpha = 0.1;
				tstatic.setGraphicSize(Std.int(tstatic.width * 12));
				tstatic.x += 600;
			}

		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					camNotes.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							camNotes.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				case 'ugh' | 'guns' | 'stress':
					tankIntro();

				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			if (curSong.toLowerCase() == 'infitrigger'){
				vmodintros();
			}
			switch (daSong)
			{
				case 'chaos':
					cinematicBarsExe(true);
					FlxG.camera.zoom = defaultCamZoom;
					camHUD.visible = false;
					camNotes.visible = false;
					dad.visible = false;
					boyfriend.visible = false;
					dad.setPosition(600, 400);
					snapCamFollowToPos(900, 700);
					// camFollowPos.setPosition(900, 700);
					FlxG.camera.focusOn(camFollowPos.getPosition());
					new FlxTimer().start(0.5, function(lol:FlxTimer)
					{
						if (true) // unclocked fleetway
						{
							new FlxTimer().start(1, function(lol:FlxTimer)
							{
								FlxTween.tween(FlxG.camera, {zoom: 1.5}, 3, {ease: FlxEase.cubeOut});
								FlxG.sound.play(Paths.sound('robot'));
								FlxG.camera.flash(FlxColor.RED, 0.2);
							});
							new FlxTimer().start(2, function(lol:FlxTimer)
							{
								FlxG.sound.play(Paths.sound('sonic'));
								thechamber.animation.play('a');
							});

							new FlxTimer().start(3.2, function(lol:FlxTimer)
							{
								boyfriendGroup.remove(boyfriend);
								var oldbfx = boyfriend.x;
								var oldbfy = boyfriend.y;
								boyfriend = new Boyfriend(oldbfx, oldbfy, 'bf-super');
								boyfriendGroup.add(boyfriend);
								boyfriendGroup.remove(boyfriend);

								var oldbfx = boyfriend.x;
								var oldbfy = boyfriend.y;
								boyfriend = new Boyfriend(oldbfx, oldbfy, 'bf');
							});

							new FlxTimer().start(6, function(lol:FlxTimer)
							{
								startCountdown();
								FlxG.sound.play(Paths.sound('beam'));
								FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.2, {ease: FlxEase.cubeOut});
								FlxG.camera.shake(0.02, 0.2);
								FlxG.camera.flash(FlxColor.WHITE, 0.2);
								floor.animation.play('b');
								fleetwaybgshit.animation.play('b');
								pebles.animation.play('b');
								emeraldbeamyellow.visible = true;
								emeraldbeam.visible = false;
							});
						}
						else
							lol.reset();
					});
				case 'sunshine':
					/*var startthingy:FlxSprite = new FlxSprite();
					startthingy.frames = Paths.getSparrowAtlas('TdollStart', 'exe');
					startthingy.animation.addByPrefix('sus', 'Start', 24, false);
					startthingy.cameras = [camHUD];
					add(startthingy);
					startthingy.screenCenter();*/
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Exe/ready'));
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Exe/set'));
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Exe/go'));

					ready.scale.x = 0.5; // i despise all coding.
					set.scale.x = 0.5;
					go.scale.x = 0.7;
					ready.scale.y = 0.5;
					set.scale.y = 0.5;
					go.scale.y = 0.7;
					ready.screenCenter();
					set.screenCenter();
					go.screenCenter();
					ready.cameras = [camHUD];
					set.cameras = [camHUD];
					go.cameras = [camHUD];
					var amongus:Int = 0;


					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						switch (amongus)
						{
							case 0:
								startCountdown();
								add(ready);
								FlxTween.tween(ready.scale, {x: .9, y: .9}, Conductor.crochet / 500);
								FlxG.sound.play(Paths.sound('ready'));
							case 1:
								ready.visible = false;
								add(set);
								FlxTween.tween(set.scale, {x: .9, y: .9}, Conductor.crochet / 500);
								FlxG.sound.play(Paths.sound('set'));
							case 2:
								set.visible = false;
								add(go);
								FlxTween.tween(go.scale, {x: 1.1, y: 1.1}, Conductor.crochet / 500);
								FlxG.sound.play(Paths.sound('go'));
							case 3:
								go.visible = false;
								canPause = true;
						}
						amongus += 1;
						if (amongus < 5)
							tmr.reset(Conductor.crochet / 700);
					});

				case "fatality":
					var swagCounter:Int = 0;
					startCountdown();
					startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
					{
						switch (swagCounter)
						{
							case 0:
								FlxG.sound.play(Paths.sound('Fatal_3'));
							case 1:
								FlxG.sound.play(Paths.sound('Fatal_2'));
								var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image("Exe/StartScreens/fatal_2"));
								ready.scrollFactor.set();

								ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

								ready.updateHitbox();

								ready.screenCenter();
								add(ready);
								countDownSprites.push(ready);
								FlxTween.tween(ready, {alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										countDownSprites.remove(ready);
										remove(ready);
										ready.destroy();
									}
								});
							case 2:
								FlxG.sound.play(Paths.sound('Fatal_1'));
								var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image("Exe/StartScreens/fatal_1"));
								set.scrollFactor.set();

								set.setGraphicSize(Std.int(set.width * daPixelZoom));

								set.screenCenter();
								add(set);
								countDownSprites.push(set);
								FlxTween.tween(set, {alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										countDownSprites.remove(set);
										remove(set);
										set.destroy();
									}
								});
							case 3:
								FlxG.sound.play(Paths.sound('Fatal_go'));
								var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image("Exe/StartScreens/fatal_go"));
								go.scrollFactor.set();

								go.setGraphicSize(Std.int(go.width * daPixelZoom));

								go.updateHitbox();

								go.screenCenter();
								add(go);
								countDownSprites.push(go);
								FlxTween.tween(go, {alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										countDownSprites.remove(go);
										remove(go);
										go.destroy();
									}
								});
							case 4:
						}
						if (swagCounter != 3)
							tmr.reset();

						swagCounter += 1;
					});
				case 'too-slow' | 'too-slow-encore' | 'you-cant-run' | 'triple-trouble' | 'endless' | 'endless-old' | 'cycles' | 'execution' |'prey' | 'fight-or-flight' | 'round-a-bout' | 'faker':

					if (daSong == 'Too Slow' || daSong == 'Too Slow Encore' || daSong == 'you-cant-run' || daSong == 'Cycles' || daSong == 'Execution')
						{
							startSong();
							startCountdown();
						}
					else
						{
							startCountdown();
						}

					add(blackFuck);
					startCircle.loadGraphic(Paths.image('Exe/StartScreens/Circle-'+ daSong));
					startCircle.x += 900;
					add(startCircle);
					startText.loadGraphic(Paths.image('Exe/StartScreens/Text-' + daSong));
					startText.x -= 1200;
					add(startText);

					new FlxTimer().start(0.6, function(tmr:FlxTimer)
					{
						FlxTween.tween(startCircle, {x: 0}, 0.5);
						FlxTween.tween(startText, {x: 0}, 0.5);
					});

					new FlxTimer().start(1.9, function(tmr:FlxTimer)
					{
						FlxTween.tween(blackFuck, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween)
							{
								remove(blackFuck);
								blackFuck.destroy();
							}
						});
						FlxTween.tween(startCircle, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween)
							{
								remove(startCircle);
								startCircle.destroy();
							}
						});
						FlxTween.tween(startText, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween)
							{
								remove(startText);
								startText.destroy();
							}
						});
					});
				case 'acceptance':
					if (curStage == 'chest')
					{
				    camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			        var misseffect:FlxSprite = new FlxSprite(-7000, 0);
			        misseffect.frames = Paths.getSparrowAtlas('isaac/chest/misseffect','shared');
			        misseffect.animation.addByPrefix('miss','hurt',24,false);
			        misseffect.animation.play('miss');
			        misseffect.setGraphicSize(Std.int(misseffect.width * 0.7));
				    misseffect.antialiasing = true;
				    misseffect.cameras = [camHUD];
				    misseffect.scrollFactor.set(0, 0);
			        add(misseffect);
			        misseffect.animation.finishCallback = function(name:String) {
			        	remove(misseffect);		
			        }
				    var bluebabyintro = new FlxSprite(-600,-850);
					bluebabyintro.frames = Paths.getSparrowAtlas('isaac/chest/bluebabyintro','shared');
					bluebabyintro.animation.addByPrefix('spawn','intro',24,false);
					bluebabyintro.visible = false;
					bluebabyintro.antialiasing = true;
					healthBar.visible = false;
					healthBarBG.visible = false;
					scoreTxt.visible = false;
					iconP1.visible = false;
					iconP2.visible = false;
					add(bluebabyintro);
					FlxTween.tween(camHUD, {zoom: 1.2}, 6);
					
						    new FlxTimer().start(3, function(introtimer:FlxTimer)
						    {
							IsaacInChest.alpha = 1;
							House.visible = false;
							rain.volume = 0.6;

						new FlxTimer().start(5, function(introtimerex:FlxTimer)
						{
                            IsaacInChest.alpha = 0;
							rain.volume = 0.3;
							FlxTween.tween(FlxG.camera, {zoom: 0.70});
							FlxG.camera.flash(FlxColor.BLACK, 2.5);
							bluebabyintro.visible = true;
							healthBar.visible = true;
					        healthBarBG.visible = true;
					        scoreTxt.visible = true;
					        iconP1.visible = true;
					        iconP2.visible = true;
							FlxTween.tween(camHUD, {zoom: 1}, 1);
						    new FlxTimer().start(3, function(introtimer:FlxTimer)
						    {
							    bluebabyintro.animation.play('spawn');
							    FlxG.sound.play(Paths.sound('bbintro'));
						    });
						});
				            });
					
                    bluebabyintro.animation.finishCallback = function(pog:String)
				    {
						dadGroup.visible = true;
						remove(bluebabyintro);
						canhitspace = true;
						rain.fadeOut();
						if (curStage == 'chest')
						{
						    chestidle.visible = true;
							if (ClientPrefs.flashing)
								FlxG.camera.flash(0xFFfffae8, 3);
							introText = new FlxSprite(-750, 200);
							introText.frames = Paths.getSparrowAtlas('IntroText/acce','shared');
							introText.animation.addByPrefix('shit','acc',24,false);
							introText.animation.play('shit');
							introText.setGraphicSize(Std.int(introText.width * 1));
							introText.cameras = [camHUD];
							add(introText);
							introText.animation.finishCallback = function(name:String) {
								remove(introText);									
							}
							FlxG.sound.play(Paths.sound('whoop'));
							canblind = true;
						}
						startCountdown();
					};
					gf.visible = false;
					}
				case 'delirious':
				    if (curStage == 'void')
					{
						gf.visible = false;
						boyfriend.visible = false;
						iconP2.alpha = 0;
						new FlxTimer().start(0.03, function(statictimer:FlxTimer)
						{
							if (staticlol.alpha > 0.1)
							{
								staticlol.alpha -= 0.05;	
								statictimer.reset();
							}
							else
							{
								statictimer.reset();
							}
						});
					}					
				case 'expurgation':
					dad.visible = false;
					camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					var spawnAnim = new FlxSprite(-150,-380);
					spawnAnim.frames = Paths.getSparrowAtlas('expurgation/EXENTER');

					spawnAnim.animation.addByPrefix('start','Entrance',24,false);

					add(spawnAnim);

					spawnAnim.animation.play('start');
					var p = new FlxSound().loadEmbedded(Paths.sound("Trickyspawn"));
					var pp = new FlxSound().loadEmbedded(Paths.sound("TrickyGlitch"));
					p.play();
					spawnAnim.animation.finishCallback = function(pog:String)
						{
							pp.fadeOut();
							dad.visible = true;
							remove(spawnAnim);
							startCountdown();
						}
					new FlxTimer().start(0.001, function(tmr:FlxTimer)
						{
							if (spawnAnim.animation.frameIndex == 24)
							{
								pp.play();
							}
							else
								tmr.reset(0.001);
						});
				case 'infitrigger', 'sunshine', 'chaos':

				default:
					startCountdown();
			}
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		precacheList.set('alphabet', 'image');

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter());
		#end


		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		callOnLuas('onCreatePost', []);

		super.create();

		cacheCountdown();
		cachePopUpScore();

		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		Paths.clearUnusedMemory();

		switch(SONG.song.toLowerCase()){
			case 'sunshine':
				transIn = OvalTransitionSubstate;
			default:

		}
		var shapeTransState:ShapeTransitionSubstate = cast transIn;
		var shapeTrans = (shapeTransState is ShapeTransitionSubstate);
		if(shapeTrans){
			ShapeTransitionSubstate.nextCamera = camOther;
		}else{
			FadeTransitionSubstate.nextCamera = camOther;
		}

		CustomFadeTransition.nextCamera = camOther;
	}

	//the clown
	function doStopSign(sign:Int = 0, fuck:Bool = false)
		{
			//trace('sign ' + sign);
			daSign = new FlxSprite(0,0);

			daSign.frames = Paths.getSparrowAtlas('expurgation/Sign_Post_Mechanic');
	
			daSign.setGraphicSize(Std.int(daSign.width * 0.67));
	
			daSign.cameras = [camOther];
	
			switch(sign)
			{
				case 0:
					daSign.animation.addByPrefix('sign','Signature Stop Sign 1',24, false);
					daSign.x = FlxG.width - 650;
					daSign.angle = -90;
					daSign.y = -300;
				case 1:
					/*daSign.animation.addByPrefix('sign','Signature Stop Sign 2',20, false);
					daSign.x = FlxG.width - 670;
					daSign.angle = -90;*/ // this one just doesn't work???
				case 2:
					daSign.animation.addByPrefix('sign','Signature Stop Sign 3',24, false);
					daSign.x = FlxG.width - 780;
					daSign.angle = -90;
					if (ClientPrefs.downScroll)
						daSign.y = -395;
					else
						daSign.y = -980;
				case 3:
					daSign.animation.addByPrefix('sign','Signature Stop Sign 4',24, false);
					daSign.x = FlxG.width - 1070;
					daSign.angle = -90;
					daSign.y = -145;
			}
			add(daSign);
			daSign.flipX = fuck;
			daSign.animation.play('sign');
			daSign.animation.finishCallback = function(pog:String)
				{
					//trace('ended sign');
					remove(daSign);
				}
		}	
	
	var totalDamageTaken:Float = 0;

	var shouldBeDead:Bool = false;

	var interupt = false;

	// basic explanation of this is:
	// get the health to go to
	// tween the gremlin to the icon
	// play the grab animation and do some funny maths,
	// to figure out where to tween to.
	// lerp the health with the tween progress
	// if you loose any health, cancel the tween.
	// and fall off.
	// Once it finishes, fall off.

	function doGremlin(hpToTake:Int, duration:Int,persist:Bool = false)
		{
			interupt = false;
	
			grabbed = true;

			canPause = false;
			
			totalDamageTaken = 0;
	
			var gramlan:FlxSprite = new FlxSprite(0,0);
	
			gramlan.frames = Paths.getSparrowAtlas('expurgation/HP GREMLIN');

			gramlan.setGraphicSize(Std.int(gramlan.width * 0.76));
	
			gramlan.x = iconP1.x;
			gramlan.y = healthBarBG.y - 325;
	
			gramlan.animation.addByIndices('come','HP Gremlin ANIMATION',[0,1], "", 24, false);
			gramlan.animation.addByIndices('grab','HP Gremlin ANIMATION',[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24], "", 24, false);
			gramlan.animation.addByIndices('hold','HP Gremlin ANIMATION',[25,26,27,28],"",24);
			gramlan.animation.addByIndices('release','HP Gremlin ANIMATION',[29,30,31,32,33],"",24,false);
	
			add(gramlan);

			gramlan.cameras = [camHUD];
	
			if(ClientPrefs.downScroll){
				gramlan.flipY = true;
				gramlan.y -= 150;
			}
			
			// over use of flxtween :)
	
			var startHealth = health;
			var toHealth = (hpToTake / 100) * startHealth; // simple math, convert it to a percentage then get the percentage of the health
	
			var perct = toHealth / 2 * 100;
	
			trace('start: $startHealth\nto: $toHealth\nwhich is prect: $perct');
	
			var onc:Bool = false;
	
			FlxG.sound.play(Paths.sound('GremlinWoosh'));
	
			gramlan.animation.play('come');
			new FlxTimer().start(0.14, function(tmr:FlxTimer) {
				gramlan.animation.play('grab');
				FlxTween.tween(gramlan,{x: iconP1.x - 140},1,{ease: FlxEase.elasticIn, onComplete: function(tween:FlxTween) {
					trace('I got em');
					gramlan.animation.play('hold');
					FlxTween.tween(gramlan,{
						x: (healthBar.x + 
						(healthBar.width * (FlxMath.remapToRange(perct, 0, 100, 100, 0) * 0.01) 
						- 26)) - 75}, duration,
					{
						onUpdate: function(tween:FlxTween) { 
							// lerp the health so it looks pog
							if (interupt && !onc && !persist)
							{
								onc = true;
								trace('oh shit');
								gramlan.animation.play('release');
								gramlan.animation.finishCallback = function(pog:String) { gramlan.alpha = 0;}
							}
							else if (!interupt || persist)
							{
								var pp = FlxMath.lerp(startHealth,toHealth, tween.percent);
								if (pp <= 0)
									pp = 0.1;
								health = pp;
							}
	
							if (shouldBeDead)
								health = 0;
						},
						onComplete: function(tween:FlxTween)
						{
							if (interupt && !persist)
							{
								remove(gramlan);
								grabbed = false;
								canPause = true;
							}
							else
							{
								trace('oh shit');
								gramlan.animation.play('release');
								if (persist && totalDamageTaken >= 0.7)
									health -= totalDamageTaken; // just a simple if you take a lot of damage wtih this, you'll loose probably.
								gramlan.animation.finishCallback = function(pog:String) { remove(gramlan);}
								grabbed = false;
								canPause = true;
							}
						}
					});
				}});
			});
		}	
	
	var cloneOne:FlxSprite;
	var cloneTwo:FlxSprite;

	function doClone(side:Int)
	{
		switch(side)
		{
			case 0:
				if (cloneOne.alpha == 1)
					return;
				cloneOne.x = dad.x + 20;
				cloneOne.y = dad.y + 140;
				cloneOne.alpha = 1;

				cloneOne.animation.play('clone');
				cloneOne.animation.finishCallback = function(pog:String) {cloneOne.alpha = 0;}
			case 1:
				if (cloneTwo.alpha == 1)
					return;
				cloneTwo.x = dad.x + 450;
				cloneTwo.y = dad.y + 140;
				cloneTwo.alpha = 1;

				cloneTwo.animation.play('clone');
				cloneTwo.animation.finishCallback = function(pog:String) {cloneTwo.alpha = 0;}
		}

	}

	function canScream():Void
		{
			FlxG.camera.shake(0.009,1);           
			trace('cancer chimping out !!!!');
			
				remove(dadGroup);
				aaaaa.setPosition(dad.x,dad.y);  
				add(aaaaa);
				aaaaa.animation.play('aaaaaaaa');
				aaaaa.animation.finishCallback = function(hh:String)
					{							
						remove(aaaaa);	
						add(dadGroup);								
					}	
		}

	function vmodintros():Void
		{
             ///flx timer abuse
			switch(curSong.toLowerCase())
				{ 
								case'infitrigger':
									inScene = true;				
									camFollow.set(boyfriendGroup.getMidpoint().x -415, boyfriendGroup.getMidpoint().y - 165);	
											FlxG.camera.zoom = 1.2;
											camHUD.visible = false; 	
											camNotes.visible = false;
											dad.visible = false;
											remove(boyfriendGroup);
											var cancer1 = new FlxSprite(640,-40);
											cancer1.scale.set(0.85,0.85);
											cancer1.frames = Paths.getSparrowAtlas('bonus/intro/cancer1');
											cancer1.animation.addByPrefix('comehere','cancer_intro_1',24,false);
											cancer1.antialiasing = ClientPrefs.globalAntialiasing;
											add(cancer1);
											
											var cancer2 = new FlxSprite(dad.x,dad.y-89);
											cancer2.scale.set(0.92,0.92);
											cancer2.frames = Paths.getSparrowAtlas('bonus/intro/cancer2');
											cancer2.animation.addByPrefix('sit','cancer_intro_2',24,false);
											cancer2.antialiasing = ClientPrefs.globalAntialiasing;
											
											var boy = new FlxSprite(boyfriendGroup.x,boyfriendGroup.y);
											boy.frames = Paths.getSparrowAtlas('bonus/intro/bf');
											boy.animation.addByPrefix('sit','bf_intro',24,false);
											boy.antialiasing = ClientPrefs.globalAntialiasing;
											


											new FlxTimer().start(1, function(holdem:FlxTimer)
												{
													cancer1.animation.play('comehere');
													cancer1.animation.finishCallback = function(whitewhitty:String)
															{			
																FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom},1, {ease: FlxEase.quadInOut,
																	onComplete: function(twn:FlxTween)
																			{
																				new FlxTimer().start(1, function(holdem:FlxTimer)
																					{
																							add(boy);
																							 add(cancer2);
																							 boy.animation.play('sit');
																							 cancer2.animation.play('sit');
																							 cancer2.animation.finishCallback = function(lol:String)
																							 {	
																									boy.kill();
																									cancer2.kill();																						
																								    				
																									 dad.visible = true;
																									 add(boyfriendGroup);
																									 new FlxTimer().start(0.3, function(startin:FlxTimer)
																										{
																											camHUD.visible = true;
																											camNotes.visible = true;
																											startCountdown();			     	
																									    });
																						 
								}											 
							});
						}
					});																				
				} 
			});
		}
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.shaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			FlxG.sound.music.pitch = value;
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		trace('Anim speed: ' + FlxAnimationController.globalSpeed);
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors() {
		flippedHealthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
		FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
		FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		flippedHealthBar.updateBar();
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
			case 3:
				if (!momMap.exists(newCharacter))
				{
					var newMom:Character = new Character(0, 0, newCharacter);
					momMap.set(newCharacter, newMom);
					momGroup.add(newMom);
					startCharacterPos(newMom);
					newMom.alpha = 0.00001;
					startCharacterLua(newMom.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) {
			doPush = true;
		}
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:MP4Handler = new MP4Handler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			startAndEnd();
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function pendulumFade() {
		pendulum.alpha = 0;
		tranceActive = false;
	}
	public function psyshock(?real:Bool = true) {
		psyshockParticle.setPosition(dadGroup.x + 825, dadGroup.y - 75);

		// if (dad.curCharacter == 'hypno-two')
		// 	{
		// 		psyshockParticle.setPosition(dadGroup.x + 625, dadGroup.y + 200);
		// 	}

		if (dad.curCharacter == 'abomination-hypno')
			{
				psyshockParticle.setPosition(dadGroup.x - 100, dadGroup.y + 200);
				psyshockParticle.flipX = true;
			}

		psyshockParticle.animation.play('psyshock');
		psyshockParticle.visible = true;
		psyshockParticle.animation.finishCallback = function(name:String)
			{
				psyshockParticle.visible = false;
			};

		FlxG.sound.play(Paths.sound('Psyshock'), 0.6);
		if (ClientPrefs.flashing) flash();

		if (real)
			trance += 0.25;
		else {
			tranceDeathScreen.alpha += 0.1;
			tranceCanKill = false;
		}
	}

	var flashTween:FlxTween;
	function flash() {
		cameraFlash.alpha = 1;
		flashTween = FlxTween.tween(cameraFlash, {alpha: 0}, 1);
	}

	function tankIntro()
	{
		var cutsceneHandler:CutsceneHandler = new CutsceneHandler();

		var songName:String = Paths.formatToSongPath(SONG.song);
		dadGroup.alpha = 0.00001;
		camHUD.visible = false;
		//inCutscene = true; //this would stop the camera movement, oops

		var tankman:FlxSprite = new FlxSprite(-20, 320);
		tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
		tankman.antialiasing = ClientPrefs.globalAntialiasing;
		addBehindDad(tankman);
		cutsceneHandler.push(tankman);

		var tankman2:FlxSprite = new FlxSprite(16, 312);
		tankman2.antialiasing = ClientPrefs.globalAntialiasing;
		tankman2.alpha = 0.000001;
		cutsceneHandler.push(tankman2);
		var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfDance);
		var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
		gfCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfCutscene);
		var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);
		picoCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(picoCutscene);
		var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		boyfriendCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(boyfriendCutscene);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			moveCamera(true);
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
		};

		camFollow.set(dad.x + 280, dad.y + 170);
		switch(songName)
		{
			case 'ugh':
				cutsceneHandler.endTime = 12;
				cutsceneHandler.music = 'DISTORTO';
				precacheList.set('wellWellWell', 'sound');
				precacheList.set('killYou', 'sound');
				precacheList.set('bfBeep', 'sound');

				var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
				FlxG.sound.list.add(wellWellWell);

				tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				tankman.animation.play('wellWell', true);
				FlxG.camera.zoom *= 1.2;

				// Well well well, what do we got here?
				cutsceneHandler.timer(0.1, function()
				{
					wellWellWell.play(true);
				});

				// Move camera to BF
				cutsceneHandler.timer(3, function()
				{
					camFollow.x += 750;
					camFollow.y += 100;
				});

				// Beep!
				cutsceneHandler.timer(4.5, function()
				{
					boyfriend.playAnim('singUP', true);
					boyfriend.specialAnim = true;
					FlxG.sound.play(Paths.sound('bfBeep'));
				});

				// Move camera to Tankman
				cutsceneHandler.timer(6, function()
				{
					camFollow.x -= 750;
					camFollow.y -= 100;

					// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
					tankman.animation.play('killYou', true);
					FlxG.sound.play(Paths.sound('killYou'));
				});

			case 'guns':
				cutsceneHandler.endTime = 11.5;
				cutsceneHandler.music = 'DISTORTO';
				tankman.x += 40;
				tankman.y += 10;
				precacheList.set('tankSong2', 'sound');

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
				FlxG.sound.list.add(tightBars);

				tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				tankman.animation.play('tightBars', true);
				boyfriend.animation.curAnim.finish();

				cutsceneHandler.onStart = function()
				{
					tightBars.play(true);
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
				};

				cutsceneHandler.timer(4, function()
				{
					gf.playAnim('sad', true);
					gf.animation.finishCallback = function(name:String)
					{
						gf.playAnim('sad', true);
					};
				});

			case 'stress':
				cutsceneHandler.endTime = 35.5;
				tankman.x -= 54;
				tankman.y -= 14;
				gfGroup.alpha = 0.00001;
				boyfriendGroup.alpha = 0.00001;
				camFollow.set(dad.x + 400, dad.y + 170);
				FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.y += 100;
				});
				precacheList.set('stressCutscene', 'sound');

				tankman2.frames = Paths.getSparrowAtlas('cutscenes/stress2');
				addBehindDad(tankman2);

				if (!ClientPrefs.lowQuality)
				{
					gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
					gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
					gfDance.animation.play('dance', true);
					addBehindGF(gfDance);
				}

				gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
				gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
				gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
				gfCutscene.animation.play('dieBitch', true);
				gfCutscene.animation.pause();
				addBehindGF(gfCutscene);
				if (!ClientPrefs.lowQuality)
				{
					gfCutscene.alpha = 0.00001;
				}

				picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
				picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
				addBehindGF(picoCutscene);
				picoCutscene.alpha = 0.00001;

				boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				boyfriendCutscene.animation.play('idle', true);
				boyfriendCutscene.animation.curAnim.finish();
				addBehindBF(boyfriendCutscene);

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(cutsceneSnd);

				tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				tankman.animation.play('godEffingDamnIt', true);

				var calledTimes:Int = 0;
				var zoomBack:Void->Void = function()
				{
					var camPosX:Float = 630;
					var camPosY:Float = 425;
					camFollow.set(camPosX, camPosY);
					camFollowPos.setPosition(camPosX, camPosY);
					FlxG.camera.zoom = 0.8;
					cameraSpeed = 1;

					calledTimes++;
					if (calledTimes > 1)
					{
						foregroundSprites.forEach(function(spr:BGSprite)
						{
							spr.y -= 100;
						});
					}
				}

				cutsceneHandler.onStart = function()
				{
					cutsceneSnd.play(true);
				};

				cutsceneHandler.timer(15.2, function()
				{
					FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});

					gfDance.visible = false;
					gfCutscene.alpha = 1;
					gfCutscene.animation.play('dieBitch', true);
					gfCutscene.animation.finishCallback = function(name:String)
					{
						if(name == 'dieBitch') //Next part
						{
							gfCutscene.animation.play('getRektLmao', true);
							gfCutscene.offset.set(224, 445);
						}
						else
						{
							gfCutscene.visible = false;
							picoCutscene.alpha = 1;
							picoCutscene.animation.play('anim', true);

							boyfriendGroup.alpha = 1;
							boyfriendCutscene.visible = false;
							boyfriend.playAnim('bfCatch', true);
							boyfriend.animation.finishCallback = function(name:String)
							{
								if(name != 'idle')
								{
									boyfriend.playAnim('idle', true);
									boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
								}
							};

							picoCutscene.animation.finishCallback = function(name:String)
							{
								picoCutscene.visible = false;
								gfGroup.alpha = 1;
								picoCutscene.animation.finishCallback = null;
							};
							gfCutscene.animation.finishCallback = null;
						}
					};
				});

				cutsceneHandler.timer(17.5, function()
				{
					zoomBack();
				});

				cutsceneHandler.timer(19.5, function()
				{
					tankman2.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					tankman2.animation.play('lookWhoItIs', true);
					tankman2.alpha = 1;
					tankman.visible = false;
				});

				cutsceneHandler.timer(20, function()
				{
					camFollow.set(dad.x + 500, dad.y + 170);
				});

				cutsceneHandler.timer(31.2, function()
				{
					boyfriend.playAnim('singUPmiss', true);
					boyfriend.animation.finishCallback = function(name:String)
					{
						if (name == 'singUPmiss')
						{
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
						}
					};

					camFollow.set(boyfriend.x + 280, boyfriend.y + 200);
					cameraSpeed = 12;
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
				});

				cutsceneHandler.timer(32.2, function()
				{
					zoomBack();
				});
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	public var camMovement:Float = 40;
	public var velocity:Float = 1;
	public var campointx:Float = 0;
	public var campointy:Float = 0;
	public var camlockx:Float = 0;
	public var camlocky:Float = 0;
	public var camlock:Bool = false;
	public var bfturn:Bool = false;


	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);
		introAssets.set('vtan', ['ready-vtan', 'set-vtan', 'go-vtan']);
		introAssets.set('dside', ['ready-dside', 'set-dside', 'go-dside']);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage) introAlts = introAssets.get('pixel');
		if (vtanSong) introAlts = introAssets.get('vtan');
		if (curSong == 'Too Slow Dside') introAlts = introAssets.get('dside');
		
		for (asset in introAlts)
			Paths.image(asset);
		
		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}
	
	public function updateLuaDefaultPos() {
		for (i in 0...playerStrums.length) {
			setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
			setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
		}
		for (i in 0...opponentStrums.length) {
			setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
			setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
			//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
		}
	}

	public var countDownSprites:Array<FlxSprite> = [];

	public function startCountdown():Void
	{
		switch(curStage.toLowerCase()){
			case 'cargo':
				camHUD.visible = false;
				camNotes.visible = false;
			case 'defeat':
				botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		if (pendulumMode)
			tranceActive = true;

		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		inScene = false;

		var ret:Dynamic = callOnLuas('onStartCountdown', [], false);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			
			updateLuaDefaultPos();

			laneunderlay.x = playerStrums.members[0].x - 10;
			laneunderlay.screenCenter(Y);

			if(sonicHUDSongs.contains(SONG.song.toLowerCase())){
				healthBar.x += 150;
				iconP1.x += 150;
				iconP2.x += 150;
				healthBarBG.x += 150;
			}
			
			if (fadeOut){
				add(fadeOutBlack);
				add(fadeOutBlack2);

				fadeOutBlack.x = playerStrums.members[0].x - 10;
				if (ClientPrefs.downScroll)
					fadeOutBlack.y = playerStrums.members[0].y - 340;
				else
					fadeOutBlack.y = playerStrums.members[0].y + 140;
	
				fadeOutBlack2.x = playerStrums.members[0].x - 10;
				if (ClientPrefs.downScroll)
					fadeOutBlack2.y = playerStrums.members[0].y - 80;
				else
					fadeOutBlack2.y = playerStrums.members[0].y - 150;

				FlxTween.tween(fadeOutBlack, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(fadeOutBlack2, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
			}

			if (fadeIn){
				add(fadeInBlack);
				add(fadeInBlack2);

				fadeInBlack.x = playerStrums.members[0].x - 10;
				if (ClientPrefs.downScroll)
					fadeInBlack.y = playerStrums.members[0].y - 375;
				else
					fadeInBlack.y = playerStrums.members[0].y + 175;
	
				fadeInBlack2.x = playerStrums.members[0].x - 10;
				if (ClientPrefs.downScroll)
					fadeInBlack2.y = playerStrums.members[0].y - 675;
				else
					fadeInBlack2.y = playerStrums.members[0].y + 425;

				FlxTween.tween(fadeInBlack, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(fadeInBlack2, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
			}

			FlxTween.tween(laneunderlay, {alpha: ClientPrefs.underlaneVisibility}, 0.5, {ease: FlxEase.quadOut});

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if(startOnTime < 0) startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}
				if (tmr.loopsLeft % mom.danceEveryNumBeats == 0 && mom.animation.curAnim != null && !mom.animation.curAnim.name.startsWith('sing') && !mom.stunned)
				{
					mom.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);
				introAssets.set('vtan', ['ready-vtan', 'set-vtan', 'go-vtan']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}
				if(curSong.toLowerCase() == 'sage' || curSong.toLowerCase() == 'infitrigger')
					introAlts = introAssets.get('vtan');

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);

					bottomBoppers.dance(true);
					santa.dance(true);
				}

				if (!noCountdown){
					switch (swagCounter)
					{
						case 0:
							FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						case 1:
							countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
							countdownReady.cameras = [camHUD];
							countdownReady.scrollFactor.set();
							countdownReady.updateHitbox();
	
							if (PlayState.isPixelStage)
								countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));
	
							countdownReady.screenCenter();
							countdownReady.antialiasing = antialias;
							insert(members.indexOf(notes), countdownReady);
							FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									remove(countdownReady);
									countdownReady.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
						case 2:
							countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
							countdownSet.cameras = [camHUD];
							countdownSet.scrollFactor.set();
	
							if (PlayState.isPixelStage)
								countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));
	
							countdownSet.screenCenter();
							countdownSet.antialiasing = antialias;
							insert(members.indexOf(notes), countdownSet);
							FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									remove(countdownSet);
									countdownSet.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
						case 3:
							countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
							countdownGo.cameras = [camHUD];
							countdownGo.scrollFactor.set();
	
							if (PlayState.isPixelStage)
								countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));
	
							countdownGo.updateHitbox();
	
							countdownGo.screenCenter();
							countdownGo.antialiasing = antialias;
							insert(members.indexOf(notes), countdownGo);
							FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									remove(countdownGo);
									countdownGo.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						case 4:
					}
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.opponentStrums || note.mustPress || curStage == 'defeat' || curStage == 'defeatold')
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.middleScroll && !note.mustPress) {
							note.alpha *= 0.35;
						}
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');

			}, 5);

			if (SONG.song.toLowerCase() == 'expurgation' && !pussyMode)
				{
					new FlxTimer().start(25, function(tmr:FlxTimer) {
						if (curStep < 2400)
						{
							if (canPause && !paused && health >= 1.5 && !grabbed)
								doGremlin(40,3);
							trace('checka ' + health);
							tmr.reset(25);
						}
					});
				}
		}
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad (obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}
	public function addBehindMom (obj:FlxObject)
		{
			insert(members.indexOf(momGroup), obj);
		}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		// if (defeatDark)
		// 	{
		// 			scoreTxt.text = 'Score: $songScore | Combo Breaks: $songMisses | Accuracy: ';
			
		// 			if (ratingString != '?'){
		// 				scoreTxt.text += ((Math.floor(ratingPercent * 10000) / 100)) + '% | ';
	
		// 				switch(ratingString){
		// 					case ' [SFC]':
		// 						scoreTxt.text += '(MFC) AAAA:';
		// 					case ' [GFC]':
		// 						scoreTxt.text += '(GFC) AAA:';
		// 					case ' [FC]':
		// 						scoreTxt.text += '(FC) AA:';
		// 					default:
		// 						scoreTxt.text += '(SDCB) A:';
		// 				}
		// 			}
		// 			else{
		// 				scoreTxt.text +='0% | N/A';
		// 			}
		// 	}
		// else
		// 	{
				scoreTxt.text = 'Score: ' + songScore 
				+ ' | Misses: ' + songMisses; 
				if (missLimited && curStage == 'defeat') scoreTxt.text += ' / $missLimitCount';
				scoreTxt.text += ' | Rating: ' + ratingName
				+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');
			// }

		if(ClientPrefs.scoreZoom && !miss && !cpuControlled)
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
		callOnLuas('onUpdateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var grabbed = false;

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		barSongLength = songLength;
		if(SONG.song.toLowerCase()=='too slow dside'){
			barSongLength = 35000;
		}
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		switch(curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});
			case 'void1':
				if (ClientPrefs.framerate > 60) {
					add(trintiywarning);
					trintiywarning.cameras = [camOther];
					FlxTween.tween(trintiywarning, {alpha: 1}, 1, {ease: FlxEase.cubeOut});
					new FlxTimer().start(10, function(dstatictimer:FlxTimer)
						{
							FlxTween.tween(trintiywarning, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
						});
				}
		}

		if (drunkGame)
			weee = true;

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}
		
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		
		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		if (fadeOut){
			add(fadeOutBlack);
			add(fadeOutBlack2);
		}

		if (fadeIn){
			add(fadeInBlack);
			add(fadeInBlack2);
		}

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if (songNotes[1] > -1)
				{ // Real notes
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % Note.ammo[mania]);

					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] > (Note.ammo[mania] - 1))
					{
						gottaHitNote = !section.mustHitSection;
					}

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var noteStep = Conductor.getStep(daStrumTime);

					if (songNotes[3] == null || songNotes[3] == '' || songNotes[3].length == 0){
						switch(SONG.song.toLowerCase()){
							case 'endless':
								if(noteStep>=900){
									songNotes[3] = 'Majin Note';
								}
							case 'endless old':
								if(noteStep>=924){
									songNotes[3] = 'Majin Note';
								}
							// case 'you-cant-run':
							// 	if(noteStep > 528 && noteStep < 784){
							// 		songNotes[3] = 'Pixel Note';
							// 	}
						}

					}

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.row = Conductor.secsToRow(daStrumTime);
					if(noteRows[gottaHitNote?0:1][swagNote.row]==null)
						noteRows[gottaHitNote?0:1][swagNote.row]=[];
					noteRows[gottaHitNote ? 0 : 1][swagNote.row].push(swagNote);

					swagNote.mustPress = gottaHitNote;
					swagNote.sustainLength = songNotes[2];
					swagNote.gfNote = (section.gfSection && (songNotes[1]<Note.ammo[mania]));
					swagNote.noteType = songNotes[3];
					if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
					// OPPONENT/BF SEPARATE SKINS
					if (SONG.player2 == "fatal-sonic" && !gottaHitNote)
						swagNote.texture = "FATALNOTE_assets";
					// if (SONG.player1 == "bf-fatal" && gottaHitNote)
					// 	swagNote.texture = "NOTE_assets";

					swagNote.scrollFactor.set();

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					var floorSus:Int = Math.floor(susLength);

					if(floorSus > 0) {
						for (susNote in 0...floorSus+1)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
							sustainNote.mustPress = gottaHitNote;
							sustainNote.gfNote = (section.gfSection && (songNotes[1]<Note.ammo[mania]));
							sustainNote.noteType = swagNote.noteType;
							sustainNote.scrollFactor.set();
							// OPPONENT/BF SEPARATE SKINS
							if (SONG.player2 == "fatal-sonic" && !gottaHitNote)
								sustainNote.texture = "FATALNOTE_assets";
							// if (SONG.player2 == "bf-fatal" && gottaHitNote)
							// 	sustainNote.texture = "NOTE_assets";
							unspawnNotes.push(sustainNote);

							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
							else if(ClientPrefs.middleScroll)
							{
								sustainNote.x += 310;
								if(daNoteData > 1) //Up and Right
								{
									sustainNote.x += FlxG.width / 2 + 25;
								}
							}
						}
					}

					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else if(ClientPrefs.middleScroll)
					{
						swagNote.x += 310;
						if(daNoteData > 1) //Up and Right
						{
							swagNote.x += FlxG.width / 2 + 25;
						}
					}

					if(!noteTypeMap.exists(swagNote.noteType)) {
						noteTypeMap.set(swagNote.noteType, true);
					}
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	//Selever Crossfade
	var flxTrlBf:FlxTrail;
	var flxTrlDad:FlxTrail;
	var bfTrailVsb:Bool = false;
	var dadTrailVsb:Bool = false;
	var bfTrailReq:Bool = false;
	var dadTrailReq:Bool = false;

	//reset: 0: none, 1:bf, 2:dad, 3:both
	function characterTrailSetup(reset:Int = 0) {
		if (flxTrlBf != null && (reset == 1 || reset == 3)) {
			remove(flxTrlBf);
			flxTrlBf.destroy();
			flxTrlBf = null;
			//trace('BF Trail reset');
		}
		if (flxTrlDad != null && (reset == 2 || reset == 3)) {
			remove(flxTrlDad);
			flxTrlDad.destroy();
			flxTrlDad = null;
			//trace('Dad Trail reset');
		}
		//trace('trailVsb: ' + bfTrailVsb + ', '+ dadTrailVsb);
		/*var bfTrail:Bool = false, dadTrail:Bool = false;
		for (event in eventNotes) {
			var arg1:String = event[2];
			if (event[1] == 'Toggle Ghost Trail') {
				var split = arg1.split(',');
				if (!bfTrail && split.contains('bf')) {
					bfTrail = true;
				} if (!dadTrail && split.contains('dad')) {
					dadTrail = true;
				}
				if (bfTrail && dadTrail) break;
			}
		}*/
		//trace('trailRequired: ' + bfTrailReq + ', '+ dadTrailReq);
		if (dadTrailReq && flxTrlDad == null) {
			var trail = new FlxTrail(dad, null, 4, 12, 0.3, 0.069);
			trail.framesEnabled = true;
			trail.color = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);//0xaa0044;
			trail.visible = dadTrailVsb;
			insert(members.indexOf(dadGroup) - 1, trail);
			dad.adjustForTrail();
			flxTrlDad = trail;
		} if (bfTrailReq && flxTrlBf == null) {
			var trail = new FlxTrail(boyfriend, null, 4, 12, 0.3, 0.069);
			trail.framesEnabled = true;
			trail.color = FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]);
			trail.visible = bfTrailVsb;
			insert(members.indexOf(boyfriendGroup) - 1, trail);
			boyfriend.adjustForTrail();
			flxTrlBf = trail;
		}
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'sonicspook':
				CoolUtil.precacheSound('jumpscare');
				CoolUtil.precacheSound('datOneSound');
				var daJumpscare:FlxSprite = new FlxSprite();
				daJumpscare.screenCenter();
				daJumpscare.frames = Paths.getSparrowAtlas('Exe/sonicJUMPSCARE');
				daJumpscare.alpha = 0.0001;
				add(daJumpscare);
				remove(daJumpscare);
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'mom' | 'opponent2' | '2':
						charType = 3;
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Dadbattle Spotlight':
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;

				dadbattleSmokes.alpha = 0.7;
				dadbattleSmokes.blend = ADD;
				dadbattleSmokes.visible = false;
				add(dadbattleLight);
				add(dadbattleSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				dadbattleSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				dadbattleSmokes.add(smoke);


			case 'Philly Glow':
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);


				phillyGlowGradient = new PhillyGlow.PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if(!ClientPrefs.flashing) phillyGlowGradient.intendedAlpha = 0.7;

				precacheList.set('philly/particle', 'image'); //precache particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlow.PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...Note.ammo[mania])
		{
			var twnDuration:Float = 4 / mania;
			var twnStart:Float = 0.5 + ((0.8 / mania) * i);
			// FlxG.log.add(i);
			if (SONG.player2 == "fatal-sonic" && player == 0)
				PlayState.SONG.arrowSkin = 'FATALNOTE_assets';
			if (SONG.player1 == "bf-fatal" && player == 1)
				PlayState.SONG.arrowSkin = 'NOTE_assets';
			if(SONG.song.toLowerCase()=='endless' && curStep==901||curSection == 58 && curSong.toLowerCase() == 'endless old')
				PlayState.SONG.arrowSkin='MAJINNOTE_assets';
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.opponentStrums || curStage == 'defeat' || curStage == 'defeatold') targetAlpha = 0;
				else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween && mania > 1 && curSong.toLowerCase() != 'fatality')
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, twnDuration, {ease: FlxEase.circOut, startDelay: twnStart});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
				if (curSong.toLowerCase() == 'lost cause' && !ClientPrefs.middleScroll)
					babyArrow.x -= 620;
				if (curSong.toLowerCase() == 'fatality' && !ClientPrefs.middleScroll)
					babyArrow.x -= 65;
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					var separator:Int = Note.separator[mania];

					babyArrow.x += 310;
					if(i > separator) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
				if (curSong.toLowerCase() == 'lost cause' && !ClientPrefs.middleScroll)
					babyArrow.x += 1240; //620
				if (curSong.toLowerCase() == 'fatality' && !ClientPrefs.middleScroll)
					babyArrow.x -= 55;
				if (curStage == 'defeat' || curStage == 'defeatold' || curSong.toLowerCase() == 'black sun')
					babyArrow.x -= 9999; //620
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();

			if (ClientPrefs.showKeybindsOnStart && player == 1) {
				for (j in 0...keysArray[mania][i].length) {
					var daKeyTxt:FlxText = new FlxText(babyArrow.x, babyArrow.y - 10, 0, InputFormatter.getKeyName(keysArray[mania][i][j]), 32);
					daKeyTxt.setFormat(Paths.font(gameFont), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					daKeyTxt.borderSize = 1.25;
					daKeyTxt.alpha = 0;
					daKeyTxt.size = 32 - mania; //essentially if i ever add 0k!?!?
					daKeyTxt.x = babyArrow.x+(babyArrow.width / 2);
					daKeyTxt.x -= daKeyTxt.width / 2;
					add(daKeyTxt);
					daKeyTxt.cameras = [camNotes];
					var textY:Float = (j == 0 ? babyArrow.y - 32 : ((babyArrow.y - 32) + babyArrow.height) - daKeyTxt.height);
					daKeyTxt.y = textY;

					if (mania > 1 && !skipArrowStartTween) {
						FlxTween.tween(daKeyTxt, {y: textY + 32, alpha: 1}, twnDuration, {ease: FlxEase.circOut, startDelay: twnStart});
					} else {
						daKeyTxt.y += 16;
						daKeyTxt.alpha = 1;
					}
					new FlxTimer().start(Conductor.crochet * 0.001 * 12, function(_) {
						FlxTween.tween(daKeyTxt, {y: daKeyTxt.y + 32, alpha: 0}, twnDuration, {ease: FlxEase.circIn, startDelay: twnStart, onComplete:
						function(t) {
							remove(daKeyTxt);
						}});
					});
				}
			}
		}
	}

	function updateNote(note:Note)
	{
		var tMania:Int = mania + 1;
		var noteData:Int = note.noteData;

		note.scale.set(1, 1);
		note.updateHitbox();

		/*
		if (!isPixelStage) {
			note.setGraphicSize(Std.int(note.width * Note.noteScales[mania]));
			note.updateHitbox();
		} else {
			note.setGraphicSize(Std.int(note.width * daPixelZoom * (Note.noteScales[mania] + 0.3)));
			note.updateHitbox();
		}
		*/

		// Like reloadNote()

		var lastScaleY:Float = note.scale.y;
		if (isPixelStage) {
			if (note.isSustainNote) {note.originalHeightForCalcs = note.height;}

			note.setGraphicSize(Std.int(note.width * daPixelZoom * Note.pixelScales[mania]));
		} else {
			// Like loadNoteAnims()

			note.setGraphicSize(Std.int(note.width * Note.scales[mania]));
			note.updateHitbox();
		}

		//if (note.isSustainNote) {note.scale.y = lastScaleY;}
		note.updateHitbox();

		// Like new()

		var prevNote:Note = note.prevNote;
		
		if (note.isSustainNote && prevNote != null) {
			
			note.offsetX += note.width / 2;

			note.animation.play(Note.keysShit.get(mania).get('letters')[noteData] + ' tail');

			note.updateHitbox();

			note.offsetX -= note.width / 2;

			if (note != null && prevNote != null && prevNote.isSustainNote && prevNote.animation != null) { // haxe flixel
				prevNote.animation.play(Note.keysShit.get(mania).get('letters')[noteData % tMania] + ' hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				prevNote.scale.y *= songSpeed;

				if(isPixelStage) {
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / note.height);
				}

				prevNote.updateHitbox();
				//trace(prevNote.scale.y);
			}
			
			if (isPixelStage){
				prevNote.scale.y *= daPixelZoom * (Note.pixelScales[mania]); //Fuck urself
				prevNote.updateHitbox();
			}
		} else if (!note.isSustainNote && noteData > - 1 && noteData < tMania) {
			if (note.changeAnim) {
				if (true && flyState == '')
					{
						// doCamMove(daNote.noteData, false);
					}

				var animToPlay:String = '';

				animToPlay = Note.keysShit.get(mania).get('letters')[noteData % tMania];
				
				note.animation.play(animToPlay);
			}
		}

		// Like set_noteType()

		if (note.changeColSwap) {
			var hsvNumThing = Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData % tMania]);
			var colSwap = note.colorSwap;

			colSwap.hue = ClientPrefs.arrowHSV[hsvNumThing][0] / 360;
			colSwap.saturation = ClientPrefs.arrowHSV[hsvNumThing][1] / 100;
			colSwap.brightness = ClientPrefs.arrowHSV[hsvNumThing][2] / 100;
		}
	}

	public function changeMania(newValue:Int, skipStrumFadeOut:Bool = false)
	{
		//funny dissapear transitions
		//while new strums appear
		var daOldMania = mania;
				
		mania = newValue;
		if (!skipStrumFadeOut) {
			for (i in 0...strumLineNotes.members.length) {
				var oldStrum:FlxSprite = strumLineNotes.members[i].clone();
				oldStrum.x = strumLineNotes.members[i].x;
				oldStrum.y = strumLineNotes.members[i].y;
				oldStrum.alpha = strumLineNotes.members[i].alpha;
				oldStrum.scrollFactor.set();
				oldStrum.cameras = [camNotes];
				oldStrum.setGraphicSize(Std.int(oldStrum.width * Note.scales[daOldMania]));
				oldStrum.updateHitbox();
				add(oldStrum);
	
				FlxTween.tween(oldStrum, {alpha: 0}, 0.3, {onComplete: function(_) {
					remove(oldStrum);
				}});
			}
		}

		playerStrums.clear();
		opponentStrums.clear();
		strumLineNotes.clear();
		setOnLuas('mania', mania);

		notes.forEachAlive(function(note:Note) {updateNote(note);});

		for (noteI in 0...unspawnNotes.length) {
			var note:Note = unspawnNotes[noteI];

			updateNote(note);
		}

		callOnLuas('onChangeMania', [mania, daOldMania]);

		generateStaticArrows(0);
		generateStaticArrows(1);
		updateLuaDefaultPos();
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{

			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad, mom];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (tranceSound != null) tranceSound.play();

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad, mom];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	function winPendulum()
		{
			trance -= 0.075;
			var shadow:FlxSprite = pendulum.clone();
			shadow.setGraphicSize(Std.int(pendulum.width), Std.int(pendulum.height));
			shadow.updateHitbox();
			shadow.setPosition(pendulum.x, pendulum.y);
			shadow.cameras = pendulum.cameras;
			shadow.origin.set(pendulum.origin.x, pendulum.origin.y);
			shadow.angle = pendulum.angle;
			shadow.antialiasing = true;
			pendulumShadow.add(shadow);
			shadow.alpha = 0.5;
			FlxTween.tween(shadow, {alpha: 0}, Conductor.stepCrochet / 1000, {
				ease: FlxEase.linear,
				startDelay: Conductor.stepCrochet / 1000,
				onComplete: function(twn:FlxTween)
				{
					pendulumShadow.remove(shadow);
				}
			});
	
			var hypnoRating:FlxSprite = new FlxSprite(530, 370); //idk
			hypnoRating.frames = Paths.getSparrowAtlas('hypno/ui/Extras');
			hypnoRating.animation.addByPrefix('correct', 'Checkmark', 24, false);
			hypnoRating.animation.play('correct');
			hypnoRating.updateHitbox();
			hypnoRating.antialiasing = true;
			add(hypnoRating);
			hypnoRating.cameras = [camHUD];
			hypnoRating.alpha = 1.0;
			hypnoRating.animation.finishCallback = function(name:String)
				{
					hypnoRating.destroy();
				}
		}
	
		function losePendulum(forced:Bool = false) {
			if (!ClientPrefs.getGameplaySetting('botplay', false))
			{
				trance += 0.115;
	
				var hypnoRating:FlxSprite = new FlxSprite(500, 350); //idk
				hypnoRating.frames = Paths.getSparrowAtlas('hypno/ui/Extras');
				hypnoRating.animation.addByPrefix('incorrect', 'X finished', 24, false);
				hypnoRating.animation.play('incorrect');
				hypnoRating.updateHitbox();
				hypnoRating.antialiasing = true;
				add(hypnoRating);
				hypnoRating.cameras = [camHUD];
				hypnoRating.alpha = 1.0;
				hypnoRating.animation.finishCallback = function(name:String)
					{
						hypnoRating.destroy();
					}
			}
		}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + storyDifficultyText, iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function windowGoBack()
		{
			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				var xLerp:Float = FlxMath.lerp(windowX, Lib.application.window.x, 0.95);
				var yLerp:Float = FlxMath.lerp(windowY, Lib.application.window.y, 0.95);
				Lib.application.window.move(Std.int(xLerp), Std.int(yLerp));
			}, 20);
		}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	var spookyText:FlxText;
	var spookyRendered:Bool = false;
	var spookySteps:Int = 0;

	var attachedText:AttachedText;
	var maxPendulumAngle:Float = 0;
	var alreadyHit:Bool = false;
	var canHitPendulum:Bool = false;
	var tranceInterval:Int = 0;
	var beatInterval:Float = 2; // every how many beats the pendulum must be hit 

	override public function update(elapsed:Float)
	{
		managePopups();

		frozenBF.x = boyfriend.x - 100;
		frozenBF.y = boyfriend.y - 100;
		
		if (canDodge && FlxG.keys.justPressed.SPACE)
			{
				dodging = true;
				boyfriend.playAnim('dodge', true);
				boyfriend.specialAnim = true;
	
				boyfriend.animation.finishCallback = function(a:String)
				{
					if(a == 'dodge'){
						new FlxTimer().start(0.5, function(a:FlxTimer)
						{
							dodging = false;
							canDodge = false;
							boyfriend.specialAnim = false;
							trace('didnt die?');
						});
					}
				}
			}
		switch (curSong.toLowerCase())
		{
			case 'black sun':
				{
					var ccap;

					ccap = combo;
					if (combo > 40)
						ccap = 40;

					heatlhDrop = 0.0000001; // this is the default drain, imma just add a 0 to it :troll:.
					health -= heatlhDrop * (500 / ((ccap + 1) / 8) * ((songMisses +
						1) / 1.9)); // alright so this is the code for the healthdrain, also i did + 1 cus i you were to multiply with 0.... yea
					vgblack.alpha = 1 - (health / 2);
					tentas.alpha = 1 - (health / 2);
				}
		}

		if (dad.curCharacter == 'fleetwaylaser' && dad.animation.curAnim.curFrame == 15 && !dodging)
			{
				health = 0;
			}

		floaty += 0.03;
		floaty2 += 0.01;

		if (isFixedAspectRatio)
			FlxG.fullscreen = false;

		if (sickOnly) {
			if (shits > 0)
				health = 0;
			else if (bads > 0)
				health = 0;
			else if (goods > 0)
				health = 0;
		}
		
		flashSprite.alpha = FlxMath.lerp(flashSprite.alpha, 0, CoolUtil.boundTo(elapsed * 9, 0, 1));

		if (curStage == 'plantroom' || curStage == 'pretender')
			{
				cloud1.x = FlxMath.lerp(cloud1.x, cloud1.x - 1, CoolUtil.boundTo(elapsed * 9, 0, 1));
				cloud2.x = FlxMath.lerp(cloud2.x, cloud2.x - 3, CoolUtil.boundTo(elapsed * 9, 0, 1));
				cloud3.x = FlxMath.lerp(cloud3.x, cloud3.x - 2, CoolUtil.boundTo(elapsed * 9, 0, 1));
				cloud4.x = FlxMath.lerp(cloud4.x, cloud4.x - 0.1, CoolUtil.boundTo(elapsed * 9, 0, 1));
				cloudbig.x = FlxMath.lerp(cloudbig.x, cloudbig.x - 0.5, CoolUtil.boundTo(elapsed * 9, 0, 1));
			}

		if (curStage == 'warehouse'){
			leftblades.x = (213.05 + bladeDistance) - (60 * health);
			rightblades.x = (827.75 - bladeDistance) + (60 * health);
		}

		if (curSong.toLowerCase() == 'recursed'||curSong.toLowerCase() == 'sunshine')
			moveCameraSection();
		if (curSong.toLowerCase() == 'chaos' && curStep > 8)
			moveCameraSection();

		elapsedtime += elapsed;

		var toy = -100 + -Math.sin((curStep / 9.5) * 2) * 30 * 5;
		var tox = -330 -Math.cos((curStep / 9.5)) * 100;

		if (dad.curCharacter == 'recurser')
			{
				toy = 100 + -Math.sin((elapsedtime) * 2) * 300;
				tox = -400 - Math.cos((elapsedtime)) * 200;
	
				dad.x += (tox - dad.x);
				dad.y += (toy - dad.y);
			}
		if (SONG.song.toLowerCase() == 'recursed')
			{
				var scrollSpeed = 150;
				charBackdrop.x -= scrollSpeed * elapsed;
				charBackdrop.y += scrollSpeed * elapsed;
	
				darkSky.x += 40 * scrollSpeed * elapsed;
				if (darkSky.x >= (darkSkyStartPos * 4) - 1280)
				{
					darkSky.x = resetPos;
				}
				darkSky2.x = darkSky.x - darkSky.width;
				
				var lerpVal = 0.97;
				freeplayBG.alpha = FlxMath.lerp(0, freeplayBG.alpha, lerpVal);
				charBackdrop.alpha = FlxMath.lerp(0, charBackdrop.alpha, lerpVal);
				for (char in alphaCharacters)
				{
					for (letter in char.characters)
					{
						letter.alpha = FlxMath.lerp(0, letter.alpha, lerpVal);
					}
				}
				if (isRecursed)
				{
					timeLeft -= elapsed;
					if (timeLeftText != null)
					{
						timeLeftText.text = FlxStringUtil.formatTime(Math.floor(timeLeft));
					}
	
					camRotateAngle += elapsed * 5 * (rotateCamToRight ? 1 : -1);
	
					FlxG.camera.angle = camRotateAngle;
					camHUD.angle = camRotateAngle;
					camNotes.angle = camRotateAngle;
	
					if (camRotateAngle > 8)
					{
						rotateCamToRight = false;
					}
					else if (camRotateAngle < -8)
					{
						rotateCamToRight = true;
					}
					
					health = FlxMath.lerp(0, 2, timeLeft / timeGiven);
				}
				else
				{
					if (FlxG.camera.angle > 0 || camHUD.angle > 0 || camNotes.angle > 0)
					{
						cancelRecursedCamTween();
					}
				}
			}

		var currentBeat:Float = (Conductor.songPosition / 1000) * (170/ 60);
		if (weee == true && !pussyMode)
		{
			for (i in 0...6) {
				playerStrums.members[i].x = playerStrums.members[i].x;
				playerStrums.members[i].y = playerStrums.members[i].y + 80 * Math.sin((currentBeat + i*4)) * elapsed;
				opponentStrums.members[i].x = opponentStrums.members[i].x;
				opponentStrums.members[i].y = opponentStrums.members[i].y + 80 * Math.sin((currentBeat + i*4)) * elapsed;
			}
			camHUD.angle += 4 * Math.sin(currentBeat * Math.PI) * elapsed;
			camNotes.angle += 4 * Math.sin(currentBeat * Math.PI) * elapsed;
			camOther.angle += 4 * Math.sin(currentBeat * Math.PI) * elapsed;
			FlxG.camera.angle += 4 * Math.sin(currentBeat * Math.PI) * elapsed;
		}
		if (normal == true && !pussyMode)
		{
			for (i in 0...6) {
				playerStrums.members[i].x = playerStrums.members[i].x;
				playerStrums.members[i].y = playerStrums.members[i].y;
				opponentStrums.members[i].x = opponentStrums.members[i].x;
				opponentStrums.members[i].y = opponentStrums.members[i].y;
			}
			camHUD.angle = 0;
			camNotes.angle = 0;
			camOther.angle = 0;
			FlxG.camera.angle = 0;
		}
			

		if (shakeCam)
			{
				FlxG.camera.shake(0.015, 0.015);
			}

		chatTxt.x = usernameTxt.x + (chatUsername.length * 14);

		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/

		switch (flyState)
		{
			case 'hover' | 'hovering':
				flyTarg.y += Math.sin(floaty) * 1.5;
			// moveCameraSection(Std.int(curStep / 16));
			case 'fly' | 'flying':
				flyTarg.y += Math.sin(floaty) * 1.5;
				flyTarg.x += Math.cos(floaty) * 1.5;
				// moveCameraSection(Std.int(curStep / 16));
			case 'sHover' | 'sHovering':
				flyTarg.y += Math.sin(floaty2) * 0.5;
		}
		callOnLuas('onUpdate', [elapsed]);



		if(ClientPrefs.camMovement && !PlayState.isPixelStage) {
			if(camlock) {
				camFollow.x = camlockx;
				camFollow.y = camlocky;
			}
		}

		switch(dad.curCharacter)
		{
			case 'extricky':
				if (exSpikes.animation.frameIndex >= 3 && dad.animation.curAnim.name == 'singUP')
				{
					trace('paused');
					exSpikes.animation.pause();
				}
		}

		if (SONG.song.toLowerCase() == 'fatality' && IsWindowMoving)
			{
				var thisX:Float = Math.sin(Xamount * (Xamount)) * 100;
				var thisY:Float = Math.sin(Yamount * (Yamount)) * 100;
				var yVal = Std.int(windowY + thisY);
				var xVal = Std.int(windowX + thisX);
				Lib.application.window.move(xVal, yVal);
				Yamount = Yamount + 0.0015;
				Xamount = Xamount + 0.00075;
			}

		switch (curStage)
		{
			case 'tank':
				moveTank(elapsed);
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

				if(phillyGlowParticles != null)
				{
					var i:Int = phillyGlowParticles.members.length-1;
					while (i > 0)
					{
						var particle = phillyGlowParticles.members[i];
						if(particle.alpha < 0)
						{
							particle.kill();
							phillyGlowParticles.remove(particle, true);
							particle.destroy();
						}
						--i;
					}
				}
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 170) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
			case 'cargo':
				if(cargoDarken){
					cargoDark.alpha = FlxMath.lerp(cargoDark.alpha, 1, CoolUtil.boundTo(elapsed * 1.4, 0, 1));
					dad.alpha = FlxMath.lerp(dad.alpha, 0.001, CoolUtil.boundTo(elapsed * 1.4, 0, 1));
					mom.alpha = FlxMath.lerp(mom.alpha, 0.001, CoolUtil.boundTo(elapsed * 1.4, 0, 1));
					mainoverlayDK.alpha = FlxMath.lerp(mainoverlayDK.alpha, 0.001, CoolUtil.boundTo(elapsed * 1.4, 0, 1));
					lightoverlayDK.alpha = FlxMath.lerp(lightoverlayDK.alpha, 0.001, CoolUtil.boundTo(elapsed * 1.4, 0, 1));					
				}

				if(showDlowDK){
					cargoAirsip.alpha = FlxMath.lerp(cargoAirsip.alpha, 0.45, CoolUtil.boundTo(elapsed * 0.1, 0, 1));
				}

				if (Conductor.songPosition >= 0 && Conductor.songPosition < 1200 ){
					cargoDarkFG.alpha -= 0.005;
					FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, CoolUtil.boundTo(elapsed * 3, 0, 1));
				}
				if (cargoReadyKill){
					cargoDarkFG.alpha += 0.015;
					FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, CoolUtil.boundTo(elapsed * 3, 0, 1));
				}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);
		missLimitManager();

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}																																

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		if (healthBarFlipped){
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 100, 0, 100, 0) * 0.01) - iconOffset);
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 100, 0, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		}
		else{
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;	
		}
	
		if (health > 2)
			health = 2;

		if (healthBarFlipped){
			if (healthBar.percent < 20)
				iconP2.animation.curAnim.curFrame = 1;
			else
				iconP2.animation.curAnim.curFrame = 0;
	
			if (healthBar.percent > 80)
				iconP1.animation.curAnim.curFrame = 1;
			else
				iconP1.animation.curAnim.curFrame = 0;
		}
		else{
			if (healthBar.percent < 20)
				iconP1.animation.curAnim.curFrame = 1;
			else
				iconP1.animation.curAnim.curFrame = 0;
	
			if (healthBar.percent > 80)
				iconP2.animation.curAnim.curFrame = 1;
			else
				iconP2.animation.curAnim.curFrame = 0;
		}
		switch (dad.curCharacter)
		{
			case 'exe':
				if (healthBar.percent < 20)
				{
					iconP2.animation.curAnim.curFrame = 1;
					iconP1.animation.curAnim.curFrame = 1;
				}
				else
				{
					iconP1.animation.curAnim.curFrame = 0;
					iconP2.animation.curAnim.curFrame = 0;
				}
		}

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			if (tranceSound != null) tranceSound.stop();
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}
		
		if (startedCountdown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / barSongLength);

					var songCalc:Float = (barSongLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name'){
						if(SONG.song.toLowerCase()=='endless' && curStep>=898){
							songPercent=0;
							timeTxt.text = 'Infinity';
						}else
							timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
					}

					var curMS:Float = Math.floor(curTime);
					var curSex:Int = Math.floor(curMS / 1000);
					if (curSex < 0)
						curSex = 0;

		    		var curMins = Math.floor(curSex / 60);
					curMS%=1000;
		    		curSex%=60;

					minNumber.number = curMins;

					var sepSex = Std.string(curSex).split("");
					if(curSex<10){
						secondNumberA.number = 0;
						secondNumberB.number = curSex;
					}else{
						secondNumberA.number = Std.parseInt(sepSex[0]);
						secondNumberB.number = Std.parseInt(sepSex[1]);
					}
					if(millisecondNumberA!=null && millisecondNumberB!=null){
						curMS = Math.round(curMS/10);
						if(curMS<10){
							millisecondNumberA.number = 0;
							millisecondNumberB.number = Math.floor(curMS);
						}else{
							var sepMSex = Std.string(curMS).split("");
							millisecondNumberA.number = Std.parseInt(sepMSex[0]);
							millisecondNumberB.number = Std.parseInt(sepMSex[1]);
						}
					}
				}
			}
			// penduluuum
			if (pendulum != null && tranceActive) {
				var convertedTime:Float = ((Conductor.songPosition / (Conductor.crochet * beatInterval)) * Math.PI);
				pendulum.angle = (Math.sin(convertedTime) * 32) + pendulumOffset;
				// pendulum.screenCenter();
				// /*
				var pendulumTimeframe = Math.floor(((convertedTime / Math.PI) - Math.floor(convertedTime / Math.PI)) * 1000) / 1000;
				var reach:Float = 0.2;
				if (!tranceNotActiveYet) {
					if (pendulumTimeframe < reach || pendulumTimeframe > (1 - reach)) {
						if (!alreadyHit)
							canHitPendulum = true;
					} 
					else
					{
						alreadyHit = false;
						if (canHitPendulum) {
							if (tranceInterval % 2 == 0)
								losePendulum(true);
							tranceInterval++;
							canHitPendulum = false;
						}
					}
						

					// /*
					if (FlxG.keys.justPressed.SPACE || (ClientPrefs.getGameplaySetting('botplay', false) && canHitPendulum && !alreadyHit))
					{
						if (canHitPendulum)
						{
							canHitPendulum = false;
							alreadyHit = true;
							winPendulum();
						}
						else
							losePendulum(true);
					}
				}
				// fuck you let me fix this with delta
				trance -= (((Conductor.bpm / 200) / 1000) * (elapsed / (1 / 90)));
				// 200 is based on left unchecked bpm & health "restore" decreases based on the bpm 
				// of the song so its not as easy on lower bpm songs

				tranceThing.alpha = trance / 2;
				if (trance > 1)
					tranceSound.volume = (trance - 1) / 2;
				else
					tranceSound.volume = 0;

				if (trance > 2) {
					trance = 2;
					if (tranceCanKill)
						health -= 9999999999999999999;
				}
				if (trance < -0.25)
					trance = -0.25;

				if (trance >= 0.8) {
					if (trance >= 1.6)
						boyfriend.idleSuffix = '-alt2';
					else
						boyfriend.idleSuffix = '-alt';
				}
				else
					boyfriend.idleSuffix = '';
			}	

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + extraZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camNotes.zoom = FlxMath.lerp(1, camNotes.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (chatTxt.overlaps(usernameTxt))
			{
				chatTxt.x += 1;
			}

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if(SONG.song.toLowerCase() == 'too slow dside' && !pussyMode){
			opponentStrums.forEachAlive( function(strum:StrumNote){
				if(freezeCounter>0){
					if(strum.alphaM>.5)
						strum.alphaM-=elapsed*5;
					if(strum.alphaM<=.5)strum.alphaM=.5;
				}else{
					if(strum.alphaM<1)
						strum.alphaM+=elapsed*5;
					if(strum.alphaM>=1)strum.alphaM=1;
				}
			});

			playerStrums.forEachAlive( function(strum:StrumNote){
				if(freezeCounter>0){
					if(strum.alphaM>.5)
						strum.alphaM-=elapsed*5;
					if(strum.alphaM<=.5)strum.alphaM=.5;
				}else{
					if(strum.alphaM<1)
						strum.alphaM+=elapsed*5;
					if(strum.alphaM>=1)strum.alphaM=1;
				}
			});
		}
		
		if (spookyRendered) // move shit around all spooky like
			{
				spookyText.angle = FlxG.random.int(-5,5); // change its angle between -5 and 5 so it starts shaking violently.
				//tstatic.x = tstatic.x + FlxG.random.int(-2,2); // move it back and fourth to repersent shaking.
				if (tstatic.alpha != 0)
					tstatic.alpha = FlxG.random.float(0.1,0.5); // change le alpha too :)
			}

		if (generatedMusic && !inCutscene && inScene == false)
		{
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}

			if(startedCountdown)
			{
				var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
				notes.forEachAlive(function(daNote:Note)
				{
					var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
					if(!daNote.mustPress) strumGroup = opponentStrums;

					var strumX:Float = strumGroup.members[daNote.noteData].x;
					var strumY:Float = strumGroup.members[daNote.noteData].y;
					var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
					var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
					var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
					var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

					strumX += daNote.offsetX;
					strumY += daNote.offsetY;
					strumAngle += daNote.offsetAngle;
					strumAlpha *= daNote.multAlpha;

					if (strumScroll) //Downscroll
					{
						//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}
					else //Upscroll
					{
						//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}

					var angleDir = strumDirection * Math.PI / 180;
					if (daNote.copyAngle)
						daNote.angle = strumDirection - 90 + strumAngle;

					if(daNote.copyAlpha)
						daNote.alpha = strumAlpha;

					if(daNote.copyX)
						daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

					if(daNote.copyY)
					{
						daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

						//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
						if(strumScroll && daNote.isSustainNote)
						{
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
								} else {
									daNote.y -= 19;
								}
							}
							daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1) * Note.scales[mania];
						}
					}

					if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
					{
						opponentNoteHit(daNote);
					}

					if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
						if(daNote.isSustainNote) {
							if(daNote.canBeHit) {
								goodNoteHit(daNote);
							}
						} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
							goodNoteHit(daNote);
						}
					}

					var center:Float = strumY + Note.swagWidth / 2;
					if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
						(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						if (strumScroll)
						{
							if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}

					// Kill extremely late notes and cause misses
					if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
					{
						if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
							noteMiss(daNote);
							updateSonicMisses();
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
			else
			{
				notes.forEachAlive(function(daNote:Note)
				{
					daNote.canBeHit = false;
					daNote.wasGoodHit = false;
				});
			}
		}
		checkEventNote();
		
		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}



	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;
		if (tranceSound != null) tranceSound.pause();

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		//}

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song + storyDifficultyText, iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		if (debugMode == true) {
			persistentUpdate = false;
			paused = true;
			if (tranceSound != null) tranceSound.stop();
			cancelMusicFadeTween();
			MusicBeatState.switchState(new ChartingState());
			chartingMode = true;
	
			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}
		else
			health -= 9999999;
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss || skipHealthCheck && sickOnly) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				if (tranceSound != null)
					tranceSound.stop();

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				if(curStage == 'defeatold')
					{
						KillNotes();
						vocals.volume = 0;
						vocals.pause();
		
						if(FlxG.random.bool(5)){
							GameOverSubstate.characterName = 'bf-defeat-dead-balls-old';
							GameOverSubstate.deathSoundName = 'fnf_loss_sfx-noballs';
						}
		
						camNotes.visible = false;
						camHUD.visible = false;
						canPause = false;
						camZooming = false;
						paused = true;
					
						camFollow.set(dad.getMidpoint().x - 400, dad.getMidpoint().y - 170);	
						dad.visible = false;
								
						var fakedad:FlxSprite = new FlxSprite();
						fakedad.frames = Paths.getSparrowAtlas('characters/blackold');
						fakedad.animation.addByPrefix('death', 'BLACK DEATH', 24, false);
						fakedad.setPosition(dad.x - 238, dad.y - 152);
						add(fakedad);
						//fakedad.setGraphicSize(Std.int(fakedad.width * 2.35));
						fakedad.animation.play('death');
						//defaultCamZoom = 0.9;
						fakedad.animation.finishCallback = function(lol:String)
							{
								remove(fakedad);
							}	
					
						camFollow.y = dad.getMidpoint().y - 200;
						camFollow.x = dad.getMidpoint().x - 450;
					
						FlxG.sound.play(Paths.sound('black-death'));
								
						FlxTween.tween(FlxG.camera, {zoom: 1.2}, 1.5, {ease: FlxEase.circOut});
					
						new FlxTimer().start(0.6, function(tmr:FlxTimer)
						{
							openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));
						});
					}
				else if(curStage == 'defeat')
					{
						KillNotes();
						vocals.volume = 0;
						vocals.pause();
			
						if(FlxG.random.bool(10)){
							GameOverSubstate.characterName = 'bf-defeat-dead-balls';
							GameOverSubstate.deathSoundName = 'defeat_kill_ballz_sfx';
						}
									
						canPause = false;
						camZooming = false;
						paused = true;
			
						FlxG.sound.music.volume = 0;
									
						triggerEventNote('Change Character', '1', 'blackKill');
						triggerEventNote('Camera Follow Pos', '550', '500');
			
						FlxG.sound.play(Paths.sound('edefeat'), 1);
			
						FlxTween.tween(camHUD, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});
						FlxTween.tween(camNotes, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});
			
						iconP1.visible = false;
						iconP2.visible = false;
			
						defaultCamZoom = 0.65;
						dad.setPosition(-15, 163);
						dad.playAnim('kill1');
						dad.specialAnim = true;
			
						new FlxTimer().start(1.8, function(tmr:FlxTimer)
						{
							dad.playAnim('kill2');
							dad.specialAnim = true;
			
							defaultCamZoom = 0.5;
							triggerEventNote('Camera Follow Pos', '750', '450');
						});
						new FlxTimer().start(2.7, function(tmr:FlxTimer)
						{
							dad.playAnim('kill3');
							dad.specialAnim = true;
						});
						new FlxTimer().start(3.4, function(tmr:FlxTimer)
						{
							openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));
						});
					}
				else if (curStage == 'void')
					openSubState(new DeliLoseSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				else
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				if (SONG.song.toLowerCase() == 'recursed')
					{
						cancelRecursedCamTween();
					}

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + storyDifficultyText, iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	function doSimpleJump()
	{
		trace('SIMPLE JUMPSCARE');

		var simplejump:FlxSprite;
		simplejump = new FlxSprite(0, 0).loadGraphic(Paths.image("Exe/simplejump"));
		simplejump.setGraphicSize(FlxG.width, FlxG.height);
		simplejump.screenCenter();
		simplejump.cameras = [camOther];
		FlxG.camera.shake(0.0025, 0.50);

		add(simplejump);

		FlxG.sound.play(Paths.sound('sppok'), 1);

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			trace('ended simple jump');
			remove(simplejump);
		});

		// now for static

		var daStatic:FlxSprite;
		daStatic = new FlxSprite(0, 0).loadGraphic(Paths.image("Exe/daSTAT"));
		daStatic.frames = Paths.getSparrowAtlas('Exe/daSTAT');
		daStatic.setGraphicSize(FlxG.width, FlxG.height);
		daStatic.screenCenter();
		daStatic.cameras = [camOther];
		daStatic.animation.addByPrefix('static', 'staticFLASH', 24, false);
		add(daStatic);

		FlxG.sound.play(Paths.sound('staticBUZZ'));

		if (daStatic.alpha != 0)
			daStatic.alpha = FlxG.random.float(0.1, 0.5);

		daStatic.animation.play('static');

		daStatic.animation.finishCallback = function(pog:String)
		{
			trace('ended static');
			remove(daStatic);
		}
	}

	function doStaticSign(lestatic:Int = 0, leopa:Bool = true)
	{
		trace('static MOMENT HAHAHAH ' + lestatic);

		var daStatic:FlxSprite;
		daStatic = new FlxSprite(0, 0).loadGraphic(Paths.image("Exe/daSTAT"));
		daStatic.frames = Paths.getSparrowAtlas('Exe/daSTAT');
		daStatic.setGraphicSize(FlxG.width, FlxG.height);
		daStatic.screenCenter();
		daStatic.cameras = [camOther];

		switch (lestatic)
		{
			case 0:
				daStatic.animation.addByPrefix('static', 'staticFLASH', 24, false);
		}
		add(daStatic);

		FlxG.sound.play(Paths.sound('staticBUZZ'));

		if (leopa)
		{
			if (daStatic.alpha != 0)
				daStatic.alpha = FlxG.random.float(0.1, 0.5);
		}
		else
			daStatic.alpha = 1;

		daStatic.animation.play('static');

		daStatic.animation.finishCallback = function(pog:String)
		{
			trace('ended static');
			remove(daStatic);
		}
	}


	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	var lyrics:FlxText;

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Dadbattle Spotlight':
				var val:Null<Int> = Std.parseInt(value1);
				if(val == null) val = 0;

				switch(Std.parseInt(value1))
				{
					case 1, 2, 3: //enable and target dad
						if(val == 1) //enable
						{
							dadbattleBlack.visible = true;
							dadbattleLight.visible = true;
							dadbattleSmokes.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if(val > 2) who = boyfriend;
						//2 only targets dad
						dadbattleLight.alpha = 0;
						new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							dadbattleLight.alpha = 0.375;
						});
						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);

					default:
						dadbattleBlack.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(dadbattleSmokes, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
						{
							dadbattleSmokes.visible = false;
						}});
				}

			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Lyrics':
				if(lyrics!=null){
					remove(lyrics);
					lyrics.destroy();
				}
				if(value2.trim()=='')value2='#FFFFFF';
				if(value1.trim()!=''){
			 		lyrics = new FlxText(0, 570, 0, value1, 32);
					lyrics.cameras = [camOther];
					lyrics.setFormat(Paths.font("PressStart2P.ttf"), 24, FlxColor.fromString(value2), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					lyrics.screenCenter(X);
					lyrics.updateHitbox();
					add(lyrics);
				}

			case 'Philly Glow':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				var doFlash:Void->Void = function() {
					var color:FlxColor = FlxColor.WHITE;
					if(!ClientPrefs.flashing) color.alphaFloat = 0.5;

					FlxG.camera.flash(color, 0.15, null, true);
				};

				var chars:Array<Character> = [boyfriend, gf, dad];
				switch(lightId)
				{
					case 0:
						if(phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = false;
							phillyWindowEvent.visible = false;
							phillyGlowGradient.visible = false;
							phillyGlowParticles.visible = false;
							curLightEvent = -1;

							for (who in chars)
							{
								who.color = FlxColor.WHITE;
							}
							phillyStreet.color = FlxColor.WHITE;
						}

					case 1: //turn on
						curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
						var color:FlxColor = phillyLightsColors[curLightEvent];

						if(!phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							phillyWindowEvent.visible = true;
							phillyGlowGradient.visible = true;
							phillyGlowParticles.visible = true;
						}
						else if(ClientPrefs.flashing)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.25;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}

						var charColor:FlxColor = color;
						if(!ClientPrefs.flashing) charColor.saturation *= 0.5;
						else charColor.saturation *= 0.75;

						for (who in chars)
						{
							who.color = charColor;
						}
						phillyGlowParticles.forEachAlive(function(particle:PhillyGlow.PhillyGlowParticle)
						{
							particle.color = color;
						});
						phillyGlowGradient.color = color;
						phillyWindowEvent.color = color;

						color.brightness *= 0.5;
						phillyStreet.color = color;

					case 2: // spawn particles
						if(!ClientPrefs.lowQuality)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];
							for (j in 0...3)
							{
								for (i in 0...particlesNum)
								{
									var particle:PhillyGlow.PhillyGlowParticle = new PhillyGlow.PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
									phillyGlowParticles.add(particle);
								}
							}
						}
						phillyGlowGradient.bop();
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
					camNotes.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
							case 3: char = mom;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD, camNotes];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}
			case 'Change Mania':
				var newMania:Int = 0;
				var skipTween:Bool = value2 == "true" ? true : false;

				newMania = Std.parseInt(value1);
				if(Math.isNaN(newMania) && newMania < 0 && newMania > 9)
					newMania = 0;
				changeMania(newMania, skipTween);

			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
					case 3:
						if(mom.curCharacter != value2) {
							if(!momMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = mom.curCharacter.startsWith('gf');
							var lastAlpha:Float = mom.alpha;
							mom.alpha = 0.00001;
							mom = momMap.get(value2);
							if(!mom.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							mom.alpha = lastAlpha;
						}
						setOnLuas('momName', mom.curCharacter);
				}
				reloadHealthBarColors();
			
			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();
			
			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
			case 'Toggle Ghost Trail': //Selever Crossfade
				var target = value1.split(',');
				var enabled = value2 == 'on' || value2 == '1' || value2 == 'true';
				if (target.length == 0 || (!enabled && !(value2 == 'off' || value2 == '0' || value2 == 'false'))) {
					//break; //tf you mean breaks don't work here?
				} else {
					var evilTrail = new FlxTrail(dad, null, 4, 12, 0.25, 0.069);
					evilTrail.framesEnabled = true;
					evilTrail.color = 0xaa0044;
					//evilTrail.changeValuesEnabled(false, false, false, false);
					// evilTrail.changeGraphic()
					add(evilTrail);
				}
			case 'Defeat Fade':
				var charType:Int = Std.parseInt(value1);
				if (Math.isNaN(charType))
					charType = 0;

				switch (charType)
				{
					case 0:
						FlxTween.tween(bodies, {alpha: 1}, 0.7, {ease: FlxEase.quadInOut});
						FlxTween.tween(bodies2, {alpha: 1}, 0.7, {ease: FlxEase.quadInOut});
						FlxTween.tween(bodiesfront, {alpha: 1}, 0.7, {ease: FlxEase.quadInOut});
					case 1:
						FlxTween.tween(bodies, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});
						FlxTween.tween(bodies2, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});
						FlxTween.tween(bodiesfront, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});
				}
			case 'Defeat Retro':
				var charType:Int = Std.parseInt(value1);
				if (Math.isNaN(charType))
					charType = 0;

				switch (charType)
				{
					case 0:
						bodiesfront.alpha = 0;
						lightoverlay.alpha = 0;
						mainoverlayDK.alpha = 1;
					case 1:
						triggerEventNote('Change Character', '0', 'bf-defeat-scared');
						triggerEventNote('Change Character', '1', 'black');
						bodiesfront.alpha = 1;
						lightoverlay.alpha = 1;
						mainoverlayDK.alpha = 0;
				}
			case 'DefeatDark':
				var charType:Int = Std.parseInt(value1);
				if (Math.isNaN(charType))
					charType = 0;

				switch (charType)
				{
					case 0:
						defeatblack.alpha = 0;
						defeatDark = false;
						scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						scoreTxt.y = healthBarBG.y + 36;
						iconP1.visible = true;
						iconP2.visible = true;
					case 1:
						defeatblack.alpha += 1;
						defeatDark = true;
						scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						scoreTxt.y = healthBarBG.y + 62;
						iconP1.visible = false;
						iconP2.visible = false;
				}
			case 'flash':
				var charType:Int = Std.parseInt(value1);
				if (Math.isNaN(charType))
					charType = 0;
				// also used for identity crisis idk why dont blame me shrug
				switch (charType)
				{
					case 0:
						if (ClientPrefs.flashing)
							camGame.flash(FlxColor.WHITE, 0.35);
					case 1:
						if (ClientPrefs.flashing)
							camGame.flash(FlxColor.WHITE, 0.35);
				}

				if(curStage.toLowerCase() == 'cargo'){
					cargoDarkFG.alpha = 0;
					camHUD.visible = true;
					camNotes.visible = true;
					if (pendulumMode){
						tranceNotActiveYet = false;
						pendulum.alpha = 1;
					}
				}
			case 'Reactor Beep':
				var charType:Float = Std.parseFloat(value1);
				if (Math.isNaN(charType))
					charType = 0.4;

				flashSprite.alpha = charType;

				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
				camNotes.zoom += 0.03;
			case 'Double Kill Events':
				switch(value1.toLowerCase()){
					case 'darken':
						cargoDarken = true;
						camGame.flash(FlxColor.BLACK, 0.55);
					case 'airship':
						showDlowDK = true;
					case 'brighten':
						showDlowDK = false;
						cargoDarken = false;
						cargoAirsip.alpha = 0.001;
						cargoDark.alpha = 0.001;
						dad.alpha = 1;
						mom.alpha = 1;
						lightoverlayDK.alpha = 0.51;
						mainoverlayDK.alpha = 0.6;
						
					case 'gonnakill':
						cargoReadyKill = true;
					case 'readykill':
						camGame.flash(FlxColor.BLACK, 2.75);
						triggerEventNote('Change Character', '0', 'bf-defeat-normal');
						defeatDKoverlay.alpha = 1;
						lightoverlayDK.alpha = 0;
						mainoverlayDK.alpha = 0;
						cargoDarkFG.alpha = 0;
						cargoDark.alpha = 1;
						cargoReadyKill = false;
						dad.alpha = 0;
						timeBar.alpha = 0;
						timeBarBG.alpha = 0;
						timeTxt.alpha = 0;
						healthBar.alpha = 0;
						healthBarBG.alpha = 0;
						iconP1.alpha = 0;
						iconP2.alpha = 0;
					case 'kill':
						camGame.flash(FlxColor.RED, 2.75);
						mom.alpha = 0;
						boyfriend.alpha = 0;
						camHUD.visible = false;
						camNotes.visible = false;
						defeatDKoverlay.alpha = 0;
						if (pendulumMode)
							tranceNotActiveYet = true;
				}
			case 'Opponent Two':
				opponent2sing = !opponent2sing;
				bothOpponentsSing = false;

				if(opponent2sing){
					switch(curStage){
						case 'cargo':
							healthBar.createColoredEmptyBar(FlxColor.fromRGB(58,27,80));    
							iconP2.changeIcon('black');
							botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
							scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
				}
				else{
					switch(curStage){
						case 'cargo':
							healthBar.createColoredEmptyBar(FlxColor.fromRGB(209,210,248));    
							iconP2.changeIcon('white');
							botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
							scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
				}

			case 'Both Opponents':
				bothOpponentsSing = !bothOpponentsSing;

				if(bothOpponentsSing){
					switch(curStage){
						case 'cargo':
							healthBar.createColoredEmptyBar(FlxColor.fromRGB(58,27,80));    
							iconP2.changeIcon('whiteblack');	
							botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
							scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
				}
				else{
					if(opponent2sing){
						switch(curStage){
							case 'cargo':
								healthBar.createColoredEmptyBar(FlxColor.fromRGB(58,27,80));    
								iconP2.changeIcon('black');
								botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
								scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						}
					}
					else{
						switch(curStage){
							case 'cargo':
								healthBar.createColoredEmptyBar(FlxColor.fromRGB(209,210,248));    
								iconP2.changeIcon('white');
								botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
								scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						}
					}
				}
			case 'Jerma Scream':
				scaryJerma.animation.play('w');
				scaryJerma.alpha = 1;

			case 'Jerma Screamed':
				scaryJerma.alpha = 0;
				FlxG.camera.zoom += 0.9;
				camHUD.zoom += 0.9;
				camNotes.zoom += 0.9;
			case 'Extra Cam Zoom':
				var _zoom:Float = Std.parseFloat(value1);
				if (Math.isNaN(_zoom))
					_zoom = 0;
				extraZoom = _zoom;
			case 'Camera Twist':
				camTwist = true;
				var _intensity:Float = Std.parseFloat(value1);
				if (Math.isNaN(_intensity))
					_intensity = 0;
				var _intensity2:Float = Std.parseFloat(value2);
				if (Math.isNaN(_intensity2))
					_intensity2 = 0;
				camTwistIntensity = _intensity;
				camTwistIntensity2 = _intensity2;
				if (_intensity2 == 0)
				{
					camTwist = false;
					FlxTween.tween(camHUD, {angle: 0}, 1, {ease: FlxEase.sineInOut});
					FlxTween.tween(camNotes, {angle: 0}, 1, {ease: FlxEase.sineInOut});
					FlxTween.tween(camGame, {angle: 0}, 1, {ease: FlxEase.sineInOut});
				}
			case 'Alter Camera Bop':
				var _intensity:Float = Std.parseFloat(value1);
				if (Math.isNaN(_intensity))
					_intensity = 1;
				var _interval:Int = Std.parseInt(value2);
				if (Math.isNaN(_interval))
					_interval = 4;

				camBopIntensity = _intensity;
				camBopInterval = _interval;
			case 'pink toggle':
				if(pinkCanPulse == false){
					pinkCanPulse = true;
						
					heartsImage.alpha = 1;
					pinkVignette.alpha = 1;
					pinkVignette2.alpha = 0.3;

					var fadeTime:Float = Std.parseFloat(value1)*1.2;
					if (Math.isNaN(fadeTime))
						fadeTime = 0;

					heartColorShader.amount = 1;
					FlxTween.tween(heartColorShader, {amount: 0}, fadeTime, {ease: FlxEase.cubeInOut});
					heartEmitter.emitting = true;
					return;
				}else{
					var fadeTime:Float = Std.parseFloat(value1)*2;
					if (Math.isNaN(fadeTime))
						fadeTime = 0;

					if(vignetteTween != null) vignetteTween.cancel();
					if(whiteTween != null) whiteTween.cancel();

					heartsImage.alpha = 1;
					pinkVignette.alpha = 1;
					pinkVignette2.alpha = 0.4;

					heartColorShader.amount = 1;

					FlxTween.tween(heartsImage, {alpha: 0}, fadeTime, {ease: FlxEase.cubeInOut});
					FlxTween.tween(heartColorShader, {amount: 0}, fadeTime, {ease: FlxEase.cubeInOut});
					FlxTween.tween(pinkVignette, {alpha: 0}, fadeTime, {ease: FlxEase.cubeInOut});
					FlxTween.tween(pinkVignette2, {alpha: 0}, fadeTime, {ease: FlxEase.cubeInOut});
					// heartsImage.visible = false;
					// pinkVignette.visible = false;
					// pinkVignette2.visible = false;
						
						
					pinkCanPulse = false;
					heartEmitter.emitting = false;
					return;
				}
			case 'HUD Fade':
				var charType:Int = Std.parseInt(value1);
				if (Math.isNaN(charType))
					charType = 0;

				switch (charType)
				{
					case 0:
						FlxTween.tween(camHUD, {alpha: 1}, 0.7, {ease: FlxEase.quadInOut});
						FlxTween.tween(camNotes, {alpha: 1}, 0.7, {ease: FlxEase.quadInOut});
					case 1:
						FlxTween.tween(camHUD, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});
						FlxTween.tween(camNotes, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});
				}
			case 'Majin count':
				switch (Std.parseFloat(value1))
				{
					case 1:
						inCutscene = true;
						camFollow.set(FlxG.width / 2 + 50, FlxG.height / 4 * 3 + 280);
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
						majinSaysFuck(4);
					case 2:
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
						majinSaysFuck(3);
					case 3:
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
						majinSaysFuck(2);
					case 4:
						inCutscene = false;
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.7, {ease: FlxEase.cubeInOut});
						majinSaysFuck(1);
				}
			case 'Majin spin':
				strumLineNotes.forEach(function(tospin:FlxSprite)
					{
						FlxTween.angle(tospin, 0, 360, 0.2, {ease: FlxEase.quintOut});
					});
			case 'Clear Popups':
				while(FatalPopup.popups.length>0)
					FatalPopup.popups[0].close();
			case 'Fatality Popup':
				if (!pussyMode){
					var value:Int = Std.parseInt(value1);
					if (Math.isNaN(value) || value<1)
						value = 1;
	
					var type:Int = Std.parseInt(value2);
					if (Math.isNaN(type) || type<1)
						type = 1;
					for(idx in 0...value){
						doPopup(type);
					}
				}
			case 'char disappear':
				boyfriendGroup.visible = false;
				flooooor.visible = false;
			case 'char appear':
				boyfriendGroup.visible = true;
				flooooor.visible = true;
			case 'Pnotefade':
				playerStrums.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.2, {ease: FlxEase.sineOut});
				});
			case 'Pnotein':
				playerStrums.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {alpha: 1}, 0.1, {ease: FlxEase.sineIn});
				});
			case 'TDnoteshitdie':
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (!ClientPrefs.middleScroll)
						spr.x -= 300;
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x -= 1000;
				});
			case 'TDnoteshitlive':
				playerStrums.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {alpha: 1}, 0.4, {ease: FlxEase.circOut});
					if (!ClientPrefs.middleScroll)
						spr.x += 300;
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x += 1000;
				});
			case 'Character Fly':
				flyState = '';
				FlxTween.tween(dad, {x: DAD_X, y: DAD_Y}, 0.2, {
					onComplete: function(lol:FlxTween)
					{
						dad.setPosition(DAD_X, DAD_Y);
						flyState = value1;
					}
				});
			case 'TooSlowFlashinShit':
				switch (Std.parseFloat(value1))
				{
					case 1:
						doStaticSign(0);
					case 2:
						doSimpleJump();
				}
			case 'sonicspook':
				trace('JUMPSCARE aaaa');

				var daJumpscare:FlxSprite = new FlxSprite();
				daJumpscare.frames = Paths.getSparrowAtlas('Exe/sonicJUMPSCARE');
				daJumpscare.animation.addByPrefix('jump', "sonicSPOOK", 24, false);
				daJumpscare.animation.play('jump',true);
				daJumpscare.scale.x = 1.1;
				daJumpscare.scale.y = 1.1;
				daJumpscare.updateHitbox();
				daJumpscare.screenCenter();
				daJumpscare.y += 370;
				daJumpscare.cameras = [camNotes];

				FlxG.sound.play(Paths.sound('jumpscare'), 1);
				FlxG.sound.play(Paths.sound('datOneSound'), 1);

				add(daJumpscare);

				daJumpscare.animation.play('jump');

				daJumpscare.animation.finishCallback = function(pog:String)
				{
					trace('ended jump');
					daJumpscare.visible = false;
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;
		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);

			switch (dad.curCharacter){
				case 'exe':
					FlxTween.tween(FlxG.camera, {zoom: 0.9}, 0.4, {ease: FlxEase.cubeOut});
					defaultCamZoom = 0.9;
			}

			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			moveCamera(true);
			if(ClientPrefs.camMovement && !PlayState.isPixelStage){
				campointx = camFollow.x;
				campointy = camFollow.y;
				bfturn = false;
				camlock = false;
				cameraSpeed = 1;
			}
			callOnLuas('onMoveCamera', ['dad']);
			if (SONG.song.toLowerCase() == 'lost cause')
				defaultCamZoom = 0.65;

			switch (dad.curCharacter){
				case "fatal-sonic", "fatal-glitched":
					camFollow.y -= 50;
					defaultCamZoom = 0.55;
				case 'sonicexeold':
					camFollow.y = dad.getMidpoint().y - 30;
					camFollow.x = dad.getMidpoint().x + 120;
				case 'exe':
					FlxTween.tween(FlxG.camera, {zoom: 0.8}, 0.4, {ease: FlxEase.cubeOut});
					defaultCamZoom = 0.8;
					camFollow.y = dad.getMidpoint().y - 300;
					camFollow.x = dad.getMidpoint().x - 100;
				case 'sonicLordX':
					camFollow.set(dad.getGraphicMidpoint().x + 200, dad.getGraphicMidpoint().y);
					camFollow.y = dad.getMidpoint().y - 150;
					camFollow.x = dad.getMidpoint().x + 120;
					FlxTween.tween(FlxG.camera, {zoom: 0.73}, 0.4, {ease: FlxEase.cubeOut});
					defaultCamZoom = 0.73;
			}
		}
		else
		{
			moveCamera(false);
			if(ClientPrefs.camMovement && !PlayState.isPixelStage){
				campointx = camFollow.x;
				campointy = camFollow.y;	
				bfturn = true;
				camlock = false;
				cameraSpeed = 1;
			}
			callOnLuas('onMoveCamera', ['boyfriend']);
			if (SONG.song.toLowerCase() == 'lost cause')
				defaultCamZoom = 0.8;
			if (SONG.song.toLowerCase() == 'fatality')
				defaultCamZoom = 0.75;
			if (SONG.song.toLowerCase() == 'execution') {
				FlxTween.tween(FlxG.camera, {zoom: 0.9}, 0.4, {ease: FlxEase.cubeOut});
				defaultCamZoom = 0.9;
			}
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			if (curSong.toLowerCase() == 'infitrigger')
				camFollow.set(boyfriend.getMidpoint().x -450, boyfriend.getMidpoint().y - 165);
			else
				camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();

			switch (dad.curCharacter)
			{
				case 'delirium':
					camFollow.x = dad.getMidpoint().x - 30;
			}
		}
		else
		{
			if (curSong.toLowerCase() == 'infitrigger')
				camFollow.set(boyfriend.getMidpoint().x - 370, boyfriend.getMidpoint().y - 165);
			else
				camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			switch (curStage)
			{
				case 'nevada','auditorHell':
					camFollow.y = boyfriend.getMidpoint().y - 300;
				case 'barnblitz-heavy':
					camFollow.y = boyfriend.getMidpoint().y - 250;
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'honor':
					camFollow.y = boyfriend.getMidpoint().y - 200;
					camFollow.x = boyfriend.getMidpoint().x - 250;
				case 'degroot':
					camFollow.y = boyfriend.getMidpoint().y - 225;
					camFollow.x = boyfriend.getMidpoint().x - 250;
			}
			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}
	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}

	public var transitioning = false;

	function createSpookyText(text:String, x:Float = -1111111111111, y:Float = -1111111111111):Void
		{
			spookySteps = curStep;
			spookyRendered = true;
			tstatic.alpha = 0.5;
			FlxG.sound.play(Paths.sound('staticSound'));
			spookyText = new FlxText((x == -1111111111111 ? FlxG.random.float(dad.x + 40,dad.x + 120) : x), (y == -1111111111111 ? FlxG.random.float(dad.y + 200, dad.y + 300) : y));
			spookyText.setFormat("Impact", 128, FlxColor.RED);
			spookyText.bold = true;
			spookyText.text = text;
			add(spookyText);
		}

	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong && SONG.song.toLowerCase() != 'fatality') {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['bopeebo_pfc', 'ballistic_95acc', 'ballistichq_95acc', 'madness_fc', 'expurgation_95acc', 'foolhardy_95acc', 'sporting_95acc', 'tooslow_95acc', 'tooslowencore_95acc', 'endless_95acc', 'oldendless_95acc',
			'cycles_fc', 'execution_fc', 'sunshine_95acc', 'chaos_95acc', 'faker_fc', 'blacksun_95acc', 'fatality_90acc', 'novillains_95acc', 'noheroes_95acc', 'phantasm_95acc', 'lostcause_95acc', 'reactor_95acc', 'doublekill_95acc', 'defeat_fc', 'heartbeat_fc', 
			'pretender_fc', 'insanestreamer_fc', 'idk_fc', 'torture_fc', 'sage_fc', 'infitrigger_2miss', 'ebola_immune', 'honorbound_95acc', 'eyelander_98acc', 'strongmann_95acc', 'acceptance_fc', 'delirious_95acc', 'recursed_fc', 'bombastic_95acc', 'abuse_fc', 
			'trinity_90acc', 'iamgod_95acc', 'superscare_95acc', 'attack_95acc', 'blueballed_100', 'fourkeyonly', 'insanity']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore && !pussyMode)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					WeekData.loadTheFirstEnabledMod();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var ratingIndexArray:Array<String> = ["sick", "good", "bad", "shit"];
	public var returnArray:Array<String> = [" [SFC]", " [GFC]", " [FC]", ""];
	public var smallestRating:String;

	function updateSonicScore(){
		var seperatedScore:Array<String> = Std.string(songScore).split("");
		if(seperatedScore.length<scoreNumbers.length){
			for(idx in seperatedScore.length...scoreNumbers.length){
				if(hudStyle == 'chaotix' || hudStyle == 'sonic3' || hudStyle == 'soniccd'){
					seperatedScore.unshift('');
				}else{
					seperatedScore.unshift('0');
				}
			}
		}
		if(seperatedScore.length>scoreNumbers.length)
			seperatedScore.resize(scoreNumbers.length);

		for(idx in 0...seperatedScore.length){
			if(seperatedScore[idx]!='' || idx==scoreNumbers.length-1){
				var val = Std.parseInt(seperatedScore[idx]);
				if(Math.isNaN(val))val=0;
				scoreNumbers[idx].number = val;
				scoreNumbers[idx].visible=true;
			}else
				scoreNumbers[idx].visible=false;

		}
	}

	function updateSonicMisses(){
		var seperatedScore:Array<String> = Std.string(songMisses).split("");
		if(seperatedScore.length<missNumbers.length){
			for(idx in seperatedScore.length...missNumbers.length){
				if(hudStyle == 'chaotix' || hudStyle == 'sonic3' || hudStyle == 'soniccd'){
					seperatedScore.unshift('');
				}else{
					seperatedScore.unshift('0');
				}
			}
		}
		if(seperatedScore.length>missNumbers.length)
			seperatedScore.resize(missNumbers.length);

		for(idx in 0...seperatedScore.length){
			if(seperatedScore[idx]!='' || idx==missNumbers.length-1){
				var val = Std.parseInt(seperatedScore[idx]);
				if(Math.isNaN(val))val=0;
				missNumbers[idx].number = val;
				missNumbers[idx].visible=true;
			}else
				missNumbers[idx].visible=false;

		}
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		if (isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);
		
		for (i in 0...10) {
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
	}

	private function popUpScore(note:Note = null):Void
	{
		if (ClientPrefs.hitsounds)
			{
				FlxG.sound.play(Paths.sound('hitsound'));
			}

		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			updateSonicScore();
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;

		if(curStage == 'idk') {
			rating.visible = false;
		}

		insert(members.indexOf(strumLineNotes), rating);
		
		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
		{
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		if (!ClientPrefs.comboStacking)
		{
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];
			
			if (!ClientPrefs.comboStacking)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.hideHud;

			if(curStage == 'idk') {
				numScore.visible = false;
            }

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && FlxG.keys.checkStatus(eventKey, JUST_PRESSED))
		{
			if(freezeCounter>0){
				var keyToPress = 5*(freezeCounter-1)%2; // left then right
				trace(keyToPress);
				if(key==keyToPress){
					FlxG.sound.play(Paths.sound("struggle"),0.75);
					freezeCounter--;

					var shit = Math.floor(((maxFreeze-freezeCounter)/maxFreeze)*4);
					frozenBF.animation.play('${shit}', true);
					var nextKey = 5*(freezeCounter-1)%2; // left then right
					if(nextKey==5){
						rightIndicator.animation.play("hit",true);
						leftIndicator.animation.play("idle",true);
					}else{
						rightIndicator.animation.play("idle",true);
						leftIndicator.animation.play("hit",true);
					}
				}

				if(freezeCounter==0){
					if(indicatorTween!=null)indicatorTween.cancel();
					indicatorTween = FlxTween.tween(frozenIndicators, {alpha: 0}, 0.25, {ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween) {
							indicatorTween = null;
						}
					});
					FlxG.sound.play(Paths.sound("breakout"),1);
					frozenBF.visible=false;
					boyfriend.visible=true;
					boyfriend.playAnim("hey",true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = 0.6;
				}
			}
			if(freezeCounter<=0){
				if(!boyfriend.stunned && generatedMusic && !endingSong)
				{
					//more accurate hit time for the ratings?
					var lastTime:Float = Conductor.songPosition;
					Conductor.songPosition = FlxG.sound.music.time;

					var canMiss:Bool = !ClientPrefs.ghostTapping;

					// heavily based on my own code LOL if it aint broke dont fix it
					var pressNotes:Array<Note> = [];
					//var notesDatas:Array<Int> = [];
					var notesStopped:Bool = false;

					var sortedNotesList:Array<Note> = [];
					notes.forEachAlive(function(daNote:Note)
					{
						if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
						{
							if(daNote.noteData == key)
							{
								sortedNotesList.push(daNote);
								//notesDatas.push(daNote.noteData);
								canMiss = ClientPrefs.antimash;
							}
						}
					});
					sortedNotesList.sort(sortHitNotes);

					if (sortedNotesList.length > 0) {
						for (epicNote in sortedNotesList)
						{
							for (doubleNote in pressNotes) {
								if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
									doubleNote.kill();
									notes.remove(doubleNote, true);
									doubleNote.destroy();
								} else
									notesStopped = true;
							}
								
							// eee jack detection before was not super good
							if (!notesStopped) {
								goodNoteHit(epicNote);
								pressNotes.push(epicNote);
							}

						}
					}
					else{
						callOnLuas('onGhostTap', [key]);
						if (canMiss) {
							noteMissPress(key);
						}
					}

					// I dunno what you need this for but here you go
					//									- Shubs

					// Shubs, this is for the "Just the Two of Us" achievement lol
					//									- Shadow Mario
					keysPressed[key] = true;

					//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
					Conductor.songPosition = lastTime;
				}

				var spr:StrumNote = playerStrums.members[key];
				if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
				{
					spr.playAnim('pressed');
					spr.resetAnim = 0;
				}
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}

			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray[mania].length)
			{
				for (j in 0...keysArray[mania][i].length)
				{
					if(key == keysArray[mania][i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	private function keysArePressed():Bool
	{
		for (i in 0...keysArray[mania].length) {
			for (j in 0...keysArray[mania][i].length) {
				if (FlxG.keys.checkStatus(keysArray[mania][i][j], PRESSED)) return true;
			}
		}

		return false;
	}

	private function dataKeyIsPressed(data:Int):Bool
	{
		for (i in 0...keysArray[mania][data].length) {
			if (FlxG.keys.checkStatus(keysArray[mania][data][i], PRESSED)) return true;
		}

		return false;
	}

	private function keyShit():Void
	{
		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			if(freezeCounter<=0){
				notes.forEachAlive(function(daNote:Note)
				{
					// hold note functions
					if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && dataKeyIsPressed(daNote.noteData % Note.ammo[mania]) && daNote.canBeHit
					&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
						goodNoteHit(daNote);
					}
				});
			}

			if (keysArePressed() && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}
	}

	function doSpam():Void
		{
			nuts(noo);	
			noo++;
			health -= 0.095;
			vocals.volume = 0;					
		}
	public function nuts(n:Int):Void 
		{
		   // n = baits;
			
			
			
			var bait1:FlxSprite = new FlxSprite(981,181).loadGraphic(Paths.image('V/bait/pic1','shared'));
			var bait2:FlxSprite = new FlxSprite(662,405).loadGraphic(Paths.image('V/bait/pic2','shared'));
			var bait3:FlxSprite = new FlxSprite(985,500).loadGraphic(Paths.image('V/bait/pic3','shared'));
			var bait4:FlxSprite = new FlxSprite(680,8).loadGraphic(Paths.image('V/bait/pic4','shared'));
			var bait5:FlxSprite = new FlxSprite(800,335).loadGraphic(Paths.image('V/bait/pic5','shared'));
			var bait6:FlxSprite = new FlxSprite(959,10).loadGraphic(Paths.image('V/bait/pic6','shared'));
			var bait7:FlxSprite = new FlxSprite(630,235).loadGraphic(Paths.image('V/bait/pic7','shared'));
			var bait8:FlxSprite = new FlxSprite(722,500).loadGraphic(Paths.image('V/bait/pic8','shared'));
			if(ClientPrefs.middleScroll){
				bait1.x -= 300;
				bait2.x -= 300;
				bait3.x -= 300;
				bait4.x -= 300;
				bait5.x -= 300;
				bait6.x -= 300;
				bait7.x -= 300;
				bait8.x -= 300;
			}
		    bait1.cameras = [camOther];
			bait2.cameras = [camOther];
			bait3.cameras = [camOther];
			bait4.cameras = [camOther];
			bait5.cameras = [camOther];
			bait6.cameras = [camOther];
			bait7.cameras = [camOther];
			bait8.cameras = [camOther];
			
			switch (n)
			{
				case 1 : add(bait1); 
				case 2 : add(bait2); 
				case 3 : add(bait3); 
				case 4 : add(bait4); 
				case 5 : add(bait5); 
				case 6 : add(bait6); 
				case 7 : add(bait7); 
				case 8 : add(bait8); 
			}
		   
		
		}
	public function ebolachan():Void
		{
			var lefunnyhead = Paths.getSparrowAtlas('bonus/mec/head','shared');
					ebolabitch.frames = lefunnyhead;
					ebolabitch.animation.addByPrefix('laugh', 'ebolagrl' ,24,false);
					ebolabitch.animation.play('laugh');
					ebolabitch.scale.set(1.5,1.5);
					ebolabitch.screenCenter();	
					add(ebolabitch);
					ebolabitch.animation.finishCallback = function(youwilldieandyouwilllikeit:String)
						{							
							remove(ebolabitch);								
						}				
		}
	function bonusanims():Void
		{			
			if (curSong.toLowerCase() == 'infitrigger') 
				{
					switch (curBeat)
					{
						case 10 : 
							scaredyo.animation.play('aaaa');
							scaredyo.animation.finishCallback = function(whitewhitty:String)
								{									
									scaredyo.destroy(); ///for opt
								}	
						
						case 68:
							r9k.visible=true;	
						
						        r9k.animation.play('ded');					   
								r9k.animation.finishCallback = function(whitewhitty:String)
								{									
								r9k.destroy();
								}	
						case 150:
							
							blackguy.visible=true;
							
							blackguy.animation.play('ded');	
							blackguy.animation.finishCallback = function(whitewhitty:String)
								{									
									blackguy.destroy();					
								}				
						case 260:
								unsmile.visible=true;

								unsmile.animation.play('ded');	
								unsmile.animation.finishCallback = function(whitewhitty:String)
									{									
										unsmile.destroy();							
									}			

						case 352:
							cat.visible=true;				
							cat.animation.play('ded');
								cat.animation.finishCallback = function(whitewhitty:String)
									{										
									unsmile.destroy();							
														
									}		
						
				}					
			
		   }
		}

	function doFlip():Void
		{
		trace('flip em!!!!');  
			blackboi = new FlxSprite(536,-140);
			if (ClientPrefs.middleScroll)
				blackboi.x = 226;
			blackboi.frames = Paths.getSparrowAtlas('bonus/mec/fnotes','shared');
			blackboi.animation.addByPrefix('flipem','black',24,false);
			blackboi.scale.set(0.7,0.7);				
			blackboi.cameras = [camOther];	
			if(ClientPrefs.downScroll)
				{
			blackboi.flipX = true;
			blackboi.flipY = true;
			blackboi.y =  326;
			if (ClientPrefs.middleScroll)
				blackboi.x =  215;
			else
				blackboi.x =  525;
				}			
				//beat 449
				//step 1797
			add(blackboi);
			blackboi.animation.play("flipem");		
			blackboi.animation.finishCallback = function(donefliping:String)
				{									
					remove(blackboi);						
				}				
		}

	function tweenCam(zoom:Float, duration:Float):Void
		{
			FlxTween.tween(FlxG.camera, {zoom: zoom}, duration ,{ease: FlxEase.quadInOut});
		}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;

		health -= daNote.missHealth * healthLoss;
		if(instakillOnMiss || sickOnly)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		updateSonicMisses();
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) {
			songScore -= 10;
			updateSonicScore();
		}
		totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = 'sing' + Note.keysShit.get(mania).get('anims')[daNote.noteData] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}

		switch(daNote.noteType) {
			case 'Sage Note':
				if (!pussyMode)
					doSpam();
			case 'Drunk Note':
				if (!pussyMode) {
					tweenCam(1.55, 1);
					shakeCam = true;
					FlxG.sound.play(Paths.sound('A'));
					health += -1;
					if(boyfriend.animation.getByName('hurt') != null) {
						boyfriend.playAnim('hurt', true);
						boyfriend.specialAnim = true;
					}
	
					new FlxTimer().start(2, function(tmr:FlxTimer)
						{
							shakeCam = false;
							tweenCam(defaultCamZoom, 0.8);
						});
				}
			case 'Text Note':
				if (!pussyMode)
					recursedNoteMiss();
			case 'Conch Note':
				if (!pussyMode) {
					if(boyfriend.animation.getByName('hurt') != null) {
						boyfriend.playAnim('hurt');
					}
					if(dad.animation.getByName('slash') != null) {
						dad.playAnim('slash');
						dad.specialAnim = false;
					}
				}
			case "Static Note":
				trace('lol you missed the static note!');
				daNoteStatic = new FlxSprite(0, 0).loadGraphic(Paths.image("Exe/hitStatic"));
				daNoteStatic.frames = Paths.getSparrowAtlas('Exe/hitStatic');
				daNoteStatic.animation.addByPrefix('static', "staticANIMATION", 24, false);
				daNoteStatic.animation.play('static');
				daNoteStatic.cameras = [camNotes];
				add(daNoteStatic);

				FlxG.camera.shake(0.005, 0.005);

				FlxG.sound.play(Paths.sound("hitStatic1"));

				new FlxTimer().start(.38, function(trol:FlxTimer) // fixed lmao
				{
					daNoteStatic.alpha = 0;
					trace('ended HITSTATICLAWL');
					remove(daNoteStatic);
				});

			//	case 'Phantom Note':
			//	health -= 0;
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.ghostTapping) return; //fuck it

		if (!boyfriend.stunned)
		{
			// health -= 0.05 * healthLoss;

			if (curSong.toLowerCase() != 'black sun')
				health -= 0.05 * healthLoss;

			if(instakillOnMiss || sickOnly)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if (SONG.song.toLowerCase() == 'acceptance' && curStep < 1568)
				{
					var misseffect:FlxSprite = new FlxSprite(-400, -200);
					remove(misseffect);
					if (ClientPrefs.flashing)
						FlxG.camera.flash(FlxColor.BLACK, 0.5);
					FlxG.camera.shake(0.02,0.2);
					misseffect.frames = Paths.getSparrowAtlas('isaac/chest/misseffect','shared');
					misseffect.animation.addByPrefix('miss','hurt',24,false);
					misseffect.animation.play('miss');
					misseffect.setGraphicSize(Std.int(misseffect.width * 0.7));
					misseffect.antialiasing = true;
					misseffect.cameras = [camHUD];
					misseffect.scrollFactor.set(0, 0);
					add(misseffect);
					misseffect.animation.finishCallback = function(name:String) {
						remove(misseffect);		
					}
				}

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
				updateSonicMisses();
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim('sing' + Note.keysShit.get(mania).get('anims')[direction] + 'miss', true);
			}
			vocals.volume = 0;
		}
		callOnLuas('noteMissPress', [direction]);
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial' || !songIsWeird)
			camZooming = true;

		if (soldierShake)
			FlxG.camera.shake(0.015,0.04);

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = 'sing' + Note.keysShit.get(mania).get('anims')[note.noteData] + altAnim;
			if(note.gfNote) {
				char = gf;
			}
			else if(note.noteType == 'Opponent 2 Sing' || opponent2sing == true) {
				char = mom;
			}
			else if (note.noteType == 'Both Opponents Sing' || bothOpponentsSing == true) {
				mom.playAnim(animToPlay, true);
				mom.holdTimer = 0;
				dad.playAnim(animToPlay, true);
				dad.holdTimer = 0;
			}

			switch(dad.curCharacter)
			{
				case 'delirium': 
					if (!pussyMode){
						if (health >= 0.10)
							{
								health -= 0.01;
							}
					}
					if (ClientPrefs.flashing) {
						if (FlxG.random.bool(20))
							{
								staticlol.alpha = 0.7;
							}
					}
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (dad.curCharacter == 'extricky')
			{
				if (dad.animation.curAnim.name == 'singUP')
				{
					trace('spikes');
					exSpikes.visible = true;
					if (exSpikes.animation.finished)
						exSpikes.animation.play('spike');
				}
				else if (!exSpikes.animation.finished)
				{
					exSpikes.animation.resume();
					trace('go back spikes');
					exSpikes.animation.finishCallback = function(pog:String) {
						trace('finished');
						exSpikes.visible = false;
						exSpikes.animation.finishCallback = null;
					}
				}
			}

		switch(dad.curCharacter)
		{
			case 'tricky': // 20% chance
				if (FlxG.random.bool(20) && !spookyRendered && !note.isSustainNote) // create spooky text :flushed:
					{
						createSpookyText(TrickyLinesSing[FlxG.random.int(0,TrickyLinesSing.length)]);
					}
			case 'extricky': // 60% chance
				if (FlxG.random.bool(60) && !spookyRendered && !note.isSustainNote) // create spooky text :flushed:
					{
						createSpookyText(ExTrickyLinesSing[FlxG.random.int(0,ExTrickyLinesSing.length)]);
					}	
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		if (healthDrainMod == true){
			if (health - 0.023 * healthDrain < 0)
				health = 0.01;
			else if (health - 0.023 * healthDrain > 0)
				health = health - 0.023 * healthDrain;
		}

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % Note.ammo[mania], time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
		
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if(note.hitCausesMiss) {
				noteMiss(note);
				updateSonicMisses();
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Static Note': // what do you fucking think dawg
							health += 0;
						case 'Majin Note':
							health += 0;
						case 'Hurt Note': //Hurt note
							if (!pussyMode){
								if(boyfriend.animation.getByName('hurt') != null) {
									boyfriend.playAnim('hurt', true);
									boyfriend.specialAnim = true;
								}
							}
						case 'Ebola Note':
							if (!pussyMode){
								ebolachan();
								totalEbolaNotesHit += 1;
								healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
								FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]));
								var choosesprite = FlxG.random.int(1,4);//what laf do i want hmmm
								switch (choosesprite)
								{
								  case 1	:FlxG.sound.play(Paths.sound('cancer/laugh1'));
								  case 2	:FlxG.sound.play(Paths.sound('cancer/laugh2'));
								  case 3	:FlxG.sound.play(Paths.sound('cancer/laugh3'));
								  case 4	:FlxG.sound.play(Paths.sound('cancer/laugh4'));
								}	
									new FlxTimer().start(0.001, function(tmr:FlxTimer)
									{
												health -= 0.00025;
									}, 9000000);
							}
						case 'Deli Note':
							if (!pussyMode){
								if (delistatic.alpha <= 1.2)
									{
										  delistatic.alpha += 0.4;
									}
									FlxG.sound.play(Paths.sound('delistatic'));
							}
						case 'Fatal Note':
							if (hellMode){
								var noteStatic = new BGSprite('Exe/statix', 0, 0, 1.0, 1.0, ['statixx'], true);
								noteStatic.screenCenter();
								noteStatic.setGraphicSize(FlxG.width, FlxG.height);
								noteStatic.cameras = [camNotes];
								add(noteStatic);
								FlxG.sound.play(Paths.sound('staticBUZZ'));
								new FlxTimer().start(0.20, function(tmr:FlxTimer)
								{
									doPopup(1);
									remove(noteStatic);
								});
							}
						}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}
			else {
				if(!note.noMissAnimation)
					{
						switch(note.noteType) {
							case 'Drunk Note':
								if (!pussyMode)
									FlxG.sound.play(Paths.sound('burp'));
							case 'Conch Note':
								if (!pussyMode) {
									if(boyfriend.animation.getByName('dodge') != null) {
										boyfriend.playAnim('dodge');
									}
									if(dad.animation.getByName('slash') != null) {
										dad.playAnim('slash');
									}
								}
							case 'Ice Note':
								combo = 0;
								if(indicatorTween!=null)indicatorTween.cancel();
								indicatorTween = FlxTween.tween(frozenIndicators, {alpha: 1}, 0.25, {ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween) {
										indicatorTween = null;
									}
								});
								rightIndicator.animation.play("idle",true);
								leftIndicator.animation.play("hit",true);
								freezeCounter = maxFreeze+1;
								FlxG.sound.play(Paths.sound("hitIce"),1);
								frozenBF.animation.play("idle",true);
								frozenBF.visible=true;
								boyfriend.visible=false;
								note.wasGoodHit = true;
								if (!note.isSustainNote)
								{
									note.kill();
									notes.remove(note, true);
									note.destroy();
								}
								return;
							}
					}
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				if(combo > 9999) combo = 9999;
				popUpScore(note);
			}
			if (!isRecursed)
				{
					if (SONG.song.toLowerCase() != 'black sun')
						health += note.hitHealth * healthGain;
				}

			if(!note.noAnimation) {
				var animToPlay:String = 'sing' + Note.keysShit.get(mania).get('anims')[note.noteData];

				if(note.gfNote)
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else{
					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;
				}
			}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				} 
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % Note.ammo[mania], time);
			} else {
				var spr = playerStrums.members[note.noteData];
				if(spr != null)	
				{
					spr.playAnim('confirm', true);
				}
			}

			if (isRecursed && !note.isSustainNote)
				{
					noteCount++;
					notesLeftText.text = noteCount + '/' + notesLeft;
	
					if (noteCount >= notesLeft)
					{
						removeRecursed();
					}
				}

			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;

			
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
	}

	function recursedNoteMiss()
	{
		if (!isRecursed)
		{
			missedRecursedLetterCount++;
			var recursedCover = new FlxSprite().loadGraphic(Paths.image('recursed/recursedX'));
			recursedCover.x = (boyfriend.getGraphicMidpoint().x - boyfriend.width / 2) + new FlxRandom().float(-recursedCover.width, recursedCover.width);
			recursedCover.y = (boyfriend.getGraphicMidpoint().y - boyfriend.height / 2) + new FlxRandom().float(-recursedCover.height, recursedCover.height) / 2;

			recursedCover.angle = new FlxRandom().float(0, 180);
			
			recursedCovers.add(recursedCover);
			add(recursedCover);

			FlxG.camera.shake(0.012 * missedRecursedLetterCount, 0.5);
			if (missedRecursedLetterCount > new FlxRandom().int(2, 5))
			{
				turnRecursed();
			}
		}
		else
		{
			FlxG.camera.shake(0.02, 0.5);
			timeLeft -= 5;
		}
	}

	function turnRecursed()
		{
			preRecursedHealth = health;
			isRecursed = true;
			missedRecursedLetterCount = 0;
			for (cover in recursedCovers)
			{
				recursedCovers.remove(cover);
				remove(cover);
			}
			if (ClientPrefs.flashing)
				FlxG.camera.flash();
			
			if(boyfriend.curCharacter != 'bf-recursed') {
				if(!boyfriendMap.exists('bf-recursed')) {
					addCharacterToList('bf-recursed', 0);
				}

				var lastAlpha:Float = boyfriend.alpha;
				boyfriend.alpha = 0.00001;
				boyfriend = boyfriendMap.get('bf-recursed');
				boyfriend.alpha = lastAlpha;
				iconP1.changeIcon(boyfriend.healthIcon);
			}
			addRecursedUI();		
		}
	
	function addRecursedUI()
	{
		timeGiven = Math.round(new FlxRandom().float(25, 35));
		timeLeft = timeGiven;
		notesLeft = new FlxRandom().int(65, 100);
		noteCount = 0;

		var yOffset = healthBar.y - 50;

		notesLeftText = new FlxText((FlxG.width / 2) - 200, yOffset, 0, noteCount + '/' + notesLeft, 60);
		notesLeftText.setFormat("Comic Sans MS Bold", 30, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		notesLeftText.scrollFactor.set();
		notesLeftText.borderSize = 2.5;
		notesLeftText.cameras = [camHUD];
		add(notesLeftText);
		recursedUI.add(notesLeftText);

		var noteIcon:FlxSprite = new FlxSprite(notesLeftText.x + notesLeftText.width + 10, notesLeftText.y - 15).loadGraphic(Paths.image('recursed/noteIcon', 'shared'));
		noteIcon.scrollFactor.set();
		noteIcon.setGraphicSize(Std.int(noteIcon.width * 0.4));
		noteIcon.updateHitbox();
		noteIcon.cameras = [camHUD];
		add(noteIcon);
		recursedUI.add(noteIcon);

		timeLeftText = new FlxText((FlxG.width / 2) + 100, yOffset, 0, FlxStringUtil.formatTime(timeLeft), 60);
		timeLeftText.setFormat("Comic Sans MS Bold", 30, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeLeftText.scrollFactor.set();
		timeLeftText.borderSize = 2.5;
		timeLeftText.cameras = [camHUD];
		add(timeLeftText);
		recursedUI.add(timeLeftText);

		var timerIcon:FlxSprite = new FlxSprite(timeLeftText.x + timeLeftText.width + 20, timeLeftText.y - 7).loadGraphic(Paths.image('recursed/timerIcon', 'shared'));
		timerIcon.scrollFactor.set();
		timerIcon.setGraphicSize(Std.int(timerIcon.width * 0.4));
		timerIcon.updateHitbox();
		timerIcon.cameras = [camHUD];
		add(timerIcon);
		recursedUI.add(timerIcon);

		rotateRecursedCam();
	}
	function removeRecursed()
		{
			if (ClientPrefs.flashing)
				FlxG.camera.flash();
			
			cancelRecursedCamTween();
	
			isRecursed = false;
			for (element in recursedUI)
			{
				recursedUI.remove(element);
				remove(element);
			}
			if(boyfriend.curCharacter != 'bf') {
				if(!boyfriendMap.exists('bf')) {
					addCharacterToList('bf', 0);
				}

				var lastAlpha:Float = boyfriend.alpha;
				boyfriend.alpha = 0.00001;
				boyfriend = boyfriendMap.get('bf');
				boyfriend.alpha = lastAlpha;
				iconP1.changeIcon(boyfriend.healthIcon);
			}
			health = preRecursedHealth;
		}
	function initAlphabet(songList:Array<String>)
	{
		for (letter in alphaCharacters)
		{
			alphaCharacters.remove(letter);
			remove(letter);
		}
		var startWidth = 640;
		var width:Float = startWidth;
		var row:Float = 0;
		
		while (row < FlxG.height)
		{
			while (width < FlxG.width * 2.5)
			{
				for (i in 0...songList.length)
				{
					var curSong = songList[i];
					var song = new Alphabet(0, 0, curSong, true);
					song.x = width;
					song.y = row;

					width += song.width + 20;
					alphaCharacters.add(song);
					add(song);
					
					if (width > FlxG.width * 2.5)
					{
						break;
					}
				}
			}
			row += 120;
			width = startWidth;
		}
		for (char in alphaCharacters)
		{
			for (letter in char.characters)
			{
				letter.alpha = 0;
			}
		}
		for (char in alphaCharacters)
		{
			char.unlockY = true;
			for (alphaChar in char.characters)
			{
				alphaChar.velocity.set(new FlxRandom().float(-50, 50), new FlxRandom().float(-50, 50));
				alphaChar.angularVelocity = new FlxRandom().int(30, 50);

				alphaChar.setPosition(new FlxRandom().float(-FlxG.width / 2, FlxG.width * 2.5), new FlxRandom().float(0, FlxG.height * 2.5));
			}
		}
	}
	function rotateRecursedCam()
	{
		rotatingCamTween = FlxTween.tween(FlxG.camera, {angle: 8}, 5, {onComplete: function(tween:FlxTween)
		{
			FlxTween.tween(FlxG.camera, {angle: -8}, 5);
		}, type: FlxTweenType.ONESHOT, ease: FlxEase.backOut});
	}
	function cancelRecursedCamTween()
	{
		if (rotatingCamTween != null)
		{
			rotatingCamTween.cancel();
			rotatingCamTween = null;
	
			camRotateAngle = 0;
			
			FlxG.camera.angle = 0;
			camHUD.angle = 0;
			camNotes.angle = 0;
		}
	}
	function cinematicBars(time:Float, closeness:Float)
	{
		var upBar = new FlxSprite().makeGraphic(Std.int(FlxG.width * ((1 / defaultCamZoom) * 2)), Std.int(FlxG.height / 2), FlxColor.BLACK);
		var downBar = new FlxSprite().makeGraphic(Std.int(FlxG.width * ((1 / defaultCamZoom) * 2)), Std.int(FlxG.height / 2), FlxColor.BLACK);

		upBar.screenCenter();
		downBar.screenCenter();
		upBar.scrollFactor.set();
		downBar.scrollFactor.set();
		upBar.cameras = [camOther];
		downBar.cameras = [camOther];

		upBar.y -= 2000;
		downBar.y += 2000;

		add(upBar);
		add(downBar);
		
		FlxTween.tween(upBar, {y: (FlxG.height - upBar.height) / 2 - closeness}, (Conductor.crochet / 1000) / 2, {ease: FlxEase.expoInOut, onComplete: function(tween:FlxTween)
		{
			new FlxTimer().start(time, function(timer:FlxTimer)
			{
				FlxTween.tween(upBar, {y: upBar.y - 2000}, (Conductor.crochet / 1000) / 2, {ease: FlxEase.expoIn, onComplete: function(tween:FlxTween)
				{
					remove(upBar);
				}});
			});
		}});
		FlxTween.tween(downBar, {y: (FlxG.height - downBar.height) / 2 + closeness}, (Conductor.crochet / 1000) / 2, {ease: FlxEase.expoInOut, onComplete: function(tween:FlxTween)
		{
			new FlxTimer().start(time, function(timer:FlxTimer)
			{
				FlxTween.tween(downBar, {y: downBar.y + 2000}, (Conductor.crochet / 1000) / 2, {ease: FlxEase.expoIn, onComplete: function(tween:FlxTween)
				{
					remove(downBar);
				}});
			});
		}});
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;

		if (data > -1 && data < ClientPrefs.arrowHSV.length)
		{
			hue = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[data] % Note.ammo[mania])][0] / 360;
			sat = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[data] % Note.ammo[mania])][1] / 100;
			brt = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[data] % Note.ammo[mania])][2] / 100;
			if(note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null)
		{
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
			camNotes.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
				FlxTween.tween(camNotes, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void
	{
		if(!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	function majinSaysFuck(numb:Int):Void
		{
			switch(numb)
			{
				case 4:
					var three:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Exe/three'));
					three.scrollFactor.set();
					three.updateHitbox();
					three.screenCenter();
					three.y -= 100;
					three.alpha = 0.5;
					three.cameras = [camOther];
					add(three);
					FlxTween.tween(three, {y: three.y + 100, alpha: 0, "scale.x": 1.05, "scale.y": 1.05}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeOut,
						onComplete: function(twn:FlxTween)
						{
							three.destroy();
						}
					});
				case 3:
					var two:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Exe/two'));
					two.scrollFactor.set();
					two.screenCenter();
					two.y -= 100;
					two.alpha = 0.5;
					two.cameras = [camOther];
					add(two);
					FlxTween.tween(two, {y: two.y + 100, alpha: 0, "scale.x": 1.05, "scale.y": 1.05}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeOut,
						onComplete: function(twn:FlxTween)
						{
							two.destroy();
						}
					});
				case 2:
					var one:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Exe/one'));
					one.scrollFactor.set();
					one.screenCenter();
					one.y -= 100;
					one.alpha = 0.5;
					one.cameras = [camOther];

					add(one);
					FlxTween.tween(one, {y: one.y + 100, alpha: 0, "scale.x": 1.05, "scale.y": 1.05}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeOut,
						onComplete: function(twn:FlxTween)
						{
							one.destroy();
						}
					});
				case 1:
					var gofun:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Exe/gofun'));
					gofun.scrollFactor.set();

					gofun.updateHitbox();

					gofun.screenCenter();
					gofun.y -= 100;
					gofun.alpha = 0.5;

					add(gofun);
					FlxTween.tween(gofun, {y: gofun.y + 100, alpha: 0, "scale.x": 1.05, "scale.y": 1.05}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							gofun.destroy();
						}
					});
			}

		}

	override function destroy() {
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];

		#if hscript
		if(FunkinLua.hscript != null) FunkinLua.hscript = null;
		#end

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		FlxAnimationController.globalSpeed = 1;
		FlxG.sound.music.pitch = 1;

		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var resetSpookyText:Bool = true;

	function resetSpookyTextManual():Void
	{
		trace('reset spooky');
		spookySteps = curStep;
		spookyRendered = true;
		tstatic.alpha = 0.5;
		FlxG.sound.play(Paths.sound('staticSound'));
		resetSpookyText = true;
	}

	function manuallymanuallyresetspookytextmanual()
	{
		remove(spookyText);
		spookyRendered = false;
		tstatic.alpha = 0;
	}

	function vScream():Void
		{
		
			trace('FUUUUUUCK');	
			FUCK.setPosition(dad.x,dad.y);
			remove(dadGroup);
			add(FUCK);	
			FUCK.animation.play('FFFFUU');	
			FlxG.camera.shake(0.009,3000);
		}
		
	function chantownanims():Void
		{
			if (curSong == 'Sage')
				{
					switch(curStep)
					{
						case 344 :xtan.animation.play("peakan");	
						case 366 :trv.animation.play("walkan");											
					}
				}
		}
	
	function addText(txtDuration:Float = 3):Void // hi
		{
			chatUsername = randomUsername[FlxG.random.int(0, randomUsername.length -1)] + ":";
			chatText = randomText[FlxG.random.int(0, randomText.length -1)];
		
			usernameTxt.color = FlxG.random.bool(50) ? 0x6495ED : FlxColor.RED;
			usernameTxt.text = chatUsername;
			chatTxt.text = chatText;
		
			usernameTxt.alpha = 1; 
			chatTxt.alpha = 1;
		
			new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					FlxTween.tween(usernameTxt, {alpha:0}, 0.5);
					FlxTween.tween(chatTxt, {alpha:0}, 0.5);
				});
		}

	var lastStepHit:Int = -1;

	function psyshockCalculate(startingValue:Int, endingValue:Int):Int 
		return Std.int(FlxMath.lerp(startingValue, endingValue, Conductor.songPosition / songLength));

	override function stepHit()
	{
		super.stepHit();
		if (tranceActive && !tranceNotActiveYet/* && (SONG.song.toLowerCase() != 'left-unchecked' || Conductor.songPosition > 20000*/)
			{
				if (psyshockCooldown <= 0)
				{
					psyshock();
					psyshockCooldown = psyshockCalculate(75, 40);
				}
				else
					psyshockCooldown--;
			}

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);

		if (SONG.song.toLowerCase()=='too slow dside')
			{
				if(curStep > 1088 && curStep < 1210)vocals.volume = 1;
				switch (curStep)
					{
						case 384:
							FlxTween.tween(this, {barSongLength: songLength, health: 1}, 3);
							FlxTween.tween(blackFade, {alpha: 1}, 0.45);
							FlxTween.tween(iconP2, {alpha: 0}, 0.45);
						case 447:
							urTooSlow.visible = true;
							fakeTooSlow.visible = false;
							if (ClientPrefs.camZooms)
							{
							supersuperZoomShit = true;
							}
						case 448:
							timeBar.createFilledBar(0x00D416E3, 0xFFD416E3);
							timeBar.updateBar();
							blackFade.alpha = 0;
							iconP2.alpha = 1;
							FlxG.camera.flash(FlxColor.WHITE, 1);
						case 1087:
							supersuperZoomShit = false;
						case 1088:
							defaultCamZoom = 1.4;
							FlxTween.tween(camHUD, {alpha: 0}, 0.45);
							FlxTween.tween(camNotes, {alpha: 0}, 0.45);
						case 1210:
							FlxTween.tween(camHUD, {alpha: 1}, 0.45);
							FlxTween.tween(camNotes, {alpha: 1}, 0.45);
						case 1344:
							defaultCamZoom = 0.8;
						case 1359:
							if (ClientPrefs.camZooms)
							{
							supersuperZoomShit = true;
							}
						case 1743:
							supersuperZoomShit = false;
						case 1760:
							if (ClientPrefs.camZooms)
								{
							defaultCamZoom = 1.0;
								}
						case 1765:
							if (ClientPrefs.camZooms)
								{
							defaultCamZoom = 1.2;
								}
						case 1769:
							if (ClientPrefs.camZooms)
								{
							defaultCamZoom = 1.5;
								}
						case 1776:
							if (ClientPrefs.camZooms)
								{
							defaultCamZoom = 1.7;
								}
					}
			}

		if (curSong == 'Faker')
			{
				switch (curStep)
				{
					case 787, 795, 902, 800, 811, 819, 823, 827, 832, 835, 839, 847:
						doStaticSign(0, false);
						camFollow.x += -35;
					case 768:
						FlxTween.tween(camHUD, {alpha: 0}, 1);
						FlxTween.tween(camNotes, {alpha: 0}, 1);
					case 801: // 800
						if (pendulumMode)
							tranceNotActiveYet = true;
						add(fakertransform);
						fakertransform.setPosition(dad.getGraphicMidpoint().x - 460, dad.getGraphicMidpoint().y - 700);
						fakertransform.x += 20;
						fakertransform.y += 128;
						fakertransform.alpha = 1;
						dad.visible = false;
						fakertransform.animation.play('1');
					case 824: // 824
						fakertransform.setPosition(dad.getGraphicMidpoint().x - 460, dad.getGraphicMidpoint().y - 700);
						fakertransform.x += -19;
						fakertransform.y += 138;
						fakertransform.animation.play('2');
					case 836: // 836
						fakertransform.setPosition(dad.getGraphicMidpoint().x - 460, dad.getGraphicMidpoint().y - 700);
						fakertransform.x += 76;
						fakertransform.y -= 110;
						fakertransform.animation.play('3');
					case 848: // 848
						fakertransform.setPosition(dad.getGraphicMidpoint().x - 460, dad.getGraphicMidpoint().y - 700);
						fakertransform.x += -110;
						fakertransform.y += 318;
						fakertransform.animation.play('4');
					case 884:
						camGame.alpha = 0;
				}
				if (curStep > 858 && curStep < 884)
					doStaticSign(0, false); // Honestly quite incredible
			}
		if (curSong == 'Chaos')
			{
				if (curStep == 16)
				{
					dad.playAnim('fastanim', true);
					dad.specialAnim = true;
					//	dad.nonanimated = true;
	
					FlxTween.tween(dad, {x: 61.15, y: -94.75}, 2, {ease: FlxEase.cubeOut});
				}
				else if (curStep == 1)
				{
					boyfriendGroup.add(boyfriend);
					boyfriend.scrollFactor.set(1.1, 1);
				}
				else if (curStep == 9)
				{
					dad.visible = true;
					FlxTween.tween(dad, {y: dad.y - 500}, 0.5, {ease: FlxEase.cubeOut});
				}
				else if (curStep == 64)
				{
					//	dad.nonanimated = false;
					dad.specialAnim = false;
					boyfriend.visible = true;
					camHUD.visible = true;
					camHUD.alpha = 0;
					camNotes.visible = true;
					camNotes.alpha = 0;
					cinematicBarsExe(false);
					FlxTween.tween(camHUD, {alpha: 1}, 0.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(camNotes, {alpha: 1}, 0.2, {ease: FlxEase.cubeOut});
				}
	
				switch (curStep)
				{
					case 380, 509, 637, 773, 1033, 1149, 1261, 1543, 1672, 1792, 1936:
						FlxTween.tween(dad, {x: 61.15, y: -94.75}, 0.2);
						dad.setPosition(61.15, -94.75);
				}
				switch (curStep)
				{
					case 256:
						laserThingy(true);
						canDodge = true;
					case 272:
						dodgething.visible = false;
					case 398, 527, 655, 783, 1039, 1167, 1295, 1551, 1679, 1807, 1951:
						/*dadGroup.remove(dad);*/
						/*var olddx = dad.x;
						var olddy = dad.y;
						dad = new Character(olddx, olddy, 'fleetway');
						dadGroup.add(dad);*/
						dad.specialAnim = false;
	
					case 1008:
						boyfriendGroup.remove(boyfriend);
						var oldbfx = boyfriend.x - 125;
						var oldbfy = boyfriend.y - 225;
						boyfriend = new Boyfriend(oldbfx, oldbfy, 'bf-super');
						boyfriendGroup.add(boyfriend);
	
						FlxG.camera.shake(0.02, 0.2);
						FlxG.camera.flash(FlxColor.YELLOW, 0.2);
	
						FlxG.sound.play(Paths.sound('SUPERBF'));
	
						boyfriend.scrollFactor.set(1.1, 1);
	
					case 1260, 1543, 1672, 1792, 1936:
						/*dadGroup.remove(dad);
						var olddx = dad.x;
						var olddy = dad.y;
						dad = new Character(olddx, olddy, 'fleetway-anims2');
						dadGroup.add(dad);*/
						switch (curStep)
						{
							case 1260:
								dad.playAnim('Ill show you', true);
								dad.specialAnim = true;
	
							case 1543:
								dad.playAnim('AAAA', true);
								dad.specialAnim = true;
	
							case 1672:
								dad.playAnim('Growl', true);
								dad.specialAnim = true;
	
							case 1792:
								dad.playAnim('Shut up', true);
								dad.specialAnim = true;
	
							case 1936:
								dad.playAnim('Right Alt', true);
								dad.specialAnim = true;
						}
					case 383, 512, 640, 776, 1036, 1152:
						/*dadGroup.remove(dad);
						var olddx = dad.x;
						var olddy = dad.y;
						dad = new Character(olddx, olddy, 'fleetway-anims3');
						dadGroup.add(dad);*/
						switch (curStep)
						{
							case 383:
								dad.playAnim('Step it up', true);
								dad.specialAnim = true;
	
							case 512:
								dad.playAnim('lmao', true);
								dad.specialAnim = true;
	
							case 640:
								dad.playAnim('fatphobia', true);
								dad.specialAnim = true;
	
							case 776:
								dad.playAnim('Finished', true);
								dad.specialAnim = true;
	
							case 1036:
								dad.playAnim('WHAT', true);
								dad.specialAnim = true;
	
							case 1152:
								dad.playAnim('Grrr', true);
								dad.specialAnim = true;
						}
				}
			}
		if (SONG.song.toLowerCase() == 'i am god') {
			switch (curStep)
			{
				case 674:
					if (pendulumMode)
						tranceNotActiveYet = true;
			}
		}
		if (curStage == 'fatality' && SONG.song.toLowerCase() == 'fatality')
			{
				switch (curStep)
				{
					case 255, 1983:
						fatalTransitionStatic();
					case 256:
						fatalTransistionThing();
					case 1151:
						dadGroup.remove(dad);
						var olddx = dad.x;
						var olddy = dad.y;
						dad = new Character(olddx, olddy, 'fatal-glitched');
						dadGroup.add(dad);
					case 1984:
						if (!pussyMode) {
							Xamount += 2;
							Yamount += 2;
						}
						fatalTransistionThingDos();
						if (!pussyMode) {
							windowX = Lib.application.window.x;
							windowY = Lib.application.window.y;
							IsWindowMoving2 = true;
						}
					case 2208:
						if (!pussyMode){
							IsWindowMoving = false;
							IsWindowMoving2 = false;
						}
					case 2230:
						if (!pussyMode)
							shakescreen();
						camGame.shake(0.02, 0.8);
						camHUD.shake(0.02, 0.8);
					case 2240:
						if (!pussyMode){
							IsWindowMoving = true;
							IsWindowMoving2 = false;
						}
					case 2528:
						if (!pussyMode){
							shakescreen();
							IsWindowMoving = true;
							IsWindowMoving2 = true;
							Yamount += 3;
							Xamount += 3;
						}
						camGame.shake(0.02, 2);
						camHUD.shake(0.02, 2);
					case 2530:
						if (!pussyMode)
							shakescreen();
					case 2535:
						if (!pussyMode)
							shakescreen();
					case 2540:
						if (!pussyMode)
							shakescreen();
					case 2545:
						if (!pussyMode)
							shakescreen();
					case 2550:
						if (!pussyMode)
							shakescreen();
					case 2555:
						if (!pussyMode)
							shakescreen();
					case 2560:
						if (!pussyMode){
							IsWindowMoving = false;
							IsWindowMoving2 = false;
							windowGoBack();
						}
				}
			}
		if (SONG.song.toLowerCase() == 'too slow encore')
			{
				switch (curStep)
				{
					case 384:
						camGame.alpha = 0;
					case 400:
						camGame.alpha = 1;
						defaultCamZoom = 0.9;
						FlxG.camera.flash(FlxColor.RED, 1);
					case 415:
						supersuperZoomShit = true;
					case 416:
						defaultCamZoom = 0.65;
					case 675:
						supersuperZoomShit = false;
					case 687:
						supersuperZoomShit = true;
					case 736:
						supersuperZoomShit = false;
					case 751:
						supersuperZoomShit = true;
					case 928:
						FlxG.camera.flash(FlxColor.RED, 0.7);
						FlxTween.tween(FlxG.camera, {zoom: 1.0}, 0.7);
						cinematicBarsExe(true);
						defaultCamZoom = 1.0;
						supersuperZoomShit = false;
						FlxTween.tween(camHUD, {alpha: 0}, 0.7);
						FlxTween.tween(camNotes, {alpha: 0}, 0.7);
						if (pendulumMode)
							tranceNotActiveYet = true;
					case 1039:
						cinematicBarsExe(false);
						FlxTween.tween(FlxG.camera, {zoom: 0.6}, 1.4);
						defaultCamZoom = 0.6;
						FlxTween.tween(camHUD, {alpha: 1}, 1.4);
						FlxTween.tween(camNotes, {alpha: 1}, 1.4);
						if (pendulumMode)
							tranceNotActiveYet = false;
					case 1055:
						supersuperZoomShit = true;
					case 1312:
						FlxG.camera.flash(FlxColor.RED, 0.7);
					case 1664:
						camFollow.x = gf.x + 300;
						isCameraOnForcedPos = true;
					case 1888:
						FlxG.camera.flash(FlxColor.RED, 0.7);
						supersuperZoomShit = false;
				}
			}
		if(SONG.song.toLowerCase()=='too slow' && CoolUtil.difficultyString() != 'OLD6K'){
			switch(curStep){
				case 765:
					FlxG.camera.flash(FlxColor.RED, 3);
				case 1305:
					FlxTween.tween(FlxG.camera, {zoom: 1.0}, 0.7);
					cinematicBarsExe(true);
					defaultCamZoom = 1.0;
					FlxTween.tween(camHUD, {alpha: 0}, 0.7);
					FlxTween.tween(camNotes, {alpha: 0}, 1.4);
					if (pendulumMode)
						tranceNotActiveYet = true;
				case 1424:
					cinematicBarsExe(false);
					FlxTween.tween(FlxG.camera, {zoom: 0.65}, 1.4);
					defaultCamZoom = 0.65;
					FlxTween.tween(camHUD, {alpha: 1}, 1.4);
					FlxTween.tween(camNotes, {alpha: 1}, 1.4);
					if (pendulumMode)
						tranceNotActiveYet = false;
			}
		}
		if (SONG.song.toLowerCase() == 'too slow' && CoolUtil.difficultyString() == 'OLD6K')
			{
				switch (curStep)
				{
					case 765:
						FlxG.camera.shake(0.005, 0.10);
						FlxG.camera.flash(FlxColor.RED, 4);
					case 1305:
						FlxTween.tween(camHUD, {alpha: 0}, 0.3);
						FlxTween.tween(camNotes, {alpha: 0}, 0.3);
						triggerEventNote('Play Animation', 'iamgod', 'Dad');
						if (pendulumMode)
							tranceNotActiveYet = true;
					case 1362:
						FlxG.camera.shake(0.002, 0.6);
						camHUD.camera.shake(0.002, 0.6);
					case 1432:
						doStaticSign(0);
						FlxTween.tween(camHUD, {alpha: 1}, 0.3);
						FlxTween.tween(camNotes, {alpha: 1}, 0.3);
						if (pendulumMode)
							tranceNotActiveYet = false;
					case 27:
						doStaticSign(0);
					case 130:
						doStaticSign(0);
					case 265:
						doStaticSign(0);
					case 450:
						doStaticSign(0);
					case 645:
						doStaticSign(0);
					case 800:
						doStaticSign(0);
					case 855:
						doStaticSign(0);
					case 889:
						doStaticSign(0);
					case 921:
						doSimpleJump();
					case 938:
						doStaticSign(0);
					case 981:
						doStaticSign(0);
					case 1030:
						doStaticSign(0);
					case 1065:
						doStaticSign(0);
					case 1105:
						doStaticSign(0);
					case 1123:
						doStaticSign(0);
					case 1178:
						doSimpleJump();
					case 1245:
						doStaticSign(0);
					case 1337:
						doSimpleJump();
					case 1345:
						doStaticSign(0);
					case 1454:
						doStaticSign(0);
					case 1495:
						doStaticSign(0);
					case 1521:
						doStaticSign(0);
					case 1558:
						doStaticSign(0);
					case 1578:
						doStaticSign(0);
					case 1599:
						doStaticSign(0);
					case 1618:
						doStaticSign(0);
					case 1647:
						doStaticSign(0);
					case 1657:
						doStaticSign(0);
					case 1692:
						doStaticSign(0);
					case 1713:
						doStaticSign(0);
					case 1723:
						triggerEventNote('sonicspook', '', '');
					case 1738:
						doStaticSign(0);
					case 1747:
						doStaticSign(0);
					case 1761:
						doStaticSign(0);
					case 1785:
						doStaticSign(0);
					case 1806:
						doStaticSign(0);
					case 1816:
						doStaticSign(0);
					case 1832:
						doStaticSign(0);
					case 1849:
						doStaticSign(0);
					case 1868:
						doStaticSign(0);
					case 1887:
						doStaticSign(0);
					case 1909:
						doStaticSign(0);
				}
			}
		if(curSong == 'endless'){
			switch(curStep){
				case 1:
					timeBar.createFilledBar(0xFF000000, 0xFF5f41a1);
					timeBar.updateBar();
				case 886:
					FlxTween.tween(camHUD, {alpha: 0}, 0.5);
					FlxTween.tween(camNotes, {alpha: 0}, 0.5);
					if (pendulumMode)
						tranceNotActiveYet = true;
				case 900:
					removeStatics();
					generateStaticArrows(0);
					generateStaticArrows(1);
					FlxTween.tween(camHUD, {alpha: 1}, 0.5);
					FlxTween.tween(camNotes, {alpha: 1}, 0.5);
					if (pendulumMode)
						tranceNotActiveYet = false;
			}
		}
		if(curSong == 'endless-old'){
			switch(curStep){
				case 924:
					removeStatics();
					generateStaticArrows(0);
					generateStaticArrows(1);
			}
		}
		if (SONG.song.toLowerCase() == 'acceptance')
			{
				if (curStep == 128 || curStep == 448 || curStep == 1008 || curStep == 1456)
				{
				
				if (!pussyMode)		
				{
				if (ClientPrefs.downScroll)
				{
					var DrawingMom:FlxSprite = new FlxSprite(570, 180);
					DrawingMom.frames = Paths.getSparrowAtlas('isaac/chest/DrawingMom','shared');
					DrawingMom.animation.addByPrefix('mom','mom',24,false);
					DrawingMom.animation.play('mom');
					DrawingMom.antialiasing = true;
					DrawingMom.setGraphicSize(Std.int(DrawingMom.width * 0.9));
					DrawingMom.cameras = [camOther];
					add(DrawingMom);
					FlxG.sound.play(Paths.sound('whoop'));
					DrawingMom.animation.finishCallback = function(name:String) {
						remove(DrawingMom);	
				}
				}
				else
				{
					var DrawingMom:FlxSprite = new FlxSprite(570, 300);
					DrawingMom.frames = Paths.getSparrowAtlas('isaac/chest/DrawingMom','shared');
					DrawingMom.animation.addByPrefix('mom','mom',24,false);
					DrawingMom.animation.play('mom');
					DrawingMom.antialiasing = true;
					DrawingMom.setGraphicSize(Std.int(DrawingMom.width * 0.9));
					DrawingMom.cameras = [camOther];
					add(DrawingMom);
					FlxG.sound.play(Paths.sound('whoop'));
					DrawingMom.animation.finishCallback = function(name:String) {
						remove(DrawingMom);		
						
				}
				}
				}
				}
	
				if (curStep == 160 || curStep == 512 || curStep == 880 || curStep == 1424)
				{
				if (!pussyMode)		
				{
				if (ClientPrefs.downScroll)
				{
					var DrawingDemon:FlxSprite = new FlxSprite(780, 10);
					DrawingDemon.frames = Paths.getSparrowAtlas('isaac/chest/DrawingDemon','shared');
					DrawingDemon.animation.addByPrefix('demon','demon',24,false);
					DrawingDemon.animation.play('demon');
					DrawingDemon.antialiasing = true;
					DrawingDemon.setGraphicSize(Std.int(DrawingDemon.width * 0.9));
					DrawingDemon.cameras = [camOther];
					add(DrawingDemon);
					FlxG.sound.play(Paths.sound('whoop'));
					DrawingDemon.animation.finishCallback = function(name:String) {
						remove(DrawingDemon);		
						
				}
				}
				else
				{
					var DrawingDemon:FlxSprite = new FlxSprite(780, 130);
					DrawingDemon.frames = Paths.getSparrowAtlas('isaac/chest/DrawingDemon','shared');
					DrawingDemon.animation.addByPrefix('demon','demon',24,false);
					DrawingDemon.animation.play('demon');
					DrawingDemon.antialiasing = true;
					DrawingDemon.setGraphicSize(Std.int(DrawingDemon.width * 0.9));
					DrawingDemon.cameras = [camOther];
					add(DrawingDemon);
					FlxG.sound.play(Paths.sound('whoop'));
					DrawingDemon.animation.finishCallback = function(name:String) {
						remove(DrawingDemon);		
						
				}
				}
				}
				}
				if (curStep == 320 || curStep == 656 || curStep == 1296 || curStep == 1552)
				{
					
				if (!pussyMode)		
				{
				if (ClientPrefs.downScroll)
				{
					var DrawingDemon2:FlxSprite = new FlxSprite(700, 130);
					DrawingDemon2.frames = Paths.getSparrowAtlas('isaac/chest/DrawingDemon2','shared');
					DrawingDemon2.animation.addByPrefix('demon2','demon2',24,false);
					DrawingDemon2.animation.play('demon2');
					DrawingDemon2.antialiasing = true;
					DrawingDemon2.setGraphicSize(Std.int(DrawingDemon2.width * 0.9));
					DrawingDemon2.cameras = [camOther];
					add(DrawingDemon2);
					FlxG.sound.play(Paths.sound('whoop'));
					DrawingDemon2.animation.finishCallback = function(name:String) {
						remove(DrawingDemon2);			
						
				}
				}
				else
				{
					
					var DrawingDemon2:FlxSprite = new FlxSprite(700, 250);
					DrawingDemon2.frames = Paths.getSparrowAtlas('isaac/chest/DrawingDemon2','shared');
					DrawingDemon2.animation.addByPrefix('demon2','demon2',24,false);
					DrawingDemon2.animation.play('demon2');
					DrawingDemon2.antialiasing = true;
					DrawingDemon2.setGraphicSize(Std.int(DrawingDemon2.width * 0.9));
					DrawingDemon2.cameras = [camOther];
					add(DrawingDemon2);
					FlxG.sound.play(Paths.sound('whoop'));
					DrawingDemon2.animation.finishCallback = function(name:String) {
						remove(DrawingDemon2);			
						
				}
				}
				}
				}
				
				
				if (curStep == 1808)
				{
					FlxG.camera.flash(0xFFfffae8, 5);
					FlxTween.tween(camHUD, {alpha: 0}, 2.8, {onComplete: function(t){
						if (pendulumMode)
							tranceNotActiveYet = true;
					}});
					FlxTween.tween(camNotes, {alpha: 0}, 2.8);
					dadGroup.visible = false;
					chestidle.visible = false;
					FlxG.sound.music.volume = 1;
					vocals.volume = 1;
					end.animation.play('end');
					end.visible = true;
					FlxTween.tween(FlxG.camera, {zoom: 0.50}, 6);
					canPause = false;
					defaultCamZoom = 0.55;
					
					songending = true;
				}
	
				if (curStep == 1872)
				{
					camGame.visible = false;
				}
				
				
				if (curStep == 1040 || curStep == 1104 || curStep == 1168 || curStep == 1232 || curStep == 1552 || curStep == 1584 || curStep == 1616 || curStep == 1648 || curStep == 1680 || curStep == 1712 || curStep == 1744)
				{
					FlxTween.tween(FlxG.camera, {zoom: 0.70});
					defaultCamZoom = 0.70;
				}
				//zoom when blue baby's turns start 
				
				if (curStep == 1072 || curStep == 1136 || curStep == 1200 || curStep == 1568 || curStep == 1600 || curStep == 1632 || curStep == 1664 || curStep == 1696 || curStep == 1728 || curStep == 1760)
				{
					FlxTween.tween(FlxG.camera, {zoom: 0.65});
					defaultCamZoom = 0.65;
				}
				//zoom out a bit when bf's turns start
				
				if (curStep == 1264 || curStep == 1776)
				{
					FlxTween.tween(FlxG.camera, {zoom: 0.60});
					defaultCamZoom = 0.60;
				}
				
	
			}

		if (SONG.song.toLowerCase() == 'delirious')
			{
				if (curStep == 288)
				{
					var effect = new MosaicEffect();
					effectTween = FlxTween.num(MosaicEffect.DEFAULT_STRENGTH, 8, 1, {type: PINGPONG}, function(v)
					{
						effect.setStrength(v, v);
					});
					
					dadGroup.shader = effect.shader;
					staticlol.alpha = 1;
					if (ClientPrefs.flashing)
						FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxG.sound.play(Paths.sound('death_card_mix'));
					if (!pussyMode)
						health = 0.01;
					portal.alpha = 1;
					FlxTween.tween(FlxG.camera, {zoom: 0.60});
					defaultCamZoom = 0.60;
				}
					
				
				if (curStep == 1344)
				{
					staticlol.alpha = 1;
					if (ClientPrefs.flashing)
						FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxG.sound.play(Paths.sound('death_card_mix'));
					if (!pussyMode)
						health = 0.01;
					FlxTween.tween(FlxG.camera, {zoom: 0.60});
					defaultCamZoom = 0.60;
				}
				if (curStep == 1600)
				{
					staticlol.alpha = 1;
				}
	
				if (curStep == 1952)
				{
					staticlol.alpha = 1;
					if (ClientPrefs.flashing)
						FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxG.sound.play(Paths.sound('death_card_mix'));
					if (!pussyMode)
						health = 0.01;
					FlxTween.tween(FlxG.camera, {zoom: 0.60});
					defaultCamZoom = 0.60;
				}
				if (curStep == 272 || curStep == 1328 || curStep == 1920)
				{
					FlxTween.tween(FlxG.camera, {zoom: 0.70});
					defaultCamZoom = 0.70;
					staticlol.alpha = 1;
					staticlol.visible = true;
				}
				
				if (curStep == 800 || curStep == 1664 || curStep == 1792)
				{
					if (ClientPrefs.flashing)
						FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxG.sound.play(Paths.sound('death_card_mix'));
					staticlol.alpha = 1;
					basementvoid.visible = true;
					chestvoid.visible = false;
				}
				
				if (curStep == 928)
				{
					if (ClientPrefs.flashing)
						FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxG.sound.play(Paths.sound('death_card_mix'));
					staticlol.alpha = 1;
					drvoid.visible = true;
					portal.alpha = 0.5;
					basementvoid.visible = false;
				}
				
				if (curStep == 1056)
				{
					if (ClientPrefs.flashing)
						FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxG.sound.play(Paths.sound('death_card_mix'));
					staticlol.alpha = 1;
					drvoid.visible = false;
					basementvoid.visible = true;
					portal.alpha = 1;
				}
				
				if (curStep == 1184 || curStep == 1600 || curStep == 1728)
				{
					if (ClientPrefs.flashing)
						FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxG.sound.play(Paths.sound('death_card_mix'));
					staticlol.alpha = 1;
					chestvoid.visible = true;
					basementvoid.visible = false;
				}
				
				if (curStep == 1344 || curStep == 1856)
				{
					if (ClientPrefs.flashing)
						FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxG.sound.play(Paths.sound('death_card_mix'));
					staticlol.alpha = 1;
					chestvoid.visible = false;
					basementvoid.visible = false;
					drvoid.visible = false;
				}
				
				if (curStep == 1984)
				{
					if (ClientPrefs.flashing)
						FlxG.camera.flash(FlxColor.WHITE, 5);
					dadGroup.visible = false;
					staticlol.alpha = 1;
				}
			}

		// EX TRICKY HARD CODED EVENTS

				if (curSong.toLowerCase() == 'expurgation' && !pussyMode)
					{
						switch(curStep)
						{
							case 384:
								doStopSign(0);
							case 511:
								doStopSign(2);
								doStopSign(0);
							case 610:
								doStopSign(3);
							case 720:
								doStopSign(2);
							case 991:
								doStopSign(3);
							case 1184:
								doStopSign(2);
							case 1218:
								doStopSign(0);
							case 1235:
								doStopSign(0, true);
							case 1200:
								doStopSign(3);
							case 1328:
								doStopSign(0, true);
								doStopSign(2);
							case 1439:
								doStopSign(3, true);
							case 1567:
								doStopSign(0);
							case 1584:
								doStopSign(0, true);
							case 1600:
								doStopSign(2);
							case 1706:
								doStopSign(3);
							case 1917:
								doStopSign(0);
							case 1923:
								doStopSign(0, true);
							case 1927:
								doStopSign(0);
							case 1932:
								doStopSign(0, true);
							case 2032:
								doStopSign(2);
								doStopSign(0);
							case 2036:
								doStopSign(0, true);
							case 2144:
								dad.playAnim('idle', true);
							case 2162:
								doStopSign(2);
								doStopSign(3);
							case 2193:
								doStopSign(0);
							case 2202:
								doStopSign(0,true);
							case 2239:
								doStopSign(2,true);
							case 2258:
								doStopSign(0, true);
							case 2304:
								doStopSign(0, true);
								doStopSign(0);	
							case 2326:
								doStopSign(0, true);
							case 2336:
								doStopSign(3);
							case 2447:
								doStopSign(2);
								doStopSign(0, true);
								doStopSign(0);	
							case 2480:
								doStopSign(0, true);
								doStopSign(0);	
							case 2512:
								doStopSign(2);
								doStopSign(0, true);
								doStopSign(0);
							case 2544:
								doStopSign(0, true);
								doStopSign(0);	
							case 2575:
								doStopSign(2);
								doStopSign(0, true);
								doStopSign(0);
							case 2608:
								doStopSign(0, true);
								doStopSign(0);	
							case 2604:
								doStopSign(0, true);
							case 2655:
								doGremlin(20,13,true);
						}
						lastStepHit = curStep;
					}
					if (spookyRendered && spookySteps + 3 < curStep)
						{
							if (resetSpookyText)
							{
								remove(spookyText);
								spookyRendered = false;
							}
							tstatic.alpha = 0;
							if (curStage == 'auditorHell')
								tstatic.alpha = 0.1;
						}
					if (!inCutscene)
						{
							switch (curSong.toLowerCase())
							{
								case 'honorbound':
									if (!pussyMode){
										if (health >= 0.1)
											health += -0.005;
									}
							}
						}

		switch (SONG.song.toLowerCase())
		{
			case 'honorbound':
				switch (curStep)
				{
					case 1264:
						songIsWeird = true;
						camZooming = false;
						tweenCam(1.3, 1);
						defaultCamZoom = 1.3;
					case 1280:
						soldierShake = true;
					case 1536:
						songIsWeird = false;
						soldierShake = false;
						camZooming = true;
						tweenCam(0.9, 1);
						defaultCamZoom = 0.9;
				}
			case 'no villains':
				switch (curStep)
				{
					case 1664:
						FlxTween.tween(FlxG.camera, {zoom: 1.6}, 1.5, {ease: FlxEase.quadInOut});
						defaultCamZoom = 1.6;
					case 1920:
						FlxTween.tween(FlxG.camera, {zoom: 1}, 1.5, {ease: FlxEase.quadInOut});
						defaultCamZoom = 1;
				}
			case 'no heroes':
				switch (curStep)
				{
					case 1440:
						FlxTween.tween(FlxG.camera, {zoom: 1.6}, 1.5, {ease: FlxEase.quadInOut});
						defaultCamZoom = 1.6;
					case 1696:
						FlxTween.tween(FlxG.camera, {zoom: 1}, 1.5, {ease: FlxEase.quadInOut});
						defaultCamZoom = 1;
				}
			case 'foolhardy':
				switch (curStep)
				{
					case 2427:
					FlxTween.tween(dadGroup, {alpha: 0.8}, 0.4);
					case 2943:
					FlxTween.tween(dadGroup, {alpha: 0}, 0.4);
				}
			case 'infitrigger':
				if (!pussyMode){
					switch (curStep)
					{
						case 1797:
							for (i in 0...6)
								FlxTween.tween(playerStrums.members[i], {alpha: 0}, 0.5, {ease: FlxEase.quartInOut});
						case 1802:
							FlxTween.tween(playerStrums.members[0], {x: playerStrums.members[5].x}, 0.000001, {ease: FlxEase.quartInOut});
							FlxTween.tween(playerStrums.members[1], {x: playerStrums.members[4].x}, 0.000001, {ease: FlxEase.quartInOut});
							FlxTween.tween(playerStrums.members[2], {x: playerStrums.members[3].x}, 0.000001, {ease: FlxEase.quartInOut});
							FlxTween.tween(playerStrums.members[3], {x: playerStrums.members[2].x}, 0.000001, {ease: FlxEase.quartInOut});
							FlxTween.tween(playerStrums.members[4], {x: playerStrums.members[1].x}, 0.000001, {ease: FlxEase.quartInOut});
							FlxTween.tween(playerStrums.members[5], {x: playerStrums.members[0].x}, 0.000001, {ease: FlxEase.quartInOut});
	
							FlxTween.tween(playerStrums.members[0], {angle: playerStrums.members[0].angle + 180}, 0.000001, {ease: FlxEase.quartInOut});
							FlxTween.tween(playerStrums.members[1], {angle: playerStrums.members[1].angle + 180}, 0.000001, {ease: FlxEase.quartInOut});
							FlxTween.tween(playerStrums.members[2], {angle: playerStrums.members[2].angle + 180}, 0.000001, {ease: FlxEase.quartInOut});
							FlxTween.tween(playerStrums.members[3], {angle: playerStrums.members[3].angle + 180}, 0.000001, {ease: FlxEase.quartInOut});
							FlxTween.tween(playerStrums.members[4], {angle: playerStrums.members[4].angle + 180}, 0.000001, {ease: FlxEase.quartInOut});
							FlxTween.tween(playerStrums.members[5], {angle: playerStrums.members[5].angle + 180}, 0.000001, {ease: FlxEase.quartInOut});
						case 1820:
							for (i in 0...6)
								FlxTween.tween(playerStrums.members[i], {alpha: 1}, 0.5, {ease: FlxEase.quartInOut});
					}
				}
			case 'eyelander':
				switch (curStep)
					{
						case 863:
							if (!drunkGame)
								weee = true;
						case 1664:
							if (!drunkGame){
								normal = true;
								weee = false;
							}
					}
			case 'recursed':
				switch (curStep)
				{
					case 320:
						defaultCamZoom = 0.6;
						cinematicBars(((Conductor.stepCrochet * 30) / 1000), 400);
					case 352:
						defaultCamZoom = 0.4;
						if (ClientPrefs.flashing)
							FlxG.camera.flash();
					case 864:
						if (ClientPrefs.flashing)
							FlxG.camera.flash();
						charBackdrop.loadGraphic(Paths.image('recursed/bambiScroll'));
						freeplayBG.loadGraphic('recursed/backgrounds/sk0rbias');
						freeplayBG.color = FlxColor.multiply(0xFF00B515, FlxColor.fromRGB(44, 44, 44));
						initAlphabet(bambiSongs);
					case 1248:
						defaultCamZoom = 0.6;
						if (ClientPrefs.flashing)
							FlxG.camera.flash();
						charBackdrop.loadGraphic(Paths.image('recursed/tristanScroll'));
						freeplayBG.loadGraphic('recursed/backgrounds/ricee_png');
						freeplayBG.color = FlxColor.multiply(0xFFFF0000, FlxColor.fromRGB(44, 44, 44));
						initAlphabet(tristanSongs);
					case 1632:
						defaultCamZoom = 0.4;
						if (ClientPrefs.flashing)
							FlxG.camera.flash();
				}
			case 'lost cause':
				switch (curStep)
				{
					case 1:
						iconP2.changeIcon('bfhypno');
						healthBar.createFilledBar(FlxColor.fromRGB(49, 176, 209),FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
						healthBar.updateBar();
					case 304:
						camZooming = false;
						if (!pussyMode)
							tranceNotActiveYet = false;
						trace('she stand');
						hypnoEntrance.visible = true;
						hypnoEntrance.animation.play('Entrance instance');	
						hypnoEntrance.animation.finishCallback = function(name:String) {
								remove(hypnoEntrance);
								dadGroup.visible = true;
							}
						
						FlxTween.tween(FlxG.camera, {zoom: 0.52}, 0.3);	
						FlxTween.tween(camHUD, {alpha: 0}, 0.2);	
						FlxTween.tween(camNotes, {alpha: 0}, 0.2);
			
						new FlxTimer().start(1.5, function(tmr:FlxTimer)
							{				
								healthBarFlipped = true;
								if (!pussyMode)	
									pendulum.alpha = 1;
								camZooming = true;						
								FlxTween.tween(camHUD, {alpha: 1}, 0.2);	
								FlxTween.tween(camNotes, {alpha: 1}, 0.2);
								if (!ClientPrefs.middleScroll){
									for (i in 0...opponentStrums.length)
										opponentStrums.members[i].x -= 620;
								}
								iconP2.changeIcon('gfhypno');
								iconP1.alpha = 0;
								reloadHealthBarColors();	
								healthBarBG.sprTracker = flippedHealthBar;
								flippedHealthBar.alpha = 1;
								healthBar.alpha = 0;
							});
			
						new FlxTimer().start(2, function(tmr:FlxTimer)
							{						
								boyfriend.playAnim('bfdrop', true);
								boyfriend.specialAnim = true;					
							});
			
						// lol
						new FlxTimer().start(4.35, function(tmr:FlxTimer){		
								if(boyfriend.curCharacter != 'gf-stand') {
									if(!boyfriendMap.exists('gf-stand')) {
										addCharacterToList('gf-stand', 0);
									}
					
									var lastAlpha:Float = boyfriend.alpha;
									boyfriend.alpha = 0.00001;
									boyfriend = boyfriendMap.get('gf-stand');
									boyfriend.alpha = lastAlpha;
									iconP1.changeIcon(boyfriend.healthIcon);
								}
			
								var bfdeadlol:FlxSprite = new FlxSprite().loadGraphic(Paths.image('characters/bf/dead_ass_bitch_LMAOOOO'));
								bfdeadlol.setGraphicSize(Std.int(bfdeadlol.width * 0.72));
								bfdeadlol.x -= 95;
								bfdeadlol.y += 935;
								bfdeadlol.antialiasing = true;
								add(bfdeadlol);
						});
					case 2128:
						dadGroup.visible = false;
						hypnoJumpscare.visible = true;
						hypnoJumpscare.animation.play('ending');
				}
		}
	}

	public static var missLimited:Bool = false;
	public static var missLimitCount:Int = 5;

	public function missLimitManager()
	{
		if (missLimited)
		{
			if (curStage == 'defeatold'){
				if (songMisses > 0)
					health = 0;
			}
			else{
				healthBar.visible = false;
				healthBarBG.visible = false;
				health = 1;
				if (songMisses > missLimitCount)
					health = 0;
			}
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	function shakescreen()
		{
			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				Lib.application.window.move(Lib.application.window.x + FlxG.random.int(-10, 10), Lib.application.window.y + FlxG.random.int(-8, 8));
			}, 50);
		}

	function doPopup(type:Int)
	{
		var popup = new FatalPopup(0, 0, type);
		var popuppos:Array<Int> = [errorRandom.int(0, Std.int(FlxG.width - popup.width)), errorRandom.int(0, Std.int(FlxG.height - popup.height))];
		popup.x = popuppos[0];
		popup.y = popuppos[1];
		popup.cameras = [camOther];
		add(popup);
	}

	function managePopups(){
		if(FlxG.mouse.justPressed){
			trace("click :)");
			for(idx in 0...FatalPopup.popups.length){
				var realIdx = (FatalPopup.popups.length - 1) - idx;
				var popup = FatalPopup.popups[realIdx];
				var hitShit:Bool=false;
				for(camera in popup.cameras){
					@:privateAccess
					var hitOK = popup.clickDetector.overlapsPoint(FlxG.mouse.getWorldPosition(camera, popup.clickDetector._point), true, camera);
					if (hitOK){
						popup.close();
						hitShit=true;
						break;
					}
				}
				if(hitShit)break;
			}
		}
	}

	function fatalTransistionThing()
	{
		base.visible = false;
		domain.visible = true;
		domain2.visible = true;
	}

	function fatalTransitionStatic()
	{
		// placeholder for now, waiting for cool static B) (cool static added)
		var daStatic = new BGSprite('Exe/statix', 0, 0, 1.0, 1.0, ['statixx'], true);
		daStatic.screenCenter();
		daStatic.setGraphicSize(FlxG.width, FlxG.height);
		daStatic.cameras = [camNotes];
		add(daStatic);
		FlxG.sound.play(Paths.sound('staticBUZZ'));
		new FlxTimer().start(0.20, function(tmr:FlxTimer)
		{
			remove(daStatic);
		});
	}

	function fatalTransistionThingDos()
	{
		// removeStatics();
		// generateStaticArrows(0);
		// generateStaticArrows(1);

		if (!ClientPrefs.middleScroll)
			{
				playerStrums.forEach(function(spr:FlxSprite)
					{
						spr.x -= 322;
					});
					opponentStrums.forEach(function(spr:FlxSprite)
					{
						spr.x += 10000;
					});
			}

		while(FatalPopup.popups.length>0)
			FatalPopup.popups[0].close();

		domain.visible = false;
		domain2.visible = false;
		trueFatal.visible = true;

		dadGroup.remove(dad);
		boyfriendGroup.remove(boyfriend);
		var olddx = dad.x + 740;
		var olddy = dad.y - 240;
		dad = new Character(olddx, olddy, 'true-fatal');
		iconP2.changeIcon(dad.healthIcon);

		var oldbfx = boyfriend.x - 250;
		var oldbfy = boyfriend.y + 135;
		boyfriend = new Boyfriend(oldbfx, oldbfy, 'bf-fatal-small');

		dadGroup.add(dad);
		boyfriendGroup.add(boyfriend);
	}

	var lastBeatHit:Int = -1;
	var beatOfFuck:Int = 0;

	override function beatHit()
	{
		super.beatHit();

		if (curBeat % 4 == 0 && SONG.song.toLowerCase() == 'recursed')
			{
				freeplayBG.alpha = 0.8;
				charBackdrop.alpha = 0.8;
	
				for (char in alphaCharacters)
				{
					for (letter in char)
					{
						letter.alpha = 0.4;
					}
				}
			}

		if (curBeat % 25 == 0)
			{
				switch (curSong)
				{
					case 'Honorbound'|'Strongmann'|'Eyelander':
						addText();
				}
				
			}

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curSong.toLowerCase() == 'infitrigger')
			{
				switch(curBeat)
				{
					case 446 :canScream();
					case 449 :if (!pussyMode)doFlip();
					
				}				
			}

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}
		if (curBeat % mom.danceEveryNumBeats == 0 && mom.animation.curAnim != null && !mom.animation.curAnim.name.startsWith('sing') && !mom.stunned)
		{
			mom.dance();
		}

		switch (curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});

			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
					phillyWindow.color = phillyLightsColors[curLight];
					phillyWindow.alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
			case 'zardy':
				zardyBackground.animation.play('Maze');
			case 'bonus':
				bonusanims();
			case 'defeat':
				if (curBeat % 4 == 0)
				{
					defeatthing.animation.play('bop', true);
				}
			case 'plantroom':
				if (curBeat % 2 == 1 && pinkCanPulse)
				{
					pinkVignette.alpha = 1;
					if(vignetteTween != null) vignetteTween.cancel();
					vignetteTween = FlxTween.tween(pinkVignette, {alpha: 0.2}, 1.2, {ease: FlxEase.sineOut});

					if(whiteTween != null) whiteTween.cancel();
					heartColorShader.amount = 0.5;
					whiteTween = FlxTween.tween(heartColorShader, {amount: 0}, 0.75, {ease: FlxEase.sineOut});
				}
				if (curBeat % 2 == 0)
				{
					cyanmira.animation.play('bop', true);
					greymira.animation.play('bop', true);
					oramira.animation.play('bop', true);
				}
				if (curBeat % 1 == 0)
				{
					bluemira.animation.play('bop', true);
				}
			case 'pretender':
				if(curBeat % 2 == 0){	
					bluemira.animation.play('bop');
				}
				if (curBeat % 1 == 0)
				{
					gfDeadPretender.animation.play('bop');
				}
			case 'reactor2':
				if (curBeat % 4 == 0)
				{
					toogusorange.animation.play('bop', true);
					toogusblue.animation.play('bop', true);
					tooguswhite.animation.play('bop', true);
				}
			case 'warehouse':
				leftblades.animation.play('spin', true);
				rightblades.animation.play('spin', true);

				if(curBeat == 2){
					ziffyStart.visible = true;
					ziffyStart.animation.play("idle", true);
					ziffyStart.screenCenter(XY);
					ziffyStart.y -= 120;
				}

				if(curBeat == 24){
					ziffyStart.visible = false;
					ziffyStart.destroy();
				}

				if(curBeat == 32){
					FlxTween.tween(startDark, {alpha: 0}, (Conductor.crochet*28)/1000, {onComplete: function(t){
						startDark.destroy();
					}});
					if (pendulumMode)
						tranceNotActiveYet = false;
						pendulum.alpha = 1;
				}

				if(curBeat == 62){
					FlxG.sound.play(Paths.sound('ziffSaw'), 1);
					FlxTween.tween(leftblades, {y: leftblades.y + 300}, (Conductor.crochet*4)/1000, {ease: FlxEase.quintOut});
					FlxTween.tween(rightblades, {y: rightblades.y + 300}, (Conductor.crochet*4)/1000, {ease: FlxEase.quintOut});
				}

				if(curBeat == 256){
					camZooming = false; 	

					ROZEBUD_ILOVEROZEBUD_HEISAWESOME.visible = true;
					ROZEBUD_ILOVEROZEBUD_HEISAWESOME.animation.play("thing");
					ROZEBUD_ILOVEROZEBUD_HEISAWESOME.animation.finishCallback = function(name){
						ROZEBUD_ILOVEROZEBUD_HEISAWESOME.destroy();
					}
					FlxTween.tween(camGame.camera, {zoom: defaultCamZoom - 0.5}, 4*Conductor.crochet/1000, {ease: FlxEase.quintOut});
				}

				if(curBeat == 271){
					
				}

				if(curBeat == 272){
					camZooming = true;
					FlxTween.tween(instance, {health: 0.05, bladeDistance: 150}, 4*Conductor.crochet/1000, {ease: FlxEase.quartOut});
				}

				if(curBeat == 32){
					task = new TaskSong(0, 200, SONG.song.toLowerCase().replace(' ', '-'), 1);
					task.cameras = [camOther];
					add(task);
					task.start();
				}
				else if(curBeat == 128){
					task = new TaskSong(0, 200, SONG.song.toLowerCase().replace(' ', '-'), 2);
					task.cameras = [camOther];
					add(task);
					task.start();
				}
				else if(curBeat == 160){
					task = new TaskSong(0, 200, SONG.song.toLowerCase().replace(' ', '-'), 3);
					task.cameras = [camOther];
					add(task);
					task.start();
				}
				else if(curBeat == 224){
					task = new TaskSong(0, 200, SONG.song.toLowerCase().replace(' ', '-'), 4);
					task.cameras = [camOther];
					add(task);
					task.start();
				}
				else if(curBeat == 256){
					task = new TaskSong(0, 200, SONG.song.toLowerCase().replace(' ', '-'), 5);
					task.cameras = [camOther];
					add(task);
					task.start();
				}
				else if(curBeat == 272){
					task = new TaskSong(0, 200, SONG.song.toLowerCase().replace(' ', '-'), 6);
					task.cameras = [camOther];
					add(task);
					task.start();
				}
				else if(curBeat == 336){
					task = new TaskSong(0, 200, SONG.song.toLowerCase().replace(' ', '-'), 7);
					task.cameras = [camOther];
					add(task);
					task.start();
				}
			case 'chest':
				GFdisappointed.animation.play('dance', true);
			case 'LordXStage':
				if(!ClientPrefs.lowQuality){
					hands.animation.play('handss', true);
					tree.animation.play('treeanimation', true);
					eyeflower.animation.play('animatedeye', true);
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}

		if (curBeat % 1 == 0 && supersuperZoomShit)
			{
				FlxG.camera.zoom += 0.06;
				camHUD.zoom += 0.08;
				camNotes.zoom += 0.08;
			}

		if (curStage == 'auditorHell')
			{
				if (curBeat % 8 == 4 && beatOfFuck != curBeat)
				{
					beatOfFuck = curBeat;
					doClone(FlxG.random.int(0,1));
				}
			}

		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);

		if (camZooming && curSong.toLowerCase() == 'sage' && curStep >= 1408)
			{
				FlxG.camera.zoom = 1.01;				
			}

		if (curSong == 'Sage')
			{			
				switch (curBeat)
				{
					case 415 : vScream();
				}
			}
		switch (curStage)
			{
				case 'chantown':
					if(!ClientPrefs.lowQuality){
						chinkMoot.forEach(function(dancer:FakeMoot)
							{
								dancer.dance();
							});}
						chantownanims();
			}
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				if (curSong.toLowerCase() != 'recursed')
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
			{
				switch(curStage.toLowerCase()){
					case 'idk':
						// a
					case 'cargo':
						FlxG.camera.zoom += 0.015;
						camHUD.zoom += 0.015;
						camNotes.zoom += 0.015;
					default:
						FlxG.camera.zoom += 0.015 * camZoomingMult;
						camHUD.zoom += 0.03 * camZoomingMult;
						camNotes.zoom += 0.03 * camZoomingMult;
				}
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if(!bool && ret != 0) {
				returnVal = cast ret;
			}
		}
		#end
		//trace(event, returnVal);
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	function removeStatics()
		{
			playerStrums.forEach(function(todel:StrumNote)
			{
				playerStrums.remove(todel);
				todel.destroy();
			});
			opponentStrums.forEach(function(todel:StrumNote)
			{
				opponentStrums.remove(todel);
				todel.destroy();
			});
			strumLineNotes.forEach(function(todel:StrumNote)
			{
				strumLineNotes.remove(todel);
				todel.destroy();
			});
		}

	function laserThingy(first:Bool)
	{
		var s:Int = 0;

		// FlxG.sound.play(Paths.sound('laser'));


		new FlxTimer().start(0, function(a:FlxTimer)
		{
			s++;
			//warning.visible = true;
			dodgething.visible = true;

			if (s < 4)
			{
				a.reset(0.32);
			}
			// else
			// {
			// 	remove(warning);
			// }
			if (s == 3)
			{
				// triggerEventNote('Change Character', 'Dad', 'fleetwaylaser');
				// triggerEventNote('Play Animation', 'LaserBlast', 'Dad');

				dad.animation.finishCallback = function(a:String)
				{
					if(a == 'laserblast'){
						/*dadGroup.remove(dad);
						var olddx = dad.x;
						var olddy = dad.y;
						dad = new Character(olddx, olddy, 'fleetway');
						dadGroup.add(dad);*/
						flyState = 'hovering';
					}
				}
			}
			else if (s == 4)
			{
				remove(dodgething);
			}
		});
	}

	function cinematicBarsExe(appear:Bool) //IF (TRUE) MOMENT?????
	{
		if (appear)
		{
			add(topBar);
			add(bottomBar);
			FlxTween.tween(topBar, {y: 0}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(bottomBar, {y: 550}, 0.5, {ease: FlxEase.quadOut});
		}
		else
		{
			FlxTween.tween(topBar, {y: -170}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(bottomBar, {y: 720}, 0.5, {ease: FlxEase.quadOut, onComplete: function(fuckme:FlxTween)
			{
				remove(topBar);
				remove(bottomBar);
			}});
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				
				if (achievementName.contains(WeekData.getWeekFileName()) && achievementName.endsWith('nomiss')) // any FC achievements, name should be "weekFileName_nomiss", e.g: "weekd_nomiss";
				{
					if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD'
						&& storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						unlock = true;
				}
				switch(achievementName)
				{
					case 'bopeebo_pfc':
						if(Paths.formatToSongPath(SONG.song) == 'bopeebo' && ratingPercent >= 1 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185119);
						}
					case 'ballistic_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'ballistic' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185120);
						}
					case 'ballistichq_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'ballistic-(hq)' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185122);
						}
					case 'madness_fc':
						if(Paths.formatToSongPath(SONG.song) == 'madness' && songMisses < 1 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185123);
						}
					case 'expurgation_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'expurgation' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty && !pussyMode) {
							unlock = true;
							GameJoltAPI.getTrophy(185125);
						}
					case 'foolhardy_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'foolhardy' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185126);
						}
					case 'sporting_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'sporting' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185127);
						}
					case 'tooslow_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'too-slow' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(187353);
						}
					case 'tooslowencore_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'too-slow-encore' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(187354);
						}
					case 'endless_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'endless' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(187355);
						}
					case 'oldendless_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'endless-old' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(187356);
						}
					case 'cycles_fc':
						if(Paths.formatToSongPath(SONG.song) == 'cycles' && songMisses < 1 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(187350);
						}
					case 'execution_fc':
						if(Paths.formatToSongPath(SONG.song) == 'execution' && songMisses < 1 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(187351);
						}
					case 'sunshine_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'sunshine' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(187357);
						}
					case 'chaos_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'chaos' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(187358);
						}
					case 'faker_fc':
						if(Paths.formatToSongPath(SONG.song) == 'faker' && songMisses < 1 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(187352);
						}
					case 'blacksun_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'black-sun' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(187359);
						}
					case 'fatality_90acc':
						if(Paths.formatToSongPath(SONG.song) == 'fatality' && ratingPercent >= 0.9 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(187360);
						}
					case 'novillains_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'no-villains' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185128);
						}
					case 'noheroes_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'no-heroes' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185394);
						}
					case 'phantasm_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'phantasm' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185130);
						}
					case 'lostcause_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'lost-cause' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty && !pussyMode) {
							unlock = true;
							GameJoltAPI.getTrophy(185131);
						}
					case 'reactor_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'reactor' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185132);
						}	
					case 'doublekill_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'double-kill' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185133);
						}											
					case 'defeat_fc':
						if(Paths.formatToSongPath(SONG.song) == 'defeat' && songMisses < 1 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185135);
						}
					case 'heartbeat_fc':
						if(Paths.formatToSongPath(SONG.song) == 'heartbeat' && songMisses < 1 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185136);
						}						
					case 'pretender_fc':
						if(Paths.formatToSongPath(SONG.song) == 'pretender' && songMisses < 1 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185137);
						}
					case 'insanestreamer_fc':
						if(Paths.formatToSongPath(SONG.song) == 'insane-streamer' && songMisses < 1 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185138);
						}
					case 'idk_fc':
						if(Paths.formatToSongPath(SONG.song) == 'idk' && songMisses < 1 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185139);
						}			
					case 'torture_fc':
						if(Paths.formatToSongPath(SONG.song) == 'torture' && songMisses < 1 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(185141);
						}																	
					case 'sage_fc':
						if(Paths.formatToSongPath(SONG.song) == 'sage' && songMisses < 1 && !usedPractice && !changedDifficulty && !pussyMode) {
							unlock = true;
							GameJoltAPI.getTrophy(185142);
						}
					case 'infitrigger_2miss':
						if(Paths.formatToSongPath(SONG.song) == 'infitrigger' && songMisses <= 2 && !usedPractice && !changedDifficulty && !pussyMode) {
							unlock = true;
							GameJoltAPI.getTrophy(185143);
						}
					case 'ebola_immune':
						if(Paths.formatToSongPath(SONG.song) == 'infitrigger' && totalEbolaNotesHit >= 5 && !usedPractice && !changedDifficulty && !pussyMode) {
							unlock = true;
							GameJoltAPI.getTrophy(185144);
						}
					case 'honorbound_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'honorbound' && ratingPercent >= 0.95 && !usedPractice && !pussyMode) {
							unlock = true;
							GameJoltAPI.getTrophy(185145);
						}
					case 'eyelander_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'eyelander' && ratingPercent >= 0.95 && !usedPractice && !pussyMode) {
							unlock = true;
							GameJoltAPI.getTrophy(185146);
						}
					case 'strongmann_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'strongmann' && ratingPercent >= 0.95 && !usedPractice) {
							unlock = true;
							GameJoltAPI.getTrophy(185147);
						}
					case 'acceptance_fc':
						if(Paths.formatToSongPath(SONG.song) == 'acceptance' && songMisses < 1 && !usedPractice) {
							unlock = true;
							GameJoltAPI.getTrophy(185395);
						}
					case 'delirious_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'delirious' && ratingPercent >= 0.95 && !usedPractice) {
							unlock = true;
							GameJoltAPI.getTrophy(185396);
						}
					case 'recursed_fc':
						if(Paths.formatToSongPath(SONG.song) == 'recursed' && songMisses < 1 && !usedPractice && !pussyMode) {
							unlock = true;
							GameJoltAPI.getTrophy(185148);
						}
					case 'bombastic_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'bombastic' && ratingPercent >= 0.95 && !usedPractice && !pussyMode) {
							unlock = true;
							GameJoltAPI.getTrophy(185149);
						}
					case 'abuse_fc':
						if(Paths.formatToSongPath(SONG.song) == 'abuse' && songMisses < 1 && !usedPractice && !pussyMode) {
							unlock = true;
							GameJoltAPI.getTrophy(185151);
						}
					case 'trinity_90acc':
						if(Paths.formatToSongPath(SONG.song) == 'trinity' && ratingPercent >= 0.9 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(187361);
						}
					case 'iamgod_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'i-am-god' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(187362);
						}
					case 'superscare_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'superscare' && ratingPercent >= 0.95 && !usedPractice && !changedDifficulty) {
							unlock = true;
							GameJoltAPI.getTrophy(187363);
						}
					case 'attack_95acc':
						if(Paths.formatToSongPath(SONG.song) == 'attack' && ratingPercent >= 0.95 && !usedPractice) {
							unlock = true;
							GameJoltAPI.getTrophy(185152);
						}	
					case 'blueballed_100':
						if (deathCounter == 100) {
							unlock = true;
							GameJoltAPI.getTrophy(185154);
						}
					case 'fourkeyonly':
						if(!usedPractice && Paths.formatToSongPath(SONG.song) != 'bopeebo' && !changedDifficulty) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 4) {
								unlock = true;
								GameJoltAPI.getTrophy(185155);
							}
						}
					case 'insanity':
						if (instakillOnMiss && fadeOut && fadeIn && drunkGame && !pussyMode && pendulumMode && !usedPractice && !changedDifficulty && Paths.formatToSongPath(SONG.song) != 'bopeebo') {
							unlock = true;
							GameJoltAPI.getTrophy(185156);
						}					
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var curLight:Int = -1;
	var curLightEvent:Int = -1;

	override function switchTo(state:FlxState){
		// DO CLEAN-UP HERE!!
		if(curSong == 'fatality'){
			FlxG.mouse.unload();
			FlxG.mouse.visible = false;
		}

		if(isFixedAspectRatio){
			Lib.application.window.resizable = true;
			FlxG.scaleMode = new RatioScaleMode(false);
			FlxG.resizeGame(1280, 720);
			FlxG.resizeWindow(1280, 720);
		}

		return super.switchTo(state);
	}
}
