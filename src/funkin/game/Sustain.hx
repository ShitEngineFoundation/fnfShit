package funkin.game;

import flixel.math.FlxRect;

class Sustain extends FunkinSprite
{
	public var parent:Note;
	public var tail:FunkinSprite;

	public function new(parent)
	{
		super(-3000, -3000);
		this.parent = parent;
		tail = new FunkinSprite(-3000, 3000);
		reload();
	}

	function reload()
	{
		frames = parent.frames;
		animation.copyFrom(parent.animation);
		playAnim("segment");
		scale.copyFrom(parent.scale);
		updateHitbox();
		centerOffsets();
		centerOrigin();

		tail.frames = parent.frames;
		tail.animation.copyFrom(parent.animation);
		tail.playAnim("cap");
		tail.scale.copyFrom(parent.scale);
		tail.updateHitbox();
		tail.centerOffsets();
		tail.centerOrigin();
	}

	override function draw()
	{
		if (parent != null)
		{
			scale.y = parent.getSusHeight() / frameHeight;
			updateHitbox();
			origin.y = offset.y = 0;
			tail.origin.y = tail.offset.y = 0;

			setPosition(parent.x + (parent.width * 0.5 - width * 0.5), parent.y + parent.height * 0.5);
			alpha = parent.alpha;
			angle = (parent.strum.noteDir + (parent.strum.downScroll ? 180 : 0));
			updateSustainClip();

			var shit = (angle + 90) * Math.PI / 180;

			var tailX = (x) + Math.cos(shit) * height;
			var tailY = (y) + Math.sin(shit) * height;
			tail.setPosition(tailX, tailY);
			tail.alpha = alpha;
			tail.angle = angle;
		}
		tail.draw();
		super.draw();
	}

	public function updateSustainClip()
		if (parent.hit)
		{
			var t = FlxMath.bound((Conductor.songPosition - parent.time) / height * 0.45 * parent.lastScrollSpeed, 0, 1);
			var rect = clipRect == null ? FlxRect.get() : clipRect;
			clipRect = rect.set(0, frameHeight * t, frameWidth, frameHeight * (1 - t));
		}
}
