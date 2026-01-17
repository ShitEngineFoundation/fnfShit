package funkin.menus;

import funkin.game.GameplayState;

class OptionsState extends FlxTransitionableState
{
	var categories = ['gameplay', 'visuals and ui'];
	var curSelected:Alphabet;
	var itemIndex:Int = 0;
	var itemGroup:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();

	override function create()
	{
		super.create();
		var bg:FunkinSprite = new FunkinSprite(0, 0, Paths.getGraphic("menus/menuDesat"));
		add(bg);

		add(itemGroup);

		for (catName in categories)
		{
			var text:Alphabet = new Alphabet(0, 0, catName, true);
			text.screenCenter(X);
			text.y += (100 * itemGroup.length);
			text.antialiasing = true;
			itemGroup.add(text);
		}

		changeSelected(0);
	}

	function changeSelected(addition:Int)
	{
		if (addition != 0)
			FlxG.sound.play(Paths.getSound("sounds/scrollMenu"));

		itemIndex += addition;
		itemIndex = FlxMath.wrap(itemIndex, 0, itemGroup.length - 1);
		var sprite = itemGroup.members[itemIndex];
		itemGroup.forEachAlive((o) ->
		{
			o.alpha = o == sprite ? 1 : 0.5;
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
		else if (controls.justPressed.UI_BACK)
			FlxG.switchState(new MainMenuState());
		else if (controls.justPressed.UI_ACCEPT)
		{
			FlxG.sound.play(Paths.getSound("sounds/confirmMenu"));
			switch (categories[itemIndex])
			{
				case "gameplay":
					FlxG.switchState(new funkin.menus.options.Gameplay());
				case "visuals and ui":
					FlxG.switchState(new funkin.menus.options.UI_and_Looks());
			}
		}
	}
}
