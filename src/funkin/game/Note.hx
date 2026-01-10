package funkin.game;

import flixel.math.FlxRect;

class Note extends FunkinSprite
{
	public var lastSkinName:String;
	public var lane:Int = 0;
	public var resetAnim:Float = 0;
	public var downScroll:Bool = false;

	public static var directions:Array<String> = ['left', 'down', 'up', 'right'];

	public var time:Float = 0;
	public var mustPress:Bool = false;
	public var isSustainNote:Bool = false;
	public var sustainLength:Float = 0;
	public var prevNote:Note;
	public var hit:Bool = false;

	public var canBeHit(get, null):Bool;
	public var ignoreNote(default, null):Bool = false;
	public var parent(default, null):Note;

	public function new(lane:Int = 0, time:Float = 0, mustPress:Bool = false, ?isSustainNote:Bool = false, ?sustainLength:Float = 0, ?prevNote:Note,
			?skinName:String = "NOTE_assets")
	{
		super(0, 0);
		this.lastSkinName = skinName;
		this.lane = lane;
		this.prevNote = prevNote ?? this;
		this.time = time;
		this.mustPress = mustPress;
		this.isSustainNote = isSustainNote;
		this.sustainLength = sustainLength;

		reload();
	}

	public function reload()
	{
		final tempSkin = NoteSkin.getSkin(lastSkinName);
		final laneName = directions[lane];

		loadAtlas("notes/" + lastSkinName, SPARROW);
		addAnimPrefix("arrow", laneName + '0', 24, true);
		addAnimPrefix("segment", laneName + ' hold0');
		addAnimPrefix("cap", laneName + ' hold end0');

		playAnim("arrow");
		scale.set(tempSkin.scale, tempSkin.scale);
		updateHitbox();

		if (prevNote != null && isSustainNote)
		{
			multAlpha = alpha = 0.6;
			playAnim("cap");
			updateHitbox();

			if (prevNote.isSustainNote)
			{
				prevNote.playAnim("segment");
				prevNote.updateHitbox();
			}
		}

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
		var tX = strum.x + Math.cos(shit) * distanceMS;
		tX += (strum.width * 0.5 - width * 0.5);

		var tY = strum.y + Math.sin(shit) * distanceMS;
		if (isSustainNote)
			tY += strum.width / 2;
		if (x != tX)
			x = tX;
		if (y != tY)
			y = tY;
		if (alpha != strum.alpha * multAlpha)
			alpha = strum.alpha * multAlpha;

		if (isSustainNote && animation.name == 'segment')
		{
			scale.y = (0.45 * sustainLength * speed) / frameHeight;
			updateHitbox();
		}
		if (isSustainNote)
		{
			centerOffsets();
			centerOrigin();
			origin.y = offset.y = 0;
			angle = scrollDir;
			flipY = strum.downScroll;
		}
	}

	override function draw()
	{
		if (strum != null && isSustainNote)
			updateClip();
		super.draw();
	}

	function updateClip()
	{
		var canClip = mustPress && hit || !mustPress && (overlaps(strum));
		if (canClip)
		{
			var swagRect = this.clipRect ?? new FlxRect(0, 0, frameWidth, frameHeight);
			var center = strum.y + (160 * 0.7) * 0.5;
			if (!strum.downScroll)
			{
				swagRect.y = (center - y) / scale.y;
				swagRect.height = (height / scale.y) - (swagRect.y);
			}
			else
			{
				swagRect.height = (center - y) / scale.y;
				swagRect.y = frameHeight - swagRect.height;
			}
			this.clipRect ??= swagRect;
		}
	}

	function get_canBeHit():Bool
	{
		return (time <= Conductor.songPosition + Conductor.safeZoneOffset * 0.5
			&& !(time <= Conductor.songPosition - Conductor.safeZoneOffset * 0.5));
	}
}
