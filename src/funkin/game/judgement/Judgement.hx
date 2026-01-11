package funkin.game.judgement;

class Judgement
{
	public var name:String = "sick";
	public var ms:Float = Conductor.safeZoneOffset * 0.17;
	public var score:Float = 350;
	public var misses:Bool = false;
	public var breaksCombo:Bool = false;
	public var splashes:Bool = true;

	public function new(name:String, ms:Float, score:Float, breaksC:Bool, splash:Bool, misses:Bool)
	{
		this.name = name;
		this.ms = ms;
		this.score = score;
		this.breaksCombo = breaksC;
		this.splashes = splash;
	}
}
