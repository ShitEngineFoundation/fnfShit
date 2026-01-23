package funkin.game.judgement;

class JudgementHandler
{
	// rating name - range - breaksCombo - splashes - misses
	public static var judgements:Array<Judgement> = [
		new Judgement("sick", Conductor.safeZoneOffset * 0.15, 350, false, true, false),
		new Judgement("good", Conductor.safeZoneOffset * 0.2, 200, false, false, false),
		new Judgement("bad", Conductor.safeZoneOffset * 0.75, 100, true, false, false),
		new Judgement("shit", Conductor.safeZoneOffset * 0.9, 25, true, false, true)
	];

	public static var SusRating:Judgement = new Judgement("sustain", 0, 0, false, false, false);

	public static function getJudgementFromNote(note:Note):Judgement
	{
		var noteDiff:Float = Math.abs(note.time - Conductor.songPosition);
		for (j in 0...judgements.length)
		{
			var J = judgements[j];
			if (noteDiff > J.ms)
				return J;
		}
		return judgements[judgements.length - 1];
	}
}
