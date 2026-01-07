package funkin.menus;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

class TitleState extends FlxState
{
	var logo:FunkinSprite;
	var girl:FunkinSprite;
	var enter:FunkinSprite;

	override public function create()
	{
		super.create();

		Paths.getAnimateAtlas("menus/title/gf_title");

		// GF
		girl = new FunkinSprite(520, 10);
		girl.loadAtlas("menus/title/gf_title", ANIMATE);
		girl.addAnimIndices("danceleft", "GF Dancing Beat", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);
		girl.addAnimIndices("danceright", "GF Dancing Beat", [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]);
		girl.antialiasing = true;
		girl.playAnim("danceleft", true);
		add(girl);

		// Logo
		logo = new FunkinSprite(0, 0, Paths.getGraphic("menus/title/logo"));
		logo.antialiasing = false;

		// Base scale
		logo.scale.set(1, 1);
		logo.updateHitbox();

		// Position ONCE
		logo.setPosition(-100, -100);
		logo.antialiasing = true;
		add(logo);

		// Enter
		enter = new FunkinSprite(100, 576);
		enter.antialiasing = true;
		enter.loadAtlas("menus/title/titleEnter", SPARROW);
		enter.addAnimPrefix("idle", "ENTER IDLE");
		enter.addAnimPrefix("press", "ENTER FREEZE");
		enter.playAnim("idle");
		add(enter);

		Conductor.BPM = 102;

		Conductor.onBeat.add((beat) ->
		{
			var isEven = Math.floor(beat) % 2 == 0;
			girl.playAnim(isEven ? "danceleft" : "danceright", true);

			// Bop
			logo.scale.set(1.2, 1.2);
		});

		FlxG.camera.alpha = 0.00000001;
		new FlxTimer().start(0.01, startIntro);
	}

	var exiting = false;

	function startIntro(?t)
	{
		FlxG.sound.playMusic(Paths.getSound("music/freakyMenu", true));
		FlxG.camera.alpha = 1;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		// Smooth return to base scale
		var m = FlxMath.lerp(1, logo.scale.x, elapsed * 9);
		logo.scale.set(m, m);

		if (controls.justPressed.UI_ACCEPT && !exiting)
		{
			exiting = true;
			FlxG.camera.flash();
			enter.playAnim("press");
			FlxG.sound.play(Paths.getSound("sounds/confirmMenu"));

			startTimer = new FlxTimer().start(1.5, (t) -> exit());
		}
		else if (exiting && controls.justPressed.UI_ACCEPT)
			exit();
	}
	var startTimer:FlxTimer;

	public function exit()
	{
		startTimer.cancel();
		startTimer.destroy();
		startTimer = null;
		FlxG.switchState(new MainMenuState());
	}
}
