package funkin.menus.options;

import funkin.options.Option;

class UI_and_Looks extends BaseOptionCat
{
	public override function create()
	{
		super.create();
		addOption("Hide Icons", new Option("hideIcons", BOOL));
    	addOption("Hide UI", new Option("hideUI", BOOL));
		addOption("Show Opponent Notes", new Option("opponentNotes", BOOL));
		addOption("Opaque Holds", new Option("opaqueHolds", BOOL));
		addOption("Note Splashes", new Option("noteSplashes", BOOL));
		addOption("Opponent Note Splashes", new Option("opponentNoteSplashes", BOOL));
	}
}
