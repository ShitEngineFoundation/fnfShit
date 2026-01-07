package funkin.menus;

class MainMenuState extends FlxState
{
	public static var items:Array<String> = ["story_mode", "freeplay", "credits", "options"];

	public var itemGroup:FlxTypedGroup<FunkinSprite>;
	public var itemIndex:Int = 0;

	public var bg:FunkinSprite;
	public var camTarget:FlxObject;

	public override function create()
	{
		super.create();
		bg = new FunkinSprite(0, -50, Paths.getGraphic("menus/menuDesat"));
		bg.scale.set(1.4, 1.4);
		bg.scrollFactor.set(0, 0.2);
		bg.updateHitbox();
		bg.antialiasing = true;
        bg.color = FlxColor.YELLOW;
		add(bg);

		itemGroup = new FlxTypedGroup<FunkinSprite>();
		add(itemGroup);

		camTarget = new FlxObject(0, 0, 1, 1);
		FlxG.camera.follow(camTarget, 0.06);
		add(camTarget);

		for (itemID in items)
		{
			var item:FunkinSprite = new FunkinSprite(0, 50);
			item.loadAtlas('menus/main/$itemID', SPARROW);
			item.addAnimPrefix('idle', '$itemID idle', 24, true);
			item.addAnimPrefix('selected', '$itemID selected', 24, true);
			item.playAnim("idle");
			item.updateHitbox();
			item.scrollFactor.y = 0.75;
			item.antialiasing = true;
			item.screenCenter(X);
			item.y += (230 * 0.7 * itemGroup.length);
			itemGroup.add(item);
		}
		changeSelected(0);
	}

	public function changeSelected(addition:Int = 0)
	{
		if (addition != 0)
			FlxG.sound.play(Paths.getSound("sounds/scrollMenu"));

		itemIndex += addition;
		itemIndex = FlxMath.wrap(itemIndex, 0, itemGroup.length - 1);
		var sprite = itemGroup.members[itemIndex];
		camTarget.setPosition(sprite.getMidpoint().x, sprite.getMidpoint().y);
		itemGroup.forEachAlive((o) ->
		{
			o.playAnim(o == sprite ? 'selected' : 'idle');
			o.updateHitbox();
			o.screenCenter(X);
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.justPressed.UI_DOWN)
			changeSelected(1);
		else if (controls.justPressed.NOTE_UP)
			changeSelected(-1);
	}
}
