package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxState;

class OutdatedState extends FlxState
{
    override function create()
    {
        super.create();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(bg);

        var text:FlxText = new FlxText(0, FlxG.height / 2 - 10, FlxG.width, "This version is outdated.");
        text.setFormat(null, 16, FlxColor.WHITE, "center");
        add(text);
    }
}
