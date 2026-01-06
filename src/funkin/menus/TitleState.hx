package funkin.menus;

class TitleState extends flixel.FlxState
{
	override public function create()
	{
		super.create();

		Paths.getAnimateAtlas("menus/title/gf_title");

		var girl:FunkinSprite = new FunkinSprite(480, 0);
		girl.loadAtlas("menus/title/gf_title", ANIMATE);
		girl.addAnimIndices("danceleft", "GF Dancing Beat", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);
		girl.addAnimIndices("danceright", "GF Dancing Beat", [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]);
		girl.antialiasing = true;
		girl.playAnim("danceRight");
		add(girl);

		Conductor.onBeat.add((beat) ->
		{
			var roundedBeat = Math.floor(beat);
			var isEven = roundedBeat % 2 == 0;
			girl.playAnim(isEven ? "danceleft" : "danceright", true);
		});
		Conductor.BPM = 102;
		FlxG.sound.playMusic(Paths.getSound("music/freakyMenu", true));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		Conductor.songPosition = FlxG.sound.music.time;
	}
}
