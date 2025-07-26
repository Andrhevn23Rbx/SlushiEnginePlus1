package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OutdatedState extends MusicBeatState
{
	override function create()
	{
		super.create();
		MusicBeatState.switchState(new MainMenuState());
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
