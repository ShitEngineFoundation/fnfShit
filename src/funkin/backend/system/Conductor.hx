package funkin.backend.system;

import flixel.util.FlxSignal;

class Conductor
{
	public static var onStep:FlxTypedSignal<Float->Void> = new FlxTypedSignal<Float->Void>(); // every 4th of a beat
	public static var onBeat:FlxTypedSignal<Float->Void> = new FlxTypedSignal<Float->Void>(); // every beat
	public static var onMeasure:FlxTypedSignal<Float->Void> = new FlxTypedSignal<Float->Void>(); // every 4 beats

	public static var measureLength:Float = 0;
	public static var beatLength:Float = 0;
	public static var stepLength:Float = 0;

	public static var measureCount:Float = 0;
	public static var beatCount:Float = 0;
	public static var stepCount:Float = 0;

	public static var BPM(default, set):Float = 0;
	public static var songPosition(default, set):Float = 0;

	static private var __lastPos:Float = 0; // last position

	public static function set_songPosition(value:Float):Float
	{
		if (value == __lastPos)
			return songPosition;

		__lastPos = value;

		updateStep();
		updateBeat();
		updateMeasure();

		return songPosition = value;
	}

	public static function clear()
	{
		onStep.removeAll();
		onBeat.removeAll();
		onMeasure.removeAll();
		BPM = 100;
		songPosition = 0;
	}

	public static function isInRange(time:Float = 0, range:Float = 0)
	{
		return Math.abs(time - songPosition) < range;
	}

	public static function set_BPM(value:Float):Float
	{
		if (value == BPM)
			return value;

		BPM = value;
		beatLength = (60 / BPM) * 1000;
		stepLength = beatLength / 4;
		measureLength = beatLength * 4; // 4 beats per measure

		return BPM;
	}

	private static function updateMeasure()
	{
		var lastMeasure:Float = Math.floor(measureCount);
		measureCount = songPosition / measureLength;
		var newMeasure:Float = Math.floor(measureCount);
		if (lastMeasure != newMeasure)
			onMeasure.dispatch(measureCount);
	}

	private static function updateBeat()
	{
		var lastBeat:Float = Math.floor(beatCount);
		beatCount = songPosition / beatLength;
		var newBeat:Float = Math.floor(beatCount);
		if (lastBeat != newBeat)
			onBeat.dispatch(beatCount);
	}

	private static function updateStep()
	{
		var lastStep:Float = Math.floor(stepCount);
		stepCount = songPosition / stepLength;
		var newStep:Float = Math.floor(stepCount);
		if (lastStep != newStep)
			onStep.dispatch(stepCount);
	}
}
