package;

import lime.app.Future;
import openfl.media.Sound;
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
import lime.utils.Assets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	var onlineSongs:Array<SongMetadata> = [];

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['dad']);

		var request = js.Browser.createXMLHttpRequest();
		request.addEventListener('load', function()
		{
			var onlineSongItems:Dynamic = cast haxe.Json.parse(request.responseText).items;
			for(i in 0...onlineSongItems.length)
			{
				var onlineSongItemName = onlineSongItems[i].song_name;

				var chartPath = 'http://sancopublic.ddns.net:5430/api/files/fnf_charts/' + onlineSongItems[i].id + "/" + onlineSongItems[i].chart_file;
				var instPath = 'http://sancopublic.ddns.net:5430/api/files/fnf_charts/' + onlineSongItems[i].id + "/" + onlineSongItems[i].inst;
				var vocalsPath = 'http://sancopublic.ddns.net:5430/api/files/fnf_charts/' + onlineSongItems[i].id + "/" + onlineSongItems[i].voices;

				onlineSongs.push(new SongMetadata(onlineSongItemName, i, "bf", chartPath, instPath, vocalsPath));
				
				openfl.system.System.gc();
			}
		});
		request.open("GET", 'http://sancopublic.ddns.net:5430/api/collections/fnf_charts/records');
		request.send();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();
		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, "", "", ""));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (FlxG.keys.justPressed.TAB)
		{
			songs = onlineSongs;
			regenMenu();
		}

		if (accepted)
		{
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeek = songs[curSelected].week;

			var request = js.Browser.createXMLHttpRequest();
			request.addEventListener('load', function()
			{
				trace("Got chart data");
				PlayState.SONG = Song.parseJSONshit(request.responseText);
				trace("Now trying to get inst using Future");
				Sound.loadFromFile(songs[curSelected].instPath).then(function(inst)
				{
					trace("Successfully got inst");
					PlayState.inst = inst;
					return Future.withValue(inst);
				});
				if(PlayState.SONG.needsVoices)
				{
					trace("Song needs voices, trying to get vocals using Future");
					Sound.loadFromFile(songs[curSelected].vocalsPath).then(function(vocals)
					{
						trace("Successfully got vocals");
						PlayState.voices = vocals;
						trace("Seems like nothing more is needed, switching to Playstate");
						LoadingState.loadAndSwitchState(new PlayState());
						return Future.withValue(vocals);
					});
				}
				else
				{
					trace("Seems like nothing more is needed, switching to Playstate");
					LoadingState.loadAndSwitchState(new PlayState());
				}
			});
			request.open("GET", songs[curSelected].chartPath); //we tryna to get the chart data
			request.send();
			/*
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState());*/
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}

	function regenMenu()
    {
        grpSongs.clear();

        for(i in 0...songs.length)
        {
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
        }

        curSelected = 0;
        changeSelection();
    }
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public var chartPath:String = "";
	public var instPath:String = "";
	public var vocalsPath:String = "";

	public function new(song:String, week:Int, songCharacter:String, chartPath:String, instPath:String, vocalsPath:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;

		this.chartPath = chartPath;
		this.instPath = instPath;
		this.vocalsPath = vocalsPath;
	}
}