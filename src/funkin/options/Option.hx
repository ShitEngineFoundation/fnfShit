package funkin.options;

import flixel.util.FlxSignal;

enum OptionType
{
	BOOL;
	INT;
	FLOAT;
	STRING(options:Array<String>);
}

class Option extends FlxSpriteGroup
{
	public var saveName:String;
	public var type:OptionType;
	public var value:Dynamic;
	public var basic:FlxBasic;
	public var intenName = "";

	public var onValChange:FlxTypedSignal<Option->Void> = new FlxTypedSignal<Option->Void>();

	public function new(saveName:String, type:OptionType)
	{
		super();
		this.saveName = saveName;
		this.type = type;
		value = Reflect.getProperty(SaveData.currentSettings, saveName);
	}

	public function upload()
	{
		SaveData.setVal(saveName, value);
		onValChange.dispatch(this);
	}

	public override function reset(x, y)
	{
		SaveData.setVal(saveName, Reflect.getProperty(SaveData.defaultSettings, saveName));
		value = Reflect.getProperty(SaveData.defaultSettings, saveName);
		onValChange.dispatch(this);
	}

	override function destroy()
	{
		basic = null;
		onValChange.removeAll();
		onValChange = null;
		super.destroy();
	}
}
