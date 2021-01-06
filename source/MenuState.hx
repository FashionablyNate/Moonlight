package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	var _gameTitle:FlxText;
	var _bg:FlxSprite;
	var _startButton:FlxButton;

	override public function create():Void
	{
		// fade in from black
		FlxG.cameras.flash(FlxColor.BLACK, 3);
		FlxG.mouse.visible = true;

		_gameTitle = new FlxText(10, 90, 300, "Moonlight");
		_gameTitle.setFormat(null, 16, FlxColor.WHITE, CENTER);
		add(_gameTitle);

		// adding in background image
	}
}
