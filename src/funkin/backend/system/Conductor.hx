package funkin.backend.system;

import funkin.game.Song.SwagSong;
import flixel.util.FlxSignal;

typedef BPMChangeEvent =
{
	var stepTime:Float;
	var songTime:Float;
	var bpm:Float;
}

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

	public static var timeChanges:Array<BPMChangeEvent> = [];

	public static var lastTimeChange = null;

	// ripped from basegame lol
	public static function mapBPMChanges(song:SwagSong)
	{
		timeChanges.resize(0);

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				timeChanges.push(event);
			}

			var deltaSteps:Int = 16;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}

		trace("new BPM map BUDDY " + timeChanges);
	}

	public static function set_songPosition(value:Float):Float
	{
		if (value == __lastPos)
			return songPosition;

		__lastPos = value;
		songPosition = value;

		updateStep();
		updateBeat();
		updateMeasure();

		return value;
	}

	public static function clear()
	{
		onStep.removeAll();
		onBeat.removeAll();
		onMeasure.removeAll();
		BPM = 100;
		songPosition = 0;
		timeChanges.resize(0);
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
		measureCount = stepCount / 16;
		var newMeasure:Float = Math.floor(measureCount);
		if (lastMeasure != newMeasure)
			onMeasure.dispatch(measureCount);
	}

	private static function updateBeat()
	{
		// lastTimeChange = lastChange;
		var lastBeat:Float = Math.floor(beatCount);
		beatCount = stepCount / 4;
		var newBeat:Float = Math.floor(beatCount);
		if (lastBeat != newBeat)
			onBeat.dispatch(beatCount);
	}

	private static function updateStep()
	{
		var lastStep:Float = Math.floor(stepCount);
		stepCount = lastTimeChange.stepTime + ((songPosition - lastTimeChange.songTime) / Conductor.stepLength);

		var newStep:Float = Math.floor(stepCount);
		if (lastStep != newStep)
			onStep.dispatch(stepCount);
	}
}
