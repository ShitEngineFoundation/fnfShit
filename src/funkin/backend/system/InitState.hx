package funkin.backend.system;

import funkin.options.SaveData;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileCircle;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;

class InitState extends FlxTransitionableState
{
	public override function create()
	{
		super.create();
		SaveData.init();
		
		controls = new funkin.backend.system.Controls("FNFControls");
		FlxG.inputs.addInput(controls);




		var dia = FlxGraphic.fromClass(GraphicTransTileCircle);
		FlxTransitionableState.defaultTransIn = new TransitionData(FADE,FlxColor.BLACK,0.5,FlxPoint.get(0,-1),{asset:dia,width: 32,height: 32,frameRate:122},FlxRect.get(0,0,FlxG.width,FlxG.height),NEW);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE,FlxColor.BLACK,0.5,FlxPoint.get(0,1),{asset:dia,width: 32,height: 32,frameRate: 122},FlxRect.get(0,0,FlxG.width,FlxG.height),NEW);
		FlxG.switchState(new funkin.menus.TitleState());
	}
}
