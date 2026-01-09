package funkin.game;

typedef StrumLineGroup = FlxTypedSpriteGroup<Strum>;

class GameplayState extends FlxTransitionableState
{
	static var self:GameplayState;

	public var camHUD:FlxCamera;
	public var hudElements:FlxGroup;

	public var opponentStrums:StrumLineGroup;
	public var playerStrums:StrumLineGroup;

	static public var SONG:SwagSong;

	public function new(?song:SwagSong)
	{
		song ??= Song.loadFromJson();
		super();
		self = this;

		hudElements = new FlxGroup();
		FlxG.sound.music.stop();
		if (song != null)
			SONG = song;

		FlxG.sound.music.load(Paths.getSound("songs/" + SONG.song + '/sound/Inst', true));
	}

	public override function create()
	{
		Conductor.mapBPMChanges(SONG);
		Conductor.BPM = SONG.bpm;
		Conductor.songPosition = -Conductor.stepLength * 5;
		super.create();

		camHUD = new FlxCamera();
		camHUD.bgColor = 0x0;
		FlxG.cameras.add(camHUD, false);

		hudElements.cameras = [camHUD];
		add(hudElements);

		opponentStrums = new StrumLineGroup(100, SaveData.currentSettings.downScroll ? FlxG.height - 150 : 50);
		generateStaticArrows(opponentStrums);
		opponentStrums.alpha = SaveData.currentSettings.middleScroll ? 0 : 1;
		add(opponentStrums);

		playerStrums = new StrumLineGroup(100 + FlxG.width / 2, opponentStrums.y);
		generateStaticArrows(playerStrums);
		if (SaveData.currentSettings.middleScroll)
			playerStrums.screenCenter(X);
		add(playerStrums);

		startCountdown();
	}

	public function generateStaticArrows(group:StrumLineGroup, ?skin:String = "NOTE_assets")
	{
		for (mem in group)
			mem.destroy();
		group.clear();
		for (i in 0...4)
		{
			var strum:Strum = new Strum(i, skin);
			strum.downScroll = SaveData.currentSettings.downScroll;
			strum.x = (160 * 0.7 * i);
			group.add(strum);
		}
	}

	public var startedSong:Bool = false;
	public var startedCountdown:Bool = false;

	public function startSong()
	{
		startedSong = true;
		FlxG.sound.music.play();
	}

	public function startCountdown()
	{
		startedCountdown = true;
	}

	override function update(elapsed:Float)
	{
		if (!startedSong && startedCountdown)
		{
			Conductor.songPosition += elapsed * 1000;
			if (Conductor.songPosition >= 0)
			{
				startSong();
				Conductor.songPosition = FlxG.sound.music.time;
			}
		}
		if (startedSong)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}
}
