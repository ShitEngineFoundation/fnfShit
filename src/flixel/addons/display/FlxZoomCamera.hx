package flixel.addons.display;

import flixel.FlxCamera;
import flixel.math.FlxMath;

/**
 * FlxZoomCamera: A FlxCamera that centers its zoom on the target that it follows
 *
 * @link http://www.kwarp.com
 * @author greglieberman, edited by LeonGamerPS1
 * @email greg@kwarp.com
 */
class FlxZoomCamera extends FlxCamera
{
	/**
	 * Tell the camera to LERP here eventually
	 */
	public var targetZoom:Float;

	/**
	 * This number is pretty arbitrary, make sure it's greater than zero!
	 */
	public var zoomSpeed:Float = 25;

	public function new(X:Int, Y:Int, Width:Int, Height:Int, Zoom:Float = 0)
	{
		super(X, Y, Width, Height, FlxCamera.defaultZoom);
		targetZoom = Zoom;
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// Update camera zoom
		zoom += (targetZoom - zoom) / 2 * elapsed * zoomSpeed;
	}
}
