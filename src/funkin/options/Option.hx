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
	public var intenName = ""; // display name
	public var selected:Bool = false;
	public var displayText:FlxSprite;

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
		FlxG.sound.play(Paths.getSound("sounds/confirmMenu"));
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

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		switch (type)
		{
			case BOOL:
				if (selected && controls.justPressed.UI_ACCEPT)
				{
					value = !value;
					upload();
				}
			default: // here so the compiler doesnt nag about Unmatched patterns: FLOAT | INT | STRING
		}
	}
}
