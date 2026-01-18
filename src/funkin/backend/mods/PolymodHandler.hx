package funkin.backend.mods;

import polymod.format.ParseRules;
import polymod.Polymod;

class PolymodHandler
{
	static public var modROOT:String = "./mods";

	public static function init()
	{
		var mods = Polymod.scan({
			modRoot: modROOT
		});
		var modIDS:Array<String> = [];

		for (mod in mods)
			if (mod != null)
				modIDS.push(mod.id);

		Polymod.init({
			modRoot: modROOT,
			dirs: modIDS,
			framework: OPENFL,
			parseRules: getParseRules(),
            useScriptedClasses: true
		});
	}

	public static function getParseRules()
	{
		var rules = ParseRules.getDefault();
		rules.addType('txt', TextFileFormat.LINES);
		rules.addType('hscript', TextFileFormat.PLAINTEXT);
		rules.addType('hxs', TextFileFormat.PLAINTEXT);
		rules.addType('hxc', TextFileFormat.PLAINTEXT);
		rules.addType('hx', TextFileFormat.PLAINTEXT);
		return rules;
	}
}
