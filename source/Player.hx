package;

import AssetsPaths.AssetPaths;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	// constant unchanging value, so we use UPPERCASE and static inline class
	static inline var SPEED:Float = 200;

	public function new(x:Float = 0, y:Float = 0)
	{
		// super goes up chain to parent class (flxSprite) and calls constructor (new)
		// passing x and y as arguments
		super(x, y);

		// tells the sprite to use playerBig.png, that it's animated and 32x32
		loadGraphic("assets/images/playerBig.png", true, 32, 32);

		// tells sprite not to flip when facing left, but to flip when facing right
		// this is because I'm lazy and the sprite only faces left in my png
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);

		// tells sprite which in which order to play animation for which direction
		// this also ensures that the player always ends in the stopped frame. Also
		// tells sprite to play in 6 frames per second.
		animation.add("lr", [3, 4, 3, 5], 6, false);
		animation.add("u", [6, 7, 6, 8], 6, false);
		animation.add("d", [0, 1, 0, 2], 6, false);

		// adds drag which slows down an object which isn't being moved
		drag.x = drag.y = 1600;
	}

	function updateMovement()
	{
		// variables used to determine which key was pressed
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;

		// checks which keys are pressed and assigns then to above variabels
		up = FlxG.keys.anyPressed([UP, W]); // up is triggered by "up arrow key" or "W"
		down = FlxG.keys.anyPressed([DOWN, S]); // down is triggered by "down arrow key" or "S"
		left = FlxG.keys.anyPressed([LEFT, A]); // left is triggered by "left arrow key" or "A"
		right = FlxG.keys.anyPressed([RIGHT, D]); // right is triggered by "right arrow key" or "D"

		// cancels out opposing direction
		if (up && down)
			up = down = false;
		if (left && right)
			left = down = false;

		// conditional checks if player is currently moving
		if (up || down || left || right)
		{
			var newAngle:Float = 0; // intializes direction to the right
			if (up) // conditional checks for up key being pressed
			{
				newAngle = -90; // sets direction N
				if (left) // conditional checks if left key is ALSO pressed
					newAngle -= 45; // sets direction NW
				else if (right) // condition checks if left key is ALSO pressed
					newAngle += 45; // sets direction NE
				facing = FlxObject.UP; // tells sprite to display up frames
			}
			else if (down)
			{
				newAngle = 90; // sets direction S
				if (left) // conditional checks if left is ALSO pressed
					newAngle += 45; // sets direction SW
				else if (right) // conditional checks if right is ALSO pressed
					newAngle -= 45; // sets direction SE
				facing = FlxObject.DOWN; // tells sprite to display down frames
			}
			else if (left) // condtional checks if left key is pressed
			{
				newAngle = 180; // sets direction W
				facing = FlxObject.LEFT; // tells sprite to display left frames
			}
			else if (right) // conditional checks if right key is pressed
			{
				newAngle = 0; // sets direction E
				facing = FlxObject.RIGHT; // tells sprite to display right frames
			}
			// sets velocity.x to SPEED and velocity.y to 0
			velocity.set(SPEED, 0);
			// rotates around point (0, 0) by angle we just found (newAngle)
			velocity.rotate(FlxPoint.weak(0, 0), newAngle);

			// ensures the player isn't stopped and that they aren't touching anything (like a wall)
			if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE)
			{
				// switches between directions to face
				switch (facing)
				{
					// if the player faces left or right
					case FlxObject.LEFT, FlxObject.RIGHT:
						animation.play("lr"); // play left/right animation
					// if player faces up
					case FlxObject.UP:
						animation.play("u"); // play up animation
					// if player faces down
					case FlxObject.DOWN:
						animation.play("d"); // play down animation
				}
			}
		}
	}

	// overrides update() function so this is called everytime update() is called
	override function update(elapsed:Float)
	{
		// calls updateMovement() function so each time update() is called,
		// player's velocity is updated.
		updateMovement();
		super.update(elapsed);
	}
}