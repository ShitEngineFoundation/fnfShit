package funkin.menus.options;

import funkin.menus.options.optionobjs.OptionCheckbox;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.plugin.taskManager.FlxTask;
import funkin.options.Option;

class BaseOptionCat extends FlxTransitionableState
{
	public var options:Array<Option> = [];
	public var itemIndex = 0;
	public var optionsGroup:FlxTypedGroup<Option>;
	public var curSelected(get, null):Option;
	public var camTarget:FlxObject;

	public function new()
	{
		super();
		persistentDraw = persistentUpdate = true;
		var bg:FlxBackdrop = new FlxBackdrop(Paths.getGraphic("menus/menuDesat"), XY, 0, 0);
		bg.velocity.set(-20, 0);
		add(bg);

		optionsGroup = new FlxTypedGroup();
		add(optionsGroup);

		camTarget = new FlxObject(0, 0, 1, 1);

		add(camTarget);
	}

	override function create()
	{
		super.create();
		FlxG.camera.follow(camTarget, 0.06);
	}

	public function addOption(opName:String, option:Option)
	{
		options.push(option);

		option.intenName = opName;

		var optionName:Alphabet = new Alphabet(0, 0, option.intenName, true, false);
		option.add(optionName);

		optionsGroup.add(option);
		option.displayText = optionName;
		option.setPosition(0, 120 * optionsGroup.length);
		option.screenCenter(X);
		option.y += FlxG.height / 2;

		switch (option.type)
		{
			case BOOL:
				var checkbox:OptionCheckbox = new OptionCheckbox(option);
				option.add(checkbox);
			default:
				trace("type " + option.type.getName() + " has no display thing yet");
		}
		return option;
	}

	var canMoveBack = true;
	var trig = false;

	override function update(elapsed:Float)
	{
		if (!trig)
		{
			trig = true;
			changeSelected();
		}
		else
		{
			if (controls.justPressed.UI_DOWN)
				changeSelected(1);
			else if (controls.justPressed.NOTE_UP)
				changeSelected(-1);
		}
		super.update(elapsed);
		if (controls.justPressed.UI_BACK && canMoveBack)
			FlxG.switchState(new OptionsState());
	}

	public function changeSelected(addition:Int = 0)
	{
		if (addition != 0)
			FlxG.sound.play(Paths.getSound("sounds/scrollMenu"));

		itemIndex += addition;
		itemIndex = FlxMath.wrap(itemIndex, 0, optionsGroup.length - 1);

		camTarget.setPosition(curSelected.getMidpoint().x, curSelected.getMidpoint().y);
		optionsGroup.forEachAlive((o) ->
		{
			o.alpha = o == curSelected ? 1 : 0.5;

			o.selected = o == curSelected;
		});
	}

	function get_curSelected():Option
	{
		return optionsGroup.members[itemIndex];
	}
}
