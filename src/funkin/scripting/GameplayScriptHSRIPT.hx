package funkin.scripting;

import funkin.game.Note;
import flixel.addons.display.FlxBackdrop;
import hscript.Parser;
import hscript.Interp;

class GameplayScriptHSRIPT
{
	public var interp:Interp;
	public var parser:Parser;
	public var name:String;

	// stuff that gets auto imported into every script
	public static var scriptImports:Map<String, Class<Dynamic>> = [
		// shit
		"Note" => Note,
		"Conductor" => Conductor,
		// =====================================================
		// FLIXEL CORE
		// =====================================================
		"FlxG" => flixel.FlxG,
		"FlxGame" => flixel.FlxGame,
		"FlxState" => flixel.FlxState,
		"FlxSubState" => flixel.FlxSubState,
		"FlxBasic" => flixel.FlxBasic,
		"FlxObject" => flixel.FlxObject,
		// =====================================================
		// FLIXEL SPRITES / GROUPS
		// =====================================================
		"FlxSprite" => flixel.FlxSprite,
		"FlxText" => flixel.text.FlxText,
		"FlxSpriteGroup" => flixel.group.FlxSpriteGroup,
		"FlxTypedSpriteGroup" => flixel.group.FlxTypedSpriteGroup,
		"FlxGroup" => flixel.group.FlxGroup,
		"FlxTypedGroup" => flixel.group.FlxTypedGroup,
		// =====================================================
		// CAMERAS
		// =====================================================
		"FlxCamera" => flixel.FlxCamera,
		// =====================================================
		// TILEMAPS
		// =====================================================
		"FlxTilemap" => flixel.tile.FlxTilemap,
		"FlxBaseTilemap" => flixel.tile.FlxBaseTilemap,
		"FlxTile" => flixel.tile.FlxTile,
		// =====================================================
		// INPUT
		// =====================================================
		"FlxInput" => flixel.input.FlxInput,
		"FlxKeyboard" => flixel.input.keyboard.FlxKeyboard,
		"FlxMouse" => flixel.input.mouse.FlxMouse,
		"FlxGamepad" => flixel.input.gamepad.FlxGamepad,
		// =====================================================
		// AUDIO
		// =====================================================
		"FlxSound" => flixel.sound.FlxSound,
		"FlxSoundGroup" => flixel.sound.FlxSoundGroup,
		// =====================================================
		// TWEENS / EFFECTS
		// =====================================================
		"FlxTween" => flixel.tweens.FlxTween,
		"FlxEase" => flixel.tweens.FlxEase,
		// =====================================================
		// MATH / GEOMETRY
		// =====================================================
		"FlxMath" => flixel.math.FlxMath,
		"FlxRect" => flixel.math.FlxRect,
		"FlxRandom" => flixel.math.FlxRandom,
		"Math" => Math,
		// =====================================================
		// UTIL
		// =====================================================
		"FlxTimer" => flixel.util.FlxTimer,
		"FlxSort" => flixel.util.FlxSort,
		"FlxSave" => flixel.util.FlxSave,
		"FlxStringUtil" => flixel.util.FlxStringUtil,
		// =====================================================
		// FLIXEL SYSTEM
		// =====================================================
		"FlxAssets" => flixel.system.FlxAssets,
		"FlxVersion" => flixel.system.FlxVersion,
		// =====================================================
		// FLIXEL ADDONS – DISPLAY
		// =====================================================
		"FlxBackdrop" => flixel.addons.display.FlxBackdrop,
		"FlxGridOverlay" => flixel.addons.display.FlxGridOverlay,
		"FlxRuntimeShader" => flixel.addons.display.FlxRuntimeShader,
		// =====================================================
		// FLIXEL ADDONS – EFFECTS
		// =====================================================
		"FlxTrail" => flixel.addons.effects.FlxTrail,
		// =====================================================
		// FLIXEL UI
		// =====================================================
		"FlxButton" => flixel.ui.FlxButton,
		"FlxBar" => flixel.ui.FlxBar,
		"FlxVirtualPad" => flixel.ui.FlxVirtualPad,
		// =====================================================
		// OPENFL DISPLAY
		// =====================================================
		"DisplayObject" => openfl.display.DisplayObject,
		"DisplayObjectContainer" => openfl.display.DisplayObjectContainer,
		"Sprite" => openfl.display.Sprite,
		"Bitmap" => openfl.display.Bitmap,
		"BitmapData" => openfl.display.BitmapData,
		"Shape" => openfl.display.Shape,
		"Graphics" => openfl.display.Graphics,
		"Stage" => openfl.display.Stage,
		// =====================================================
		// OPENFL EVENTS
		// =====================================================
		"Event" => openfl.events.Event,
		"MouseEvent" => openfl.events.MouseEvent,
		"KeyboardEvent" => openfl.events.KeyboardEvent,
		"TouchEvent" => openfl.events.TouchEvent,
		"FocusEvent" => openfl.events.FocusEvent,
		// =====================================================
		// OPENFL GEOM
		// =====================================================
		"Point" => openfl.geom.Point,
		"Rectangle" => openfl.geom.Rectangle,
		"Matrix" => openfl.geom.Matrix,
		"ColorTransform" => openfl.geom.ColorTransform,
		// =====================================================
		// OPENFL TEXT
		// =====================================================
		"TextField" => openfl.text.TextField,
		"TextFormat" => openfl.text.TextFormat,
		// =====================================================
		// OPENFL SYSTEM / UTILS
		// =====================================================
		"Assets" => openfl.utils.Assets,
		"Lib" => openfl.Lib,
		"Capabilities" => openfl.system.Capabilities,
		"System" => openfl.system.System,
		// =====================================================
		// LIME (because why not)
		// =====================================================
		"Application" => lime.app.Application,
		"Window" => lime.ui.Window,
		// =====================================================
		// HAXE CORE / STD
		// =====================================================
		"Std" => Std,
		"StringTools" => StringTools,
		"Reflect" => Reflect,
		"Type" => Type,
		"Date" => Date,
		"EReg" => EReg,
		#if sys
		// =====================================================
		// SYS (danger zone 😬)
		// =====================================================
		"FileSystem" => sys.FileSystem, "File" => sys.io.File, "Process" => sys.io.Process,
		#end
		"Paths" => Paths
	];

	public function new(path:String, ?vars:Array<Array<Dynamic>>)
	{
		name = path;
		interp = new Interp();
		parser = new Parser();

		interp.execute(parser.parseString(OpenFLAssets.getText(path)));

		for (imp in scriptImports.keyValueIterator())
			set(imp.key, imp.value);

		set('this', this);
		set('state', FlxG.state);
		set('mathabs', (v:Float) -> return Math.abs(v));

		call('new');
	}

	public function set(vari:String, val:Dynamic)
	{
		interp.variables.set(vari, val);
	}

	public function get(vari:String):Dynamic
	{
		return interp.variables.get(vari);
	}

	public static var emptyArgs:Array<Dynamic> = [];

	public function call(func:String, ?args:Array<Dynamic>):Dynamic
	{
		var func = get(func);

		var val = func != null ? Reflect.callMethod(this, func, args ?? emptyArgs) : null;
		return val;
	}

	public function destroy()
	{
		interp = null;
		parser = null;
	}
}
