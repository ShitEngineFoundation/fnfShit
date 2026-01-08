package funkin.menus.options;

import funkin.options.Option;

class Gameplay extends BaseOptionCat
{
	public override function create()
	{
		super.create();
		addOption("Downscroll", new Option("downscroll", BOOL));
        addOption("Middlescroll", new Option("middlescroll", BOOL));
	}
}
