package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		// tells main to start in MenuState
		addChild(new FlxGame(480, 270, MenuState));
	}
}
