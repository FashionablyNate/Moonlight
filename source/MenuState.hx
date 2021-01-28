package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.ui.FlxButton;

class MenuState extends FlxState
{
	var playButton:FlxButton;

	override public function create()
	{
		// creates a FlxButton object and assigns the playButton variable at position 0, 0 with the word "play"
		// it will call clickPlay() function upon clicking
		playButton = new FlxButton(0, 0, "Play", clickPlay);

		// adds object to the state, so it becomes visible and usable
		add(playButton);

		// centers play button on screen
		playButton.screenCenter();

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	// called when user clicks play button
	function clickPlay()
	{
		// this switches the state to a new instance of PlayState
		FlxG.switchState(new PlayState());
	}
}
