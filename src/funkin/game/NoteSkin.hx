package funkin.game;

import haxe.Json;

typedef NoteSkinConfig =
{
	var scale:Float;
	var antialiasing:Bool;
}

class NoteSkin
{
	static var skins:Map<String, NoteSkinConfig> = new Map<String, NoteSkinConfig>();

	public static function getSkin(name:String = "NOTE_assets")
	{
		var skinPath = Paths.getPath("images/notes/" + name + '.json');
		if (!OpenFLAssets.exists(skinPath))
		{
			FlxG.log.warn("f.game.NoteSkin: " + name + ' not found, default selected instead');
			name = "NOTE_assets";
			return getSkin();
		}

		if (skins.exists(name))
			return skins.get(name);

		var skinD = Json.parse(OpenFLAssets.getText(skinPath));
		skins.set(name, skinD);
		return skinD;
	}
}
