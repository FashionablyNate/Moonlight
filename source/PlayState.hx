package;

import flixel.FlxState;

class PlayState extends FlxState
{
	// defines player variable
	var player:Player;

	override public function create()
	{
		player = new Player(20, 20);
		// assigns new instance of Player sprite to player variable
		add(player);
		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
