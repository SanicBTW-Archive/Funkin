package;

import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import haxe.io.Path;
import sys.FileSystem;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

class HitSoundState extends MusicBeatState
{
    var soundEXT = "ogg";
    //var soundEXT = Paths.SOUND_EXT;
    var hitSounds:Array<String> = [];
    public static var hitSPaths:Array<String> = [];
    var checkArr:Array<String> = [];
    public static var ChosenHitSound:Array<Int> = [];

    private var grphitSounds:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;
    var check:FlxText;

    override function create()
    {
        var initHitSoundsList = CoolUtil.coolTextFile(StorageVariables.HSLFPath);
        for(i in 0...initHitSoundsList.length){
            hitSounds.push(initHitSoundsList[i]);
            var thename:String = hitSounds[i] + "." + soundEXT;
            var imaginarythingy:String = Path.join([StorageVariables.HitSoundsPath, thename]);
            trace("Pushing possible hit sound path");
            hitSPaths.push(imaginarythingy.toLowerCase());
            if(FileSystem.exists(hitSPaths[i])){
                trace("EXISTING");
                checkArr.push("Exists");
            } else {
                trace("FUCK");
                checkArr.push("Check again");
            }
            trace(hitSPaths[i]);
        }

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

        grphitSounds = new FlxTypedGroup<Alphabet>();
		add(grphitSounds);

        for(i in 0...hitSounds.length){
            var hitSoundsTxt:Alphabet = new Alphabet(0, (70 * i) + 30, hitSounds[i], true, false);
            hitSoundsTxt.isMenuItem = true;
            hitSoundsTxt.targetY = i;
            grphitSounds.add(hitSoundsTxt);
        }

        check = new FlxText(FlxG.width * 0.7, 5, 0, "trying to get path", 32);
        check.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

        var pathBG:FlxSprite = new FlxSprite(check.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		pathBG.alpha = 0.6;
		add(pathBG);

        add(check);

        changeSelection();

        FlxG.sound.music.stop();
        super.create();
    }

    override function update(elapsed:Float)
    {
        if(controls.BACK){
            FlxG.switchState(new MainMenuState());
        }

        if(controls.UP_P)
            changeSelection(-1);
        if(controls.DOWN_P)
            changeSelection(1);

        if(controls.ACCEPT){
            ChosenHitSound = [];
            ChosenHitSound.push(curSelected);
            FlxG.switchState(new MainMenuState());
        }

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0){
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curSelected += change;

        if(curSelected < 0)
            curSelected = hitSounds.length - 1;
        if(curSelected >= hitSounds.length)
            curSelected = 0;

        var bullShit:Int = 0;

        FlxG.sound.stream(hitSPaths[curSelected], 1000, true, null, false);

        for (item in grphitSounds.members){
            item.targetY = bullShit - curSelected;
            bullShit++;

            item.alpha = 0.6;

            if(item.targetY == 0)
                item.alpha = 1;
        }

        check.text = checkArr[curSelected];
    }
}