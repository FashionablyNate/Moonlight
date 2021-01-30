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
	public static inline var GRAVITY:Float = 600;

	public function new(x:Float = 0, y:Float = 0)
	{
		// super goes up chain to parent class (flxSprite) and calls constructor (new)
		// passing x and y as arguments
		super(x, y);

		// tells the sprite to use player.png, that it's animated and 32x32
		loadGraphic("assets/images/player.png", true, 32, 32);

		// tells sprite not to flip when facing left, but to flip when facing right
		// this is because I'm lazy and the sprite only faces left in my png
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);

		// tells sprite which in which order to play animation for which direction
		// this also ensures that the player always ends in the stopped frame. Also
		// tells sprite to play in 6 frames per second.
		animation.add("lr", [4, 3, 5, 3], 9, false);
		animation.add("u", [7, 6, 8, 6], 9, false);
		animation.add("d", [1, 0, 2, 0], 9, false);

		// adds drag which slows down an object which isn't being moved.
		drag.x = drag.y = 1600;

		// adds in gravity
		acceleration.y = GRAVITY;
		maxVelocity.set(100, GRAVITY);

		setSize(12, 27); // sets player size smaller so he can fit through doorways
		offset.set(10, 3); //
	}

	function updateMovement()
	{
		// variables used to determine which key was pressed
		var up:Bool = false;
		var left:Bool = false;
		var right:Bool = false;

		// checks which keys are pressed and assigns then to above variabels
		up = FlxG.keys.anyPressed([UP, W, SPACE]); // up is triggered by "up arrow key" or "W" or "SPACE"
		left = FlxG.keys.anyPressed([LEFT, A]); // left is triggered by "left arrow key" or "A"
		right = FlxG.keys.anyPressed([RIGHT, D]); // right is triggered by "right arrow key" or "D"

		// cancels out opposing direction
		if (left && right)
			left = right = false;

		// conditional checks if player is currently moving
		if (up || left || right)
		{
			var newAngle:Float = 0; // intializes direction to 0
			if (up) // conditional checks for up key being pressed
			{
				newAngle = -90; // sets direction N
				if (left) // conditional checks if left key is ALSO pressed
					newAngle = -135; // sets direction NW
				else if (right) // condition checks if left key is ALSO pressed
					newAngle = -45; // sets direction NE

				// maintains velocty.x and sets velocity.y to -200
				velocity.set(velocity.x, -200);
			}
			else if (left) // condtional checks if left key is pressed
			{
				newAngle = 180; // sets direction W
				facing = FlxObject.LEFT; // tells sprite to display left frames
				// sets velocity.x to SPEED and maintains velocity.y
				velocity.set(SPEED, velocity.y);
			}
			else if (right) // conditional checks if right key is pressed
			{
				newAngle = 0; // sets direction E
				facing = FlxObject.RIGHT; // tells sprite to display right frames
				// sets velocity.x to SPEED and maintains velocity.y
				velocity.set(SPEED, velocity.y);
			}

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
