package funkin.game;

import flixel.util.FlxSort;

typedef StrumLineGroup = FlxTypedSpriteGroup<Strum>;
typedef NoteGroup = FlxTypedGroup<Note>;

class GameplayState extends FlxTransitionableState
{
	static var self:GameplayState;

	public var camHUD:FlxCamera;
	public var hudElements:FlxGroup;

	public var opponentStrums:StrumLineGroup;
	public var playerStrums:StrumLineGroup;
	public var notes:NoteGroup;
	public var unspawnNotes:Array<Note> = [];

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
		if (Paths.getSound("songs/" + SONG.song + '/sound/Voices', true) != null)
			voices = FlxG.sound.load(Paths.getSound("songs/" + SONG.song + '/sound/Voices', true));
	}

	override public function create()
	{
		songSpeed = SONG.speed;
		bgColor = FlxColor.GRAY;
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
		hudElements.add(opponentStrums);

		playerStrums = new StrumLineGroup(100 + FlxG.width / 2, opponentStrums.y);
		generateStaticArrows(playerStrums);
		if (SaveData.currentSettings.middleScroll)
			playerStrums.screenCenter(X);
		hudElements.add(playerStrums);

		notes = new NoteGroup();
		hudElements.add(notes);

		generateNotes();
		Conductor.onBeat.add((b) ->
		{
			beatHit(Math.floor(b));
		});

		Conductor.onStep.add((b) ->
		{
			stepHit(Math.floor(b));
		});

		startCountdown();
	}

	public function beatHit(beat:Int)
	{
		notes.sort(sortNotesByTimeHelper, FlxSort.DESCENDING);
	}

	inline public static function sortNotesByTimeHelper(Order:Int, Obj1:Note, Obj2:Note)
		return FlxSort.byValues(Order, Obj1.time, Obj2.time);

	public function stepHit(step:Int)
	{
		if (step > 0 && voices != null && voices.playing)
		{
			if (Math.abs(voices.time - Conductor.songPosition) > 10)
				voices.time = Conductor.songPosition;
		}
	}

	function generateNotes()
	{
		for (n in unspawnNotes)
			n.destroy();
		unspawnNotes.resize(0);

		var oldBPM = Conductor.BPM;

		for (section in SONG.notes)
		{
			if (section.changeBPM)
				Conductor.BPM = section.bpm;
			final stepLength:Float = Conductor.stepLength;
			for (rawNote in section.sectionNotes)
			{
				var lane:Int = Math.floor(Math.abs(rawNote[1])) % 4;
				var mustHitNote = section.mustHitSection;
				var holdLength = rawNote[2] is String ? 0 : rawNote[2];
				if (rawNote[1] > 3)
					mustHitNote = !section.mustHitSection;
				var strum = mustHitNote ? playerStrums.members[lane] : opponentStrums.members[lane];

				var note:Note = new Note(lane, rawNote[0], mustHitNote, false, holdLength, unspawnNotes[unspawnNotes.length - 1], strum.lastSkinName);
				note.setPosition(-note.width * 2, -note.height * 2);
				unspawnNotes.push(note);

				if (holdLength > 0)
				{
					for (segmentID in 0...Math.floor(holdLength / stepLength))
					{
						final extra:Float = (stepLength * segmentID) + (stepLength / 2);
						var sustain:Note = new Note(lane, note.time + extra, mustHitNote, true, stepLength, unspawnNotes[unspawnNotes.length - 1],
							strum.lastSkinName);
						sustain.setPosition(-sustain.width * 2, -sustain.height * 2);
						unspawnNotes.push(sustain);
					}
				}
			}
		}
		Conductor.BPM = oldBPM;

		unspawnNotes.sort((n, n2) ->
		{
			return Math.floor(n.time - n2.time);
		});
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
		voices?.play();
	}

	public function startCountdown()
	{
		startedCountdown = true;
	}

	public var songSpeed:Float = 1;
	public var voices:FlxSound;

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
		else if (startedSong)
			Conductor.songPosition = FlxG.sound.music.time;

		if (unspawnNotes.length > 0)
		{
			var note:Note = unspawnNotes[0];
			if (note != null && note.time <= Conductor.songPosition + (1500 / songSpeed))
			{
				notes.insert(0, note);
				note.revive();
				unspawnNotes.remove(note);
			}
		}

		notes.forEachAlive((note:Note) ->
		{
			var strum = note.mustPress ? playerStrums.members[note.lane] : opponentStrums.members[note.lane];
			note.move(strum, songSpeed);

			if (!note.mustPress && note.time <= Conductor.songPosition && !note.hit)
			{
				strum.playAnim("confirm", true);
				strum.resetAnim = Conductor.stepLength * 1.5 / 1000;
				note.hit = true;
				if (!note.isSustainNote)
					killNote(note);
			}

			// deletes notes out of range and causes misses if it is too late to hit
			if (note.time <= Conductor.songPosition - (350))
			{
				if (!note.hit && note.mustPress)
					trace("miss");

				killNote(note);
			}
		});
		super.update(elapsed);
	}

	public function killNote(note:Note)
	{
		note.destroy();
		notes.remove(note, true);
	}
}
