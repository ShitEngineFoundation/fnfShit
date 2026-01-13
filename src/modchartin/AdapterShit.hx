package modchartin;

import funkin.game.*;
import funkin.game.GameplayState;
import modchart.backend.standalone.IAdapter;

class AdapterShit implements IAdapter
{
	public function new() {}

	public function onModchartingInitialization() {}

	public function getSongPosition():Float
	{
		return Conductor.songPosition;
	}

	public function getCurrentBeat():Float
	{
		return Conductor.beatCount;
	}

	public function getCurrentCrochet():Float
	{
		return Conductor.beatLength;
	}

	public function getCurrentScrollSpeed():Float
	{
		return GameplayState.self.songSpeed * .45;
	}

	public function getBeatFromStep(step:Float):Float
	{
		return step * .25;
	}

	public function getDefaultReceptorX(lane:Int, player:Int):Float
	{
		var strumline:StrumLineGroup = GameplayState.self.getStrumline(player);
		return strumline.members[lane % strumline.length].x;
	}

	public function getDefaultReceptorY(lane:Int, player:Int):Float
	{
		var strumline:StrumLineGroup = GameplayState.self.getStrumline(player);
		return strumline.members[lane % strumline.length].y;
	}

	public function getTimeFromArrow(arrow:FlxSprite):Float
	{
		if (arrow is Note)
		{
			var note:Note = cast arrow;
			return note.time;
		}
		return 0;
	}

	public function isTapNote(sprite:FlxSprite):Bool
	{
		return sprite is Note;
	}

	public function isHoldEnd(sprite:FlxSprite):Bool
	{
		return sprite.animation.name.contains('cap') && isTapNote(sprite);
	}

	public function arrowHit(sprite:FlxSprite):Bool
	{
		if (sprite is Note)
		{
			var note:Note = cast sprite;
			return note.hit;
		}
		return false;
	}

	public function getHoldParentTime(sprite:FlxSprite):Float
	{
		if (sprite is Note)
		{
			var note:Note = cast sprite;
			return note.parent?.time ?? note.time;
		}
		return 0;
	}

	public function getHoldLength(sprite:FlxSprite):Float
	{
		if (sprite is Note)
		{
			var note:Note = cast sprite;
			return note.sustainLength;
		}
		return Conductor.stepLength;
	}

	public function getLaneFromArrow(sprite:FlxSprite):Int
	{
		if (sprite is Note)
		{
			var note:Note = cast sprite;
			return note.lane;
		}
		else if (sprite is Strum)
		{
			var note:Strum = cast sprite;
			return note.lane;
		}
		return 0;
	}

	public function getPlayerFromArrow(sprite:FlxSprite):Int
	{
		if (sprite is Note)
		{
			var note:Note = cast sprite;
			return note.mustPress ? 1 : 0;
		}
		else if (sprite is Strum)
		{
			var note:Strum = cast sprite;
			return GameplayState.self.playerStrums.members.contains(note) ? 1 : 0;
		}
		return 0;
	}

	public function getKeyCount(?player:Int):Int
	{
		return GameplayState.self.getStrumline(player).length;
	}

	public function getPlayerCount():Int
	{
		return 2;
	}

	public function getArrowCamera():Array<FlxCamera>
	{
		return [GameplayState.self.camHUD];
	}

	public function getHoldSubdivisions(item:FlxSprite):Int
	{
		return 4;
	}

	public function getDownscroll():Bool
	{
		return SaveData.currentSettings.downScroll;
	}

	/**
	 * Get the every arrow/lane indexed by player.
	 * Example:
	 * [
	 *      [ // Player 0
	 *          [strum1, strum2...],
	 *          [arrow1, arrow2...],
	 *          [hold1, hold2....],
	 * 			[splash1, splash2....]
	 *      ],
	 *      [ // Player 2
	 *          [strum1, strum2...],
	 *          [arrow1, arrow2...],
	 *          [hold1, hold2....],
	 * 			[splash1, splash2....]
	 *      ]
	 * ]
	 * @return Array<Array<Array<FlxSprite>>>
	 */
	public function getArrowItems():Array<Array<Array<FlxSprite>>>
	{
		var itemsLol:Array<Array<Array<FlxSprite>>> = [
			[cast GameplayState.self.getStrumline(0).members, [], []],
			[cast GameplayState.self.getStrumline(1).members, [], []]
		];

		for (noteID in 0...GameplayState.self.notes.length)
		{
			var note:Note = GameplayState.self.notes.members[noteID];
			itemsLol[getPlayerFromArrow(note)][note.isSustainNote ? 2 : 1].push(note);
		}
		return itemsLol;
	}
}
