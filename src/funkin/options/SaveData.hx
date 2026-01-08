package funkin.options;

import lime.app.Application;

@:structInit
class OptionSaveData
{
	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;
}

class SaveData
{
	static public var defaultSettings:OptionSaveData = {};
	static public var currentSettings:OptionSaveData = {};

	public static function setVal(name:String, val:Dynamic)
	{
		if (Reflect.hasField(currentSettings, name))
			Reflect.setProperty(currentSettings, name, val);
		else
			FlxG.log.error("SaveData: save variable " + name + 'does not exist');
	}

	public static function init()
	{
		Application.current.onExit.add((_) ->
		{
			for (field in Reflect.fields(currentSettings))
			{
				Reflect.setField(FlxG.save.data, field, Reflect.getProperty(currentSettings, field));
			}
			FlxG.save.flush();
		}, false, 999);

		for (field in Reflect.fields(defaultSettings))
		{
			if (Reflect.hasField(FlxG.save.data, field))
			{
				setVal(field, Reflect.getProperty(FlxG.save.data, field));
			}
		}
	}
}
