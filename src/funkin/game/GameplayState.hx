package funkin.game;

import funkin.scripting.GameplayScriptHSRIPT;
import haxe.Json;
import funkin.game.stages.*;
#if modchart import modchart.Manager; #end
import funkin.game.stage.Character;
import funkin.game.judgement.Judgement;
import funkin.game.judgement.JudgementHandler;
import funkin.game.sub.PauseSubState;
import flixel.addons.display.FlxZoomCamera;
import flixel.ui.FlxBar;
import flixel.util.FlxSort;

typedef StrumLineGroup = FlxTypedSpriteGroup<Strum>;
typedef NoteGroup = FlxTypedGroup<Note>;

typedef StageJSON =
{
	var zoom:Float;
	var bf:Array<Int>;
	var gf:Array<Int>;
	var dad:Array<Int>;
}

class GameplayState extends FlxTransitionableState
{
	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var camFollow:FlxObject = new FlxObject(0, 0, 1, 1);

	public static var self:GameplayState;

	public var camHUD:FlxCamera;
	public var hudElements:FlxGroup;

	public var opponentStrums:StrumLineGroup;
	public var playerStrums:StrumLineGroup;
	public var notes:NoteGroup;
	public var unspawnNotes:Array<Note> = [];

	static public var SONG:SwagSong;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	public var health:Float = 1;
	public var misses:Int = 0;

	public var dad:Character;
	public var gf:Character;
	public var bf:Character;

	#if modchart public var funkin_modchart_instance:Manager; #end
	public var curStage:String;
	public var stageJSON:StageJSON;

	public var scripts:Array<GameplayScriptHSRIPT> = [];

	public function new()
	{
		super();
		self = this;
		Paths.getSparrowAtlas("noteSplashes");

		hudElements = new FlxGroup();
		FlxG.sound.music.stop();
		SONG ??= Song.loadFromJson();

		dad = new Character(SONG.player2);
		gf = new Character(SONG.gfVersion ?? 'gf');
		bf = new Character(SONG.player1, true);

		if (gf.curCharacter == dad.curCharacter)
			gf.visible = false;

		curStage = SONG.stage ?? getDefaultStageCheck(SONG.song);
		var s = Paths.getPath("data/stages/" + curStage) + '.json';
		if (!OpenFLAssets.exists(s))
			curStage = 'stage';
		s = Paths.getPath("data/stages/" + curStage) + '.json';
		stageJSON = cast Json.parse(OpenFLAssets.getText(s));

		// dad
		DAD_X = stageJSON.dad[0];
		DAD_Y = stageJSON.dad[1];

		// gf
		GF_X = stageJSON.gf[0];
		GF_Y = stageJSON.gf[1];

		// gf
		BF_X = stageJSON.bf[0];
		BF_Y = stageJSON.bf[1];

		#if modchart funkin_modchart_instance = new Manager(); #end
	}

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var nSplashes:FlxTypedGroup<NoteSplash>;

	override public function create()
	{
		// preload stuff
		FlxG.sound.music.loadEmbedded(Paths.getSound("songs/" + SONG.song + '/sound/Inst', true));
		voices = FlxG.sound.load(Paths.getSound("songs/" + SONG.song + '/sound/Voices', true));

		// set up stuff
		persistentDraw = persistentUpdate = true;
		FlxG.cameras.reset(camGame = new FlxZoomCamera(0, 0, FlxG.width, FlxG.height, 1));

		songSpeed = SONG.speed;
		bgColor = FlxColor.GRAY;
		Conductor.mapBPMChanges(SONG);
		Conductor.BPM = SONG.bpm;
		Conductor.songPosition = -Conductor.stepLength * 5;

		super.create();

		var stageCheck = SONG.stage ?? getDefaultStageCheck(SONG.song);
		curStage = stageCheck;

		switch (stageCheck)
		{
			case 'spooky':
				currentStage = new Week2();
			case 'philly':
				currentStage = new Week3();

			default:
				camGame.targetZoom = 0.9;

				currentStage = new Week1();
		}

		currentStage?.create();
		if (currentStage != null)
			add(currentStage);

		add(gf);
		add(dad);
		add(bf);

		bf.setPosition(BF_X, BF_Y);
		dad.setPosition(DAD_X, DAD_Y);
		gf.setPosition(GF_X, GF_Y);

		for (char in [dad, bf, gf])
		{
			char.x += char.json.pos_offset[0];
			char.y += char.json.pos_offset[1];
		}

		// set up camhud
		camHUD = new FlxZoomCamera(0, 0, FlxG.width, FlxG.height, 1);
		camHUD.bgColor = 0x0;
		FlxG.cameras.add(camHUD, false);

		for (camera in FlxG.cameras.list)
			if (camera is FlxZoomCamera)
				cast(camera, FlxZoomCamera).zoomSpeed = 12.5;
		camGame.targetZoom = camGame.zoom = stageJSON.zoom;

		hudElements.cameras = [camHUD];
		add(hudElements);

		// make them grey arrows appear
		opponentStrums = new StrumLineGroup(50, SaveData.currentSettings.downScroll ? FlxG.height - 150 : 50);
		generateStaticArrows(opponentStrums);
		opponentStrums.alpha = SaveData.currentSettings.middleScroll || !SaveData.currentSettings.opponentNotes ? 0 : 1;
		hudElements.add(opponentStrums);

		playerStrums = new StrumLineGroup(50 + FlxG.width / 2, opponentStrums.y);
		generateStaticArrows(playerStrums);
		if (SaveData.currentSettings.middleScroll)
			playerStrums.screenCenter(X);
		hudElements.add(playerStrums);
		nSplashes = new FlxTypedGroup<NoteSplash>();
		hudElements.add(nSplashes);

		#if modchart hudElements.add(funkin_modchart_instance); #end

		notes = new NoteGroup();
		hudElements.add(notes);

		healthBarBG = new FlxSprite(0, FlxG.height * 0.89).loadGraphic(Paths.getGraphic('healthBar'));
		healthBarBG.screenCenter(X);

		if (SaveData.currentSettings.downScroll)
			healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x, healthBarBG.y, RIGHT_TO_LEFT, Std.int(healthBarBG.width), Std.int(healthBarBG.height), this, 'health', 0, 2);
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		hudElements.add(healthBar);
		hudElements.add(healthBarBG);

		iconP2 = new HealthIcon("bf", false);
		hudElements.add(iconP2);

		iconP1 = new HealthIcon("bf", true);
		hudElements.add(iconP1);

		comboGroup = new FlxTypedSpriteGroup<Alphabet>();
		add(comboGroup);

		scoreTxt = new FlxText(0, 0, 0, '');
		scoreTxt.setFormat(Paths.getFont("vcr"), 22, FlxColor.WHITE, null, OUTLINE, FlxColor.BLACK);
		scoreTxt.borderSize = 1;
		scoreTxt.antialiasing = true;
		scoreTxt.screenCenter(X);
		scoreTxt.y = healthBar.y + 20;
		hudElements.add(scoreTxt);

		healthBarBG.visible = healthBar.visible = healthBarBG.visible = scoreTxt.visible = !SaveData.currentSettings.hideUI;

		generateNotes();
		Conductor.onBeat.add((b) ->
		{
			beatHit(Math.floor(b));
		});

		Conductor.onStep.add((b) ->
		{
			stepHit(Math.floor(b));
		});

		Conductor.onMeasure.add((b) ->
		{
			sectionHit(Math.floor(b));
		});

		startCountdown();
		FlxG.camera.follow(camFollow, LOCKON, 0.06);
		moveCameraToCharacter(dad);
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

		currentStage?.stepHit(step);
	}

	public var camGame:FlxZoomCamera;

	public function beatHit(beat:Int)
	{
		notes.sort(sortNotesByTimeHelper, FlxSort.DESCENDING);
		iconP1.bump();
		iconP2.bump();

		gf.dance(beat);
		dad.dance(beat);
		bf.dance(beat);

		currentStage?.beatHit(beat);
	}

	public function sectionHit(sectionCount:Int)
	{
		camHUD.zoom += 0.03;
		FlxG.camera.zoom += 0.015;

		var section = SONG.notes[sectionCount];
		if (section != null)
		{
			var char = section.mustHitSection ? bf : dad;
			moveCameraToCharacter(char);
		}

		currentStage?.sectionHit(sectionCount);
	}

	public var currentStage:BaseStage;

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
						final extra:Float = (stepLength * segmentID) + 20;
						var sustain:Note = new Note(lane, note.time + extra, mustHitNote, true, stepLength, unspawnNotes[unspawnNotes.length - 1],
							strum.lastSkinName);
						sustain.setPosition(-sustain.width * 2, -sustain.height * 2);
						@:privateAccess
						sustain.parent = note;
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

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		iconP1.y = healthBar.y - (iconP1.frameHeight * 0.5);
		iconP2.y = healthBar.y - (iconP2.frameHeight * 0.5);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

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

		keyPresses();
		notes.forEachAlive((note:Note) ->
		{
			var strum = note.mustPress ? playerStrums.members[note.lane] : opponentStrums.members[note.lane];
			note.move(strum, songSpeed);

			if (!note.mustPress && note.time <= Conductor.songPosition && !note.hit)
			{
				strum.playAnim("confirm", true);
				strum.resetAnim = 0.15;
				note.hit = true;
				dad.hitNote(note);
				noteCamMovement(note);

				if (SaveData.currentSettings.opponentNoteSplashes)
					spawnSplash(note);
				if (!note.isSustainNote)
					killNote(note);
			}

			// deletes notes out of range and causes misses if it is too late to hit
			if (note.time <= Conductor.songPosition - (Conductor.safeZoneOffset * 1))
			{
				if (!note.hit && note.mustPress)
				{
					missNote(note);
					combo = 0;
				}

				killNote(note);
			}
		});
		super.update(elapsed);
		if (controls.justPressed.UI_ACCEPT)
		{
			pause();
		}
		scoreTxt.screenCenter(X);
		scoreTxt.text = "Score: " + score + ' | Misses: $misses';

		if (FlxG.keys.justPressed.SEVEN)
			FlxG.switchState(new funkin.menus.charter.ChartingState());
	}

	function pause()
	{
		FlxG.sound.music.pause();
		voices?.pause();
		var ps = new PauseSubState();
		ps.cameras = [camHUD];
		camHUD.zoom = 1;
		persistentUpdate = false;
		openSubState(ps);
	}

	override function closeSubState()
	{
		super.closeSubState();
		FlxG.sound.music.resume();
		voices?.resume();
		persistentUpdate = true;
	}

	public function killNote(note:Note)
	{
		note.destroy();
		notes.remove(note, true);
	}

	public var hitNotes:Array<Note> = [];
	public var directions:Array<Int> = [];

	var keyPress:Array<Bool> = [];
	var keyHold:Array<Bool> = [];
	var keyReleased:Array<Bool> = [];

	public function keyPresses():Void
	{
		for (i in hitNotes)
			hitNotes.remove(i);
		for (i in directions)
			directions.remove(i);

		// fuck this  shitty function name!
		keyPress = [
			controls.justPressed.NOTE_LEFT,
			controls.justPressed.NOTE_DOWN,
			controls.justPressed.NOTE_UP,
			controls.justPressed.NOTE_RIGHT
		];
		keyHold = [
			controls.pressed.NOTE_LEFT,
			controls.pressed.NOTE_DOWN,
			controls.pressed.NOTE_UP,
			controls.pressed.NOTE_RIGHT
		];

		keyReleased = [
			controls.justReleased.NOTE_LEFT,
			controls.justReleased.NOTE_DOWN,
			controls.justReleased.NOTE_UP,
			controls.justReleased.NOTE_RIGHT
		];

		playerStrums.forEachAlive(function(strum:Strum)
		{
			if (keyPress[strum.lane])
				strum.playAnim('press', true);
			else if (!keyHold[strum.lane])
				strum.playAnim('static', false);
		});

		for (note in notes.members.filter((n:Note) -> return (n.canBeHit && n.alive && n.mustPress && !n.hit)))
		{
			hitNotes.push(note);
			directions.push(note.lane);
		}

		if (hitNotes.length > 0)
		{
			for (shit in 0...keyPress.length)
				if (keyPress[shit] && !directions.contains(shit))
					miss(shit);

			for (daN in hitNotes)
			{
				if (keyPress[daN.lane] && daN.canBeHit && !daN.isSustainNote)
					playerHit(daN);
				if (keyHold[daN.lane] && (daN.canBeHit) && daN.isSustainNote)
					playerHit(daN);
			}
		}
	}

	function playerHit(daN:Note)
	{
		var Judgement = JudgementHandler.getJudgementFromNote(daN);
		daN.hit = true;

		var strum = playerStrums.members[daN.lane];
		strum.playAnim("confirm", true);
		bf.hitNote(daN);

		var healthGain:Float = 0.023 * (daN.isSustainNote ? 0.5 : 1);

		health += healthGain;
		if (!Judgement.misses)
		{
			score += Judgement.score;
			noteCamMovement(daN);
		}
		else
		{
			health -= healthGain;
			missNote(daN);
			strum.playAnim("press", true);
		}
		if (Judgement.breaksCombo)
		{
			combo = 0;
		}
		else
			combo++;
		if (Judgement.splashes)
			spawnSplash(daN);

		if (!daN.isSustainNote)
			killNote(daN);
	}

	public var comboGroup:FlxTypedSpriteGroup<Alphabet>;

	public var combo:Int = 0;
	public var score:Float = 0;

	public var scoreTxt:FlxText;

	function miss(shit:Int)
	{
		health -= 0.04;
		score -= 150;
		misses++;
	}

	public function noteCamMovement(n:Note, ?force:Bool = false)
	{
		if (!SaveData.currentSettings.noteCamMovement && !force)
			return;
		var xOffset:Float = 0;
		var yOffset:Float = 0;

		switch (n.lane)
		{
			case 0: // left
				xOffset = -noteCamMovementAmountX;

			case 1: // down
				yOffset = noteCamMovementAmountY;

			case 2: // up
				yOffset = -noteCamMovementAmountY;

			case 3: // right
				xOffset = noteCamMovementAmountX;
		}

		FlxG.camera.targetOffset.set(xOffset, yOffset);
	}

	function missNote(note:Note)
	{
		miss(note.lane);
	}

	override function destroy()
	{
		for (note in unspawnNotes)
		{
			note.destroy();
			unspawnNotes[unspawnNotes.indexOf(note)] = null;
			note = null;
		}
		unspawnNotes.resize(0);
		super.destroy();
	}

	public var opponentCameraOffset = [0.0, 0.0];
	public var boyfriendCameraOffset = [0.0, 0.0];

	public function moveCameraToCharacter(char:Character)
	{
		if (char == null)
			return;

		var isDad = !char.player;
		if (isDad)
		{
			camFollow.setPosition(char.getMidpoint().x + 150, char.getMidpoint().y - 100);
			camFollow.x += char.json.cam_offset[0] + opponentCameraOffset[0];
			camFollow.y += char.json.cam_offset[1] + opponentCameraOffset[1];
		}
		else
		{
			camFollow.setPosition(char.getMidpoint().x - 100, char.getMidpoint().y - 100);
			camFollow.x -= char.json.cam_offset[0] - boyfriendCameraOffset[0];
			camFollow.y += char.json.cam_offset[1] + boyfriendCameraOffset[1];
		}
	}

	public function getStrumline(player:Int)
	{
		return player == 0 ? opponentStrums : playerStrums;
	}

	public var noteCamMovementAmountX:Float = 20;
	public var noteCamMovementAmountY:Float = 20;

	public function getDefaultStageCheck(song):String
	{
		song = song.toLowerCase();

		switch (song)
		{
			case 'spookeez' | 'monster' | 'south':
				return "spooky";
			case 'pico' | 'blammed' | 'philly':
				return 'philly';
			case "milf" | 'satin-panties' | 'high':
				return 'limo';
			case "cocoa" | 'eggnog':
				return 'mall';
			case 'winter-horrorland':
				return 'mallEvil';
			case 'senpai' | 'roses':
				return 'school';
			case 'thorns':
				return 'schoolEvil';
			case 'guns' | 'stress' | 'ugh':
				return 'tank';
			default:
				return 'stage';
		}
		return 'stage';
	}

	public function spawnSplash(n:Note)
	{
		if (!SaveData.currentSettings.noteSplashes || n.isSustainNote)
			return;
		var strumline = getStrumline(n.mustPress ? 1 : 0);
		var strum = strumline.members[n.lane % strumline.length];
		var splash = nSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(strum.x, strum.y, n.lane);
	}

	public function makeScriptFromPath(path:String)
	{
		var script:GameplayScriptHSRIPT = new GameplayScriptHSRIPT(path);
		scripts.push(script);
	}
}
