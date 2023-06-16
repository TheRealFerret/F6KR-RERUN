#if desktop
import Discord.DiscordClient;
#end
import math.*;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxState;
import flixel.util.FlxColor;
import lime.app.Application;
import haxe.Exception;
using StringTools;
import flixel.util.FlxTimer;
import flixel.input.mouse.FlxMouseEventManager;
import flash.events.MouseEvent;
import ui.*;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import flixel.addons.display.FlxBackdrop;
import ClientPrefs;

class GFSelectState extends MusicBeatState
{
  var left:FlxSprite;
  var right:FlxSprite;
  var girlfrien:Character;
  public static var thegfriends = ["gf","gf-christmas","gfbetter","gfbest","gf-dside","gf-exe","gf-mii","gfmira","gf-tf2"];

  var selectableGfriends:Array<String>=[];
  var selectedChar:Int = 0;
  var characters:FlxTypedGroup<Character>;

  override function create()
  {
    super.create();
    FlxG.save.flush();
    for(gf in thegfriends){
        selectableGfriends.push(gf);
      }

    selectedChar = thegfriends.indexOf(ClientPrefs.gfSkin);
    if(selectedChar==-1){
      ClientPrefs.gfSkin = thegfriends[0];
      selectedChar=0;
    }
    var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBGMagenta'));
    bg.scrollFactor.set();
    bg.setGraphicSize(Std.int(bg.width * 1.1));
    bg.updateHitbox();
    bg.screenCenter();
    bg.antialiasing = true;
    add(bg);

    var esc:FlxText = new FlxText(60,25, FlxG.width, "Press \"BACK\" to select\n your GF and return.", 32);
    esc.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(esc);

    var controls:FlxText = new FlxText(60,85, FlxG.width, "Press \"LEFT\" or \"RIGHT\"\n to switch GFs.", 32);
    controls.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(controls);

    var notice:FlxText = new FlxText(60,160, FlxG.width, "If you don\'t see any GFs\n then enter a song and\n leave to fix it.", 32);
    notice.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(notice);

    characters = new FlxTypedGroup<Character>();
    add(characters);

    #if desktop
    // Updating Discord Rich Presence
    DiscordClient.changePresence("Selecting a new GF", null);
    #end

    for(name in selectableGfriends){
      var char = new Character(0,0,name);
      char.screenCenter(XY);
      char.visible=false;
      characters.add(char);
    }
    characters.members[selectedChar].visible=true;
    girlfrien = characters.members[selectedChar];
  }

  override function beatHit(){
    for(c in characters){
      c.dance();
    }
    super.beatHit();
  }

  override function switchTo(next:FlxState){
    for(c in characters){
      c.destroy();
    }
		return super.switchTo(next);
	}

  function change(delta:Int){
    selectedChar += delta;
    if(selectedChar<0)selectedChar = characters.length-1;
    if(selectedChar>characters.length-1)selectedChar = 0;
    girlfrien.visible=false;
    girlfrien = characters.members[selectedChar];
    girlfrien.visible=true;
  }

  override function update(elapsed:Float){
    if (FlxG.sound.music != null)
      Conductor.songPosition = FlxG.sound.music.time;
    super.update(elapsed);

    if (controls.BACK)
    {
      ClientPrefs.gfSkin = selectableGfriends[selectedChar];
      ClientPrefs.saveSettings();
      FlxG.switchState(new FreeplayState());
    }

    if(controls.UI_LEFT_P){
      change(-1);
    }

    if(controls.UI_RIGHT_P){
      change(1);
    }

  }
}