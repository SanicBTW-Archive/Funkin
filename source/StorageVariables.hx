package;

import sys.io.File;
import openfl.utils.Assets;
import sys.FileSystem;
import lime.system.System;
import haxe.io.Path;

//this method will be deprecated once i find a good way to do it lol (expect to be on 0.3 or 0.4)
class StorageVariables
{
    static var freeplayListTemplate = "Tutorial";
    static var hitsoundsTempl = "osumania";
	public static var RequiredPath:String = Path.join([System.userDirectory, 'sanicbtw_funkinfiles']);
	public static var DataRPath:String = Path.join([RequiredPath, 'data']);
    public static var SongsRPath:String = Path.join([RequiredPath, 'songs']);
    public static var FPLPath:String = Path.join([DataRPath, 'freeplaySonglist.txt']);
    public static var HitSoundsPath:String = Path.join([RequiredPath, 'hitsounds']);
    public static var HSLFPath:String = Path.join([HitSoundsPath, 'hitsoundsList.txt']);  //for custom hit sounds and shit

    public static function CheckStuff() {
        if(!FileSystem.exists(RequiredPath)){FileSystem.createDirectory(RequiredPath);}
        if(!FileSystem.exists(DataRPath)){FileSystem.createDirectory(DataRPath);}
        if(!FileSystem.exists(SongsRPath)){FileSystem.createDirectory(SongsRPath);}
        if(!FileSystem.exists(FPLPath)){File.saveContent(FPLPath, freeplayListTemplate);}
        if(!FileSystem.exists(HitSoundsPath)){FileSystem.createDirectory(HitSoundsPath);}
        if(!FileSystem.exists(HSLFPath)){File.saveContent(HSLFPath, hitsoundsTempl);}
    }

} 

enum Sources {
    ASSETS;
    INTERNAL;
}