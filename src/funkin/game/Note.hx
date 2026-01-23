package funkin.game;

import flixel.math.FlxRect;

class Note extends FunkinSprite
{
	public static var types(default, null):Array<String> = [];

	public var lastSkinName:String;
	public var lane:Int = 0;
	public var resetAnim:Float = 0;
	public var downScroll:Bool = false;
	public var type:String = "normal";

	public static var directions:Array<String> = ['purple', 'blue', 'green', 'red'];

	public var time:Float = 0;
	public var mustPress:Bool = false;

	public var sustainLength:Float = 0;
	public var prevNote:Note;
	public var hit:Bool = false;

	public var canBeHit(get, null):Bool;
	public var ignoreNote(default, set):Bool = false;
	public var parent(default, null):Note;
	public var distance:Float = 0;

	public function new(lane:Int = 0, time:Float = 0, mustPress:Bool = false, ?sustainLength:Float = 0, ?prevNote:Note, ?skinName:String = "NOTE_assets")
	{
		super(0, 0);
		this.lastSkinName = skinName;
		this.lane = lane;
		this.prevNote = prevNote ?? this;
		this.time = time;
		this.mustPress = mustPress;
		this.sustainLength = sustainLength;

		reload();
	}

	public function reload()
	{
		final tempSkin = NoteSkin.getSkin(lastSkinName);
		final laneName = directions[lane];

		loadAtlas("notes/" + lastSkinName, SPARROW);
		addAnimPrefix("arrow", laneName + '0', 24, true);
		addAnimPrefix("segment", laneName + ' hold piece0', 24, true);
		addAnimPrefix("cap", laneName + ' hold end0', 24, true);

		playAnim("arrow");
		scale.set(tempSkin.scale, tempSkin.scale);
		updateHitbox();

		antialiasing = tempSkin.antialiasing;
	}

	public override function playAnim(animName:String, force = false, reversed = false, frame = 0)
	{
		super.playAnim(animName, force, reversed, frame);
		centerOffsets();
		centerOrigin();
	}

	public var lastScrollSpeed = 1.0;
	public var multAlpha:Float = 1;
	public var strum:Strum;

	public function move(strum:Strum, speed:Float = 1)
	{
		var scrollDir = strum.noteDir;
		var shit = (scrollDir + 90) * Math.PI / 180;

		lastScrollSpeed = speed;
		this.strum = strum;

		var distanceMS:Float = (time - Conductor.songPosition) * (0.45 * lastScrollSpeed) * (strum.downScroll ? -1 : 1);
		distance = distanceMS;
		var tX = strum.x + Math.cos(shit) * distanceMS;
		tX += (strum.width * 0.5 - width * 0.5);

		var tY = strum.y + Math.sin(shit) * distanceMS;

		if (x != tX)
			x = tX;
		if (y != tY)
			y = tY;
		if (alpha != strum.alpha * multAlpha)
			alpha = strum.alpha * multAlpha;
	}

	public var eHM:Float = 0.5;
	public var lHM:Float = 1;
	public var sustain:Sustain;

	function get_canBeHit():Bool
	{
		return (time <= Conductor.songPosition + Conductor.safeZoneOffset * eHM
			&& !(time <= Conductor.songPosition - Conductor.safeZoneOffset * lHM));
	}

	public function set_ignoreNote(v:Bool):Bool
	{
		color = v ? FlxColor.GRAY : 0xFFFFFFFF;
		multAlpha = v ? 0.6 : getInitialAlpha();
		return ignoreNote = v;
	}

	public function getInitialAlpha():Float
		return 1;

	override function draw()
	{
		if (hit)
			return;
		super.draw();
	}

	public function getSusHeight():Int
		return Math.floor(0.45 * lastScrollSpeed * sustainLength);
}
