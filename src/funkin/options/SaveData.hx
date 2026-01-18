package funkin.options;

import lime.app.Application;

@:structInit
class OptionSaveData
{
	// gameplay
	public var antialias:Bool = false;
	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;
	public var noteCamMovement:Bool = true;
	public var fps:Float = 64;

	//UI and Looks
	public var hideIcons:Bool = false;
	public var hideUI:Bool = false;
	public var opponentNotes:Bool = true;
	public var opaqueHolds:Bool = false;
	public var noteSplashes:Bool = true;
	public var opponentNoteSplashes:Bool = false;
	public var fpsCounter:Bool = true;
}

class SaveData
{
	static public var defaultSettings:OptionSaveData = {};
	static public var currentSettings:OptionSaveData = {};

	public static function setVal(name:String, val:Dynamic)
	{
		try
		{
			Reflect.setProperty(currentSettings, name, val);
		}
		catch (e:Dynamic)
		{
			Application.current.window.alert(Std.string(e), 'Error');
		}
		FlxG.save.flush();
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
