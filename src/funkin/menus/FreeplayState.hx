package funkin.menus;

import lime.app.Application;
import funkin.game.Song;
import funkin.game.GameplayState;
import funkin.backend.system.TxtParser;

typedef SongM =
{
	var songName:String;
	var week:Int;
}

class FreeplayState extends FlxTransitionableState
{
	public var songList:Array<SongM> = [];

	public function new()
	{
		super();
		var txtList = TxtParser.parseSongList(Paths.getPath("data/songList.txt"));
		for (song in txtList.keyValueIterator())
		{
			songList.push({songName: song.key, week: song.value});
		}
		songList.sort((m, m2) -> return m.week - m2.week);
	}

	public var group:FlxTypedGroup<Alphabet>;

	public override function create()
	{
		trace(songList);
		var bg:FlxSprite = new FunkinSprite(0, 0, Paths.getGraphic("menus/menuDesat"));
		add(bg);

		group = new FlxTypedGroup<Alphabet>();
		add(group);

		for (i in 0...songList.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songList[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			group.add(songText);
		}
		super.create();

		persistentUpdate = true;
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.wheel != 0)
			changeSelection(-Math.round(FlxG.mouse.wheel / 4));
		if (controls.justPressed.UI_UP)
			changeSelection(-1);
		else if (controls.justPressed.UI_DOWN)
			changeSelection(1);

		if (controls.justPressed.UI_BACK)
		{
			FlxG.sound.play(Paths.getSound('sounds/cancelMenu'));
			FlxG.switchState(new MainMenuState());
			return;
		}

		if (controls.justPressed.UI_ACCEPT)
		{
			var songName = songList[curSelected].songName;
			var isValid = true;
			try
			{
				GameplayState.SONG = Song.loadFromJson(songName);
			}
			catch (e:Dynamic)
			{
				Application.current.window.alert('song error: $e', 'songError');
				isValid = false;
			}
			if (isValid)
				FlxG.sound.play(Paths.getSound('sounds/confirmMenu'));

			FlxG.switchState(isValid ? new GameplayState() : new FreeplayState());
		}
	}

	var curSelected = 0;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.getSound('sounds/scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songList.length - 1;
		if (curSelected >= songList.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		FlxG.sound.playMusic(Paths.getSound("songs/" + songList[curSelected].songName + '/sound/Inst', true), 0);
		FlxG.sound.music?.fadeIn(0.5, 0, 1);

		var bullShit:Int = 0;
		for (item in group.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}
}
