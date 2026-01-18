package;

import funkin.backend.FPSCounter;
import funkin.backend.system.InitState;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.DisplayObject;
import openfl.display.StageScaleMode;
import flixel.graphics.FlxGraphic;

#if windows
@:headerCode("
	#include <windows.h>
	#include <winuser.h>
")
#end
class Main extends Sprite
{
	public function new()
	{
		super();
		FlxG.signals.preStateSwitch.add(Conductor.clear);

		// FlxModding.reload(false);

		addChild(new FlxGame(1280, 720, InitState, 100, 100, true));
		addChild(new FPSCounter(10, 20));
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		registerAsDPICompatible();
		setFlxDefines();
	}

	function setFlxDefines()
	{
		#if FLX_MOUSE FlxG.mouse.visible = false; #end
		FlxG.cameras.useBufferLocking = true;
		FlxG.autoPause = false;
		FlxG.fixedTimestep = false;
		#if FLX_MOUSE FlxG.mouse.useSystemCursor = true; #end
	}

	#if windows
	@:functionCode('
        SetProcessDPIAware();
    ')
	#end
	public static function registerAsDPICompatible() {}

	#if !flash
	// Get rid of hit test function because mouse memory ramp up during first move (-Bolo)
	@:noCompletion override function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool
		return false;

	@:noCompletion override function __hitTestHitArea(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool,
			hitObject:DisplayObject):Bool
		return false;

	@:noCompletion override function __hitTestMask(x:Float, y:Float):Bool
		return false;
	#end
}
