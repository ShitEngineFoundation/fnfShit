package funkin.backend.system;

class InitState extends FlxState
{
	public override function create()
	{
		super.create();
		controls = new funkin.backend.system.Controls("FNFControls");
		FlxG.inputs.addInput(controls);

		FlxG.switchState(new funkin.menus.TitleState());
	}
}
