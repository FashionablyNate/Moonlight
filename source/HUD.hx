package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;

class HUD extends FlxTypedGroup<FlxSprite>
{
	var healthIcon:FlxSprite; // declare healthIcon variable

	public function new()
	{
		super();
		healthIcon = new FlxSprite(4, 2, "assets/images/health.png"); // assign image to healthIcon variable
		add(healthIcon); // add health icon to state
		forEach(function(sprite) sprite.scrollFactor.set(0, 0)); // iterates through items in group and sets their scroll factor so items stay on screen
	}
}
