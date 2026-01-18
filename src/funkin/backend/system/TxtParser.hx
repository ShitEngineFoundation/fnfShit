package funkin.backend.system;

class TxtParser
{
	public static function parseSongList(path:String):Map<String, Int>
	{
		var contents = OpenFLAssets.getText(path).trim();
		var lines = contents.split("\n");

		var result = new Map<String, Int>();

		for (line in lines)
		{
			line = line.trim();

			// ignore empty lines and comments
			if (line.length == 0 || line.startsWith("#"))
				continue;

			var parts = line.split(":");
			if (parts.length != 2)
				continue;

			var key = parts[0].trim();
			var value = Std.parseInt(parts[1].trim());

			if (value != null)
				result.set(key, value);
		}

		return result;
	}
}
