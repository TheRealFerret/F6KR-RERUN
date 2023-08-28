package;

import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRandom;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;
import editors.ChartingState;

using StringTools;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends FlxSprite
{
	//////////////////////////////////////////////////
	//Extra keys stuff

	//Important stuff
	public static var gfxLetter:Array<String> = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
												'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R'];
	public static var ammo:Array<Int> = EKData.gun;
	public static var minMania:Int = 0;
	public static var maxMania:Int = 17; // key value is this + 1

	public static var scales:Array<Float> = EKData.scales;
	public static var lessX:Array<Int> = EKData.lessX;
	public static var separator:Array<Int> = EKData.noteSep;
	public static var xtra:Array<Float> = EKData.offsetX;
	public static var posRest:Array<Float> = EKData.restPosition;
	public static var gridSizes:Array<Int> = EKData.gridSizes;
	public static var noteSplashOffsets:Map<Int, Array<Int>> = [
		0 => [20, 10],
		9 => [10, 20]
	];
	public static var noteSplashScales:Array<Float> = EKData.splashScales;

	public static var xmlMax:Int = 17; // This specifies the max of the splashes can go

	public static var minManiaUI_integer:Int = minMania + 1;
	public static var maxManiaUI_integer:Int = maxMania + 1;

	public static var defaultMania:Int = 3;

	// pixel notes
	public static var pixelNotesDivisionValue:Int = 18;
	public static var pixelScales:Array<Float> = EKData.pixelScales;

	public static var keysShit:Map<Int, Map<String, Dynamic>> = EKData.keysShit;

	// End of extra keys stuff
	//////////////////////////////////////////////////

	public var alreadyTweened:Bool = false;
	
	public var extraData:Map<String,Dynamic> = [];
	public var row:Int = 0;
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;

	public var spawned:Bool = false;

	public var tail:Array<Note> = []; // for sustains
	public var parent:Note;
	public var blockHit:Bool = false; // only works for player

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;

	public var animSuffix:String = '';
	public var gfNote:Bool = false;
	public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1;
	public var lowPriority:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;
	public var multSpeed(default, set):Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; //9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
	public var ratingDisabled:Bool = false;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var noMissAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000; //plan on doing scroll directions soon -bb

	public var hitsoundDisabled:Bool = false;
	public var changeAnim:Bool = true;
	public var changeColSwap:Bool = true;

	public var noteIsPixel:Bool = false;
	
	public function resizeByRatio(ratio:Float) //haha funny twitter shit
		{
			if(isSustainNote && !animation.curAnim.name.endsWith('end'))
			{
				scale.y *= ratio;
				updateHitbox();
			}
		}

	private function set_multSpeed(value:Float):Float {
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		//trace('fuck cock');
		return value;
	}

	public var mania:Int = 1;

	var ogW:Float;
	var ogH:Float;

	var defaultWidth:Float = 0;
	var defaultHeight:Float = 0;

	private function set_texture(value:String):String {
		if(texture != value) {
			reloadNote('', value);
		}
		texture = value;
		return value;
	}


	private function set_noteType(value:String):String {
		noteSplashTexture = PlayState.SONG.splashSkin;
		if (noteData > -1 && noteData < ClientPrefs.arrowHSV.length)
		{
			colorSwap.hue = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][2] / 100;
		}

		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					if (PlayState.instance.pussyMode == true || PlayState.instance.randomMode == true)
						this.kill();
					else {
						if (PlayState.SONG.song.toLowerCase() == 'madness' && !PlayState.opponentChart)
							ignoreNote = false;
						else
							ignoreNote = true;

						hitByOpponent = false;

						if (PlayState.SONG.song.toLowerCase() == 'madness'){
							reloadNote('FIRE');
							setGraphicSize(Std.int(width * 1.86));
							noteSplashTexture = 'FIREnoteSplashes';
						}
						else{
							reloadNote('HURT');
							noteSplashTexture = 'HURTnoteSplashes';
						}

						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
						lowPriority = true;
						if(isSustainNote) {
							missHealth = 0.1;
						} else {
							missHealth = 0.3;
						}
						hitCausesMiss = true;
					}
				case 'Hurt Note Hell':
					if (PlayState.instance.hellMode == false || PlayState.instance.randomMode == true)
						this.kill();
					else {
						ignoreNote = true;
						hitByOpponent = false;

						if (PlayState.SONG.song.toLowerCase() == 'madness'){
							reloadNote('FIRE');
							setGraphicSize(Std.int(width * 1.86));
							noteSplashTexture = 'FIREnoteSplashes';
						}
						else{
							reloadNote('HURT');
							noteSplashTexture = 'HURTnoteSplashes';
						}

						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
						lowPriority = true;
						if(isSustainNote) {
							missHealth = 0.1;
						} else {
							missHealth = 0.3;
						}
						hitCausesMiss = true;
					}
				case 'Alt Animation':
					animSuffix = '-alt';
				case 'No Animation':
					noAnimation = true;
					noMissAnimation = true;
				case 'GF Sing':
					gfNote = true;
				case 'Sage Note':
					if (PlayState.instance.pussyMode == true)
						hitHealth = 0.03;
					else {
						reloadNote('SAGE');
						hitHealth = 0.03;
						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
					}
				case 'Ebola Note':
					if (PlayState.instance.pussyMode == true || PlayState.instance.randomMode == true)
						this.kill();
					else{
						ignoreNote = true;
						reloadNote('EBOLA');
						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
						lowPriority = true;
						hitCausesMiss = true;
					}
				case 'Drunk Note':
					if (PlayState.instance.pussyMode == true)
						hitHealth = 0.03;
					else {
						reloadNote('DRUNK');
						hitHealth = 0.03;
						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
					}
				case 'Text Note':
					if (PlayState.instance.pussyMode == true)
						hitHealth = 0.03;
					else {
						hitHealth = 0.023;
						frames = Paths.getSparrowAtlas('recursed/alphabet');
						
						setGraphicSize(Std.int(width * 1.2));
						updateHitbox();
						antialiasing = true;
						offsetX = -(width - 78);
					}
				case 'Death Note':
					if (PlayState.instance.pussyMode == true || PlayState.instance.randomMode == true)
						this.kill();
					else {
						ignoreNote = true;
						hitByOpponent = false;
						if (PlayState.SONG.song.toLowerCase() == 'epiphany')
							reloadNote('MARKOV');
						else if (PlayState.SONG.song.toLowerCase() == 'expurgation'){
							reloadNote('HALO');
							setGraphicSize(Std.int(width * 3.86));
						}
						else
							reloadNote('DEATH');

						noteSplashTexture = 'HURTnoteSplashes';
						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
						lowPriority = true;
						if(isSustainNote) {
							missHealth = 999;
						} else {
							missHealth = 999;
						}
						hitCausesMiss = true;
					}
				case 'Conch Note':
					if (PlayState.instance.pussyMode == true)
						hitHealth = 0.03;
					else {
						reloadNote('CONCH');
						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
						hitHealth = 0.03;
						missHealth = 0.8;
						noAnimation = true;
					}
				case 'Opponent 2 Sing':
					lowPriority = false;
				case 'Both Opponents Sing':
					lowPriority = false;
				case 'nermalNote':
					if (PlayState.instance.pussyMode == true || PlayState.instance.randomMode == true)
						this.kill();
					hitByOpponent = false;
					ignoreNote = true;
				case 'jumpScareNote':
					if (PlayState.instance.pussyMode == true || PlayState.instance.randomMode == true)
						this.kill();
					hitByOpponent = false;
					ignoreNote = true;
				case 'Bomb Note':
					if (PlayState.instance.pussyMode == true || PlayState.instance.randomMode == true)
						this.kill();
					hitByOpponent = false;
					ignoreNote = true;
				case 'Deli Note':
					if (PlayState.instance.pussyMode == true || PlayState.instance.randomMode == true)
						this.kill();
					else {
						reloadNote('DELI');
						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
						ignoreNote = true;
						hitByOpponent = false;
						lowPriority = true;
						hitCausesMiss = true;
					}
				case 'Majin Note':
					reloadNote('MAJIN');
					noteSplashTexture = 'endlessNoteSplashes';
				case 'Fatal Note':
					if (PlayState.instance.hellMode == true || PlayState.instance.hellMode == true && PlayState.instance.randomMode == true) {
						reloadNote('FATAL');
						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
						ignoreNote = true;
						lowPriority = true;
						hitCausesMiss = true;
						hitByOpponent = false;
					}
					else
						this.kill();
				case 'Static Note':
					if (PlayState.instance.pussyMode == false)
						reloadNote('STATIC');
				case 'Static Note Hell':
					if (PlayState.instance.hellMode == true)
						reloadNote('STATIC');
				case 'Ice Note':
					if (PlayState.instance.pussyMode == true || PlayState.instance.randomMode == true)
						this.kill();
					else {
						//hitbox*=.5;
						lowPriority = true;
						ignoreNote = true;
						hitByOpponent = false;
						reloadNote('ICE');
						noteSplashTexture = 'ICEnoteSplashes';
						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
					}
				case 'Bob Musthit':
					if (PlayState.instance.pussyMode == true)
						hitHealth = 0.03;
					else {
						//hitbox*=.5;
						reloadNote('BOB');
						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
						hitHealth = 0.03;
					}
				case 'Bob Warning':
					if (PlayState.instance.pussyMode == true || PlayState.instance.randomMode == true)
						this.kill();
					else {
						//hitbox*=.5;
						lowPriority = true;
						ignoreNote = true;
						hitByOpponent = false;
						reloadNote('BOBINVERT');
						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
						hitCausesMiss = true;
					}
				case 'spam':
					if (PlayState.instance.hellMode == false)
						this.kill();
					ignoreNote = true;
					hitByOpponent = false;
				case 'Pixel Note':
					noteIsPixel = true;
					reloadNote('SONIC');
				case 'Phantom Note':
					lowPriority = true;
					ignoreNote = true;
					hitByOpponent = false;
					reloadNote('PHANTOM');
					ignoreNote = true;
					hitCausesMiss = true;
				case 'Non OpponentPlay Note':
					if (PlayState.opponentChart)
						this.kill();
				case 'Ebola Note Cancer Lord':
					reloadNote('EBOLA');
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();

		mania = PlayState.mania;

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;

		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.noteOffset;

		this.noteData = noteData;

		if(noteData > -1) {
			texture = '';
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			x += swagWidth * (noteData % Note.ammo[mania]);
			if(!isSustainNote && noteData > -1 && noteData < Note.maxManiaUI_integer) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				animToPlay = Note.keysShit.get(mania).get('letters')[noteData];
				animation.play(animToPlay);
			}
		}
		
		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;
			hitsoundDisabled = true;
			if(ClientPrefs.downScroll) flipY = true;

			offsetX += width / 2;
			copyAngle = false;

			animation.play(Note.keysShit.get(mania).get('letters')[noteData] + ' tail');

			updateHitbox();

			offsetX -= width / 2;

			if (PlayState.isPixelStage||noteIsPixel)
				offsetX += 30 * Note.pixelScales[mania];

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(Note.keysShit.get(mania).get('letters')[prevNote.noteData] + ' hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if(PlayState.instance != null)
				{
					prevNote.scale.y *= PlayState.instance.songSpeed;
				}

				if(PlayState.isPixelStage||noteIsPixel) { ///Y E  A H
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); //Auto adjust note size
				}
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}

			if(PlayState.isPixelStage||noteIsPixel) {
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		} else if(!isSustainNote) {
			earlyHitMult = 1;
		}
		x += offsetX;
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	var lastNoteScaleToo:Float = 1;
	public var originalHeightForCalcs:Float = 6;
	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '') {
		if(prefix == null) prefix = '';
		if(texture == null) texture = '';
		if(suffix == null) suffix = '';
		
		var skin:String = texture;
		if(texture.length < 1) {
			skin = PlayState.SONG.arrowSkin;
			if(skin == null || skin.length < 1) {
				skin = 'NOTE_assets';
			}
		}

		var animName:String = null;
		if(animation.curAnim != null) {
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length-1] = prefix + arraySkin[arraySkin.length-1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');

		defaultWidth = 157;
		defaultHeight = 154;
		if(PlayState.isPixelStage) {
			if(isSustainNote) {
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
				width = width / pixelNotesDivisionValue;
				height = height / 2;
				originalHeightForCalcs = height;
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
			} else {
				loadGraphic(Paths.image('pixelUI/' + blahblah));
				width = width / pixelNotesDivisionValue;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
			}
			defaultWidth = width;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom * Note.pixelScales[mania]));
			loadPixelNoteAnims();
			antialiasing = false;

			if(isSustainNote) {
				offsetX += lastNoteOffsetXForPixelAutoAdjusting;
				lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (PlayState.daPixelZoom / 2);
				offsetX -= lastNoteOffsetXForPixelAutoAdjusting;
				
				/*if(animName != null && !animName.endsWith('end'))
				{
					lastScaleY /= lastNoteScaleToo;
					lastNoteScaleToo = (6 / height);
					lastScaleY *= lastNoteScaleToo; 
				}*/
			}
		} else {
			if (noteIsPixel){
				if(isSustainNote) {
					loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
					width = width / pixelNotesDivisionValue;
					height = height / 2;
					originalHeightForCalcs = height;
					loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
				} else {
					loadGraphic(Paths.image('pixelUI/' + blahblah));
					width = width / pixelNotesDivisionValue;
					height = height / 5;
					loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
				}
				defaultWidth = width;
				setGraphicSize(Std.int(width * PlayState.daPixelZoom * Note.pixelScales[mania]));
				loadPixelNoteAnims();
				antialiasing = false;
	
				if(isSustainNote) {
					offsetX += lastNoteOffsetXForPixelAutoAdjusting;
					lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (PlayState.daPixelZoom / 2);
					offsetX -= lastNoteOffsetXForPixelAutoAdjusting;
					
					/*if(animName != null && !animName.endsWith('end'))
					{
						lastScaleY /= lastNoteScaleToo;
						lastNoteScaleToo = (6 / height);
						lastScaleY *= lastNoteScaleToo; 
					}*/
				}
			}
			else{
				frames = Paths.getSparrowAtlas(blahblah);
				loadNoteAnims();
				antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
		if(isSustainNote) {
			scale.y = lastScaleY;
		}
		updateHitbox();

		if(animName != null)
			animation.play(animName, true);

		if(inEditor) {
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	function loadNoteAnims() {
		for (i in 0...gfxLetter.length)
			{
				if (noteType == 'Text Note'){
					if (PlayState.instance.pussyMode == false){
						animation.addByPrefix(gfxLetter[0], 'END PARENTHESES bold0', 24);
						animation.addByPrefix(gfxLetter[1], 'M bold0', 24);
						animation.addByPrefix(gfxLetter[2], 'START PARENTHESES bold0', 24);
						animation.addByPrefix(gfxLetter[3], 'bold >0', 24);
						animation.addByPrefix(gfxLetter[4], 'À bold0', 24);
						animation.addByPrefix(gfxLetter[5], 'Ó bold0', 24);
					}
				}
				else
				animation.addByPrefix(gfxLetter[i], gfxLetter[i] + '0');
	
				if (isSustainNote)
				{
					if (PlayState.instance.pussyMode == false){
						if (noteType == 'Text Note'){
							reloadNote('NOTE');
						}
					}
					animation.addByPrefix(gfxLetter[i] + ' hold', gfxLetter[i] + ' hold');
					animation.addByPrefix(gfxLetter[i] + ' tail', gfxLetter[i] + ' tail');
				}
			}
				
			ogW = width;
			ogH = height;
			if (!isSustainNote)
				setGraphicSize(Std.int(defaultWidth * scales[mania]));
			else
				setGraphicSize(Std.int(defaultWidth * scales[mania]), Std.int(defaultHeight * scales[0]));
			updateHitbox();
	}

	function loadPixelNoteAnims() {
		if(isSustainNote) {
			for (i in 0...gfxLetter.length) {
				animation.add(gfxLetter[i] + ' hold', [i]);
				animation.add(gfxLetter[i] + ' tail', [i + pixelNotesDivisionValue]);
			}
		} else {
			for (i in 0...gfxLetter.length) {
				animation.add(gfxLetter[i], [i + pixelNotesDivisionValue]);
			}
		}
	}

	/*public function applyManiaChange()
	{
		if (isSustainNote) 
			scale.y = 1;
		reloadNote(texture);
		if (isSustainNote)
			offsetX = width / 2;
		if (!isSustainNote)
		{
			var animToPlay:String = '';
			animToPlay = Note.keysShit.get(mania).get('letters')[noteData % Note.ammo[mania]];
			animation.play(animToPlay);
		}

		/*if (isSustainNote && prevNote != null) someone please tell me why this wont work
		{
			animation.play(Note.keysShit.get(mania).get('letters')[noteData % Note.ammo[mania]] + ' tail');
			if (prevNote != null && prevNote.isSustainNote)
			{
				prevNote.animation.play(Note.keysShit.get(mania).get('letters')[prevNote.noteData % Note.ammo[mania]] + ' hold');
				prevNote.updateHitbox();
			}
		}

		updateHitbox();
	}*/


	override function update(elapsed:Float)
	{
		super.update(elapsed);

		mania = PlayState.mania;

		/* im so stupid for that
		if (noteData == 9)
		{
			if (animation.curAnim != null)
				trace(animation.curAnim.name);
			else trace("te anim is null waaaaaa");

			trace(Note.keysShit.get(mania).get('letters')[noteData]);
		}
		*/

		if (mustPress)
		{
			// ok river
			if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
			{
				if((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}

		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}