package funkin.backend;

import flixel.system.FlxAssets.FlxGraphicAsset;

enum AtlasType
{
	SPARROW;
	ANIMATE;
}

class FunkinSprite extends OffsetSprite
{
	public function new(x:Float, y:Float, ?graphic:FlxGraphicAsset)
	{
		super(x, y, graphic);
		useRenderTexture = true; // glup glup glup
	}

	public function addAnimPrefix(name:String, prefix:String, ?frameRate = 24.0, ?looped = false, ?flipX = false, ?flipY = false)
	{
		if (!isAnimate)
			animation.addByPrefix(name, prefix, frameRate, looped, flipX, flipY);
		else
			anim.addBySymbol(name, prefix, frameRate, looped, flipX, flipY);
	}

	public function addAnimIndices(Name:String, Prefix:String, Indices:Array<Int>, ?Postfix:String, ?FrameRate:Float = 24.0, ?Looped:Bool = false,
			?FlipX:Bool = false, ?FlipY:Bool = false)
	{
		if (!isAnimate)
			animation.addByIndices(Name, Prefix, Indices, Postfix, FrameRate, Looped, flipX, flipY);
		else
			anim.addBySymbolIndices(Name, Prefix, Indices, FrameRate, Looped, flipX, flipY);
	}

	public function loadAtlas(atlasName:String, type:AtlasType)
	{
		if (type == ANIMATE)
			frames = Paths.getAnimateAtlas(atlasName);
		else
			frames = Paths.getSparrowAtlas(atlasName);
	}
}
