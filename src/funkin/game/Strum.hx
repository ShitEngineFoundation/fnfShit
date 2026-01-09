package funkin.game;

class Strum extends FunkinSprite
{
	public var lastSkinName:String;
	public var lane:Int = 0;
	public var resetAnim:Float = 0;
	public var downScroll:Bool = false;

	public static var directions:Array<String> = ['left', 'down', 'up', 'right'];

	public function new(lane:Int = 0, ?skinName:String = "NOTE_assets")
	{
		super(0, 0);
		this.lastSkinName = skinName;
		this.lane = lane;
		reload();
	}

	public function reload()
	{
		final tempSkin = NoteSkin.getSkin(lastSkinName);
		final laneName = directions[lane];

		loadAtlas("notes/" + lastSkinName, SPARROW);
		addAnimPrefix("static", laneName + ' static', 24, true);
		addAnimPrefix("confirm", laneName + ' confirm');
		addAnimPrefix("press", laneName + ' press');

		playAnim("static");
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

	override function update(dt:Float)
	{
		super.update(dt);
		if (resetAnim != 0)
		{
			resetAnim -= dt;
			if (resetAnim < 0)
			{
				resetAnim = 0;
				playAnim("static");
			}
		}
	}
}
