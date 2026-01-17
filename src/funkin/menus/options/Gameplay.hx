package funkin.menus.options;

import funkin.options.Option;

class Gameplay extends BaseOptionCat
{
	public override function create()
	{
		super.create();
		var alias = addOption("Antialiasing", new Option("antialias", BOOL));
		alias.onValChange.add((op) ->
		{
			FlxSprite.defaultAntialiasing = op.value;
		});
		addOption("Downscroll", new Option("downScroll", BOOL));
		addOption("Middlescroll", new Option("middleScroll", BOOL));
		addOption("Note Camera Movement", new Option("noteCamMovement", BOOL));
	}
}
