package funkin.game;

import flixel.tweens.FlxEase;

class HealthIcon extends FunkinSprite
{
	public var isPlayer = false;

	public function new(char:String = "bf", isPlayer:Bool = false)
	{
		super(0, 0);
		this.isPlayer = isPlayer;
		changeIcon(char);
	}

	public function changeIcon(char:String = "bf")
	{
		if (animation.getByName(char) == null)
		{
			flipX = isPlayer;
			loadGraphic(Paths.getGraphic("icons/icon-" + char));
			loadGraphic(Paths.getGraphic("icons/icon-" + char), true, Math.floor(width / 2), Math.floor(height));

			animation.add(char, [0, 1], 0);
            antialiasing = true;
		}
		animation.play(char);
	}

	public var baseScale:Float = 1;

	public function bump()
	{
		scale.set(baseScale * 1.2, baseScale * 1.2);
		updateHitbox();

		FlxTween.cancelTweensOf(scale);
		FlxTween.tween(scale, {x: baseScale, y: baseScale}, Conductor.beatLength * 0.5 / 1000,{ease: FlxEase.sineInOut});
	}
}
