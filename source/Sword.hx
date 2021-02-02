package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class Sword extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0)
	{
		super();
		makeGraphic(1, 16, FlxColor.GRAY);
	}
}
