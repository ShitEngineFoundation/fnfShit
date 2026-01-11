package funkin.game.sub;

class PauseSubState extends FlxSubState
{
	public var blackPixel:FlxGraphic;

	public function new()
	{
		super();
		blackPixel = FlxG.bitmap.create(1, 1, 0xFF000000, false, 'black_pixel_pause_menu');
	}

	var f = false;

	override function update(elapsed:Float)
	{
		if (!f)
		{
			f = true;
			return;
		}

		if (controls.justPressed.UI_BACK)
		{
			close();
		}
	}

	override function create() {
        var bg:FunkinSprite = new FunkinSprite(0,0,blackPixel);
        bg.alpha = 0;
        bg.makeGraphic(1,1,0xFF000000);
        bg.setGraphicSize(FlxG.width,FlxG.height);
        bg.updateHitbox();
        bg.screenCenter();
        add(bg);
        FlxTween.tween(bg,{alpha:0.4},0.1);
    }
}
