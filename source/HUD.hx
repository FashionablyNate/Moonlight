package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;

class HUD extends FlxTypedGroup<FlxSprite>
{
	public var healthIcon1:FlxSprite; // declare healthIcon variable
	public var healthIcon2:FlxSprite; // declare healthIcon variable
	public var healthIcon3:FlxSprite; // declare healthIcon variable
	public var healthIcon4:FlxSprite; // declare healthIcon variable
	public var healthIcon5:FlxSprite; // declare healthIcon variable
	public var healthIcon6:FlxSprite; // declare healthIcon variable

	public function new()
	{
		super();
		healthIcon2 = new FlxSprite(4, 2, "assets/images/health.png"); // assign image to healthIcon variable
		add(healthIcon2); // add health icon to state
		healthIcon4 = new FlxSprite(14, 2, "assets/images/health.png"); // assign image to healthIcon variable
		add(healthIcon4); // add health icon to state
		healthIcon6 = new FlxSprite(24, 2, "assets/images/health.png"); // assign image to healthIcon variable
		add(healthIcon6); // add health icon to state

		healthIcon1 = new FlxSprite(4, 2, "assets/images/halfHealth.png"); // assign image to healthIcon variable
		add(healthIcon1); // add health icon to state
		healthIcon3 = new FlxSprite(14, 2, "assets/images/halfHealth.png"); // assign image to healthIcon variable
		add(healthIcon3); // add health icon to state
		healthIcon5 = new FlxSprite(24, 2, "assets/images/halfHealth.png"); // assign image to healthIcon variable
		add(healthIcon5); // add health icon to state

		forEach(function(sprite) sprite.scrollFactor.set(0, 0)); // iterates through items in group and sets their scroll factor so items stay on screen
	}
}
