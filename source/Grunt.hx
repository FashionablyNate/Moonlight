package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import haxe.PosInfos;

enum GruntType // specify the type of enemy we want
{
	REGULAR;
	ARCHER;
}

class Grunt extends FlxSprite
{
	static inline var SPEED:Float = 50; // sets speed of the enemy
	public static inline var GRAVITY:Float = 600; // sets gravity acting on enemy (same as player)

	var type:GruntType; // declare enemy type variable
	var brain:FSM; // define FSM logic variabe
	var idleTimer:Float; // declares idleTimer variable, directs time interval for random movements
	var moveDirection:Float; // declare variable for direction enemy should move

	public var seesPlayer:Bool; // conditional the player is visible/not
	public var playerPosition:FlxPoint; // position of player for use in player tracking
	public var gruntPosition:FlxPoint; // position of self for use in player tracking

	public function new(x:Float, y:Float, type:GruntType)
	{
		super(x, y);
		this.type = type;
		var graphic = if (type == ARCHER) "assets/images/boss.png" else "assets/images/player.png"; // conditional loads sprite for specific type of enemy
		loadGraphic(graphic, true, 16, 16); // loads specified graphic and indicates it is 16x16
		setFacingFlip(FlxObject.LEFT, true, false); // flips sprite
		setFacingFlip(FlxObject.RIGHT, false, false); // if facing left
		animation.add("walking", [1, 0, 2, 0], 6, false); // animation pattern for movement
		drag.x = drag.y = 10; // amount of drag on entity (allows slowdown)
		setSize(8, 16); // sets offset
		offset.set(4, 0); // for entity inside it's 16x16 box

		acceleration.y = GRAVITY; // applies gravitational constant
		maxVelocity.set(100, GRAVITY); // sets max velocity

		brain = new FSM(idle); // starts new instance of FSM class
		idleTimer = 0; // initializes idleTimer to 0
		seesPlayer = false; // intializes seesPlayer to false
		playerPosition = FlxPoint.get(); // gets player position
		gruntPosition = FlxPoint.get(); // gets grunt position
	}

	override public function update(elapsed:Float)
	{
		if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE) // conditional if grunt is moving
		{
			if (velocity.x < 0) // conditional if grunt is moving on x-axis
			{
				facing = FlxObject.LEFT; // tells sprite to face left
			}
			else // conditional if grunt is moving on y-axis
			{
				facing = FlxObject.RIGHT; // tells sprite to face right
			}
			animation.play("walking"); // plays walking animation
		}
		brain.update(elapsed);
		super.update(elapsed);
	}

	function idle(elapsed:Float)
	{
		if (seesPlayer) // conditional if player is in sight
		{
			brain.activeState = chase; // switch to chase state
		}
		else if (idleTimer <= 0) // if timer is over
		{
			if (FlxG.random.bool(1)) // random chance to change direction or stop
			{
				moveDirection = -1; // stops
				velocity.x = velocity.y = 0; // sets velocity to 0
			}
			else
			{
				moveDirection = FlxG.random.int(0, 1) * 180; // sets random direction

				velocity.set(SPEED * 0.5, 0); // sets velocity to half of top speed
				velocity.rotate(FlxPoint.weak(), moveDirection); // moves in direction found above
			}
			idleTimer = FlxG.random.int(1, 4); // starts timer again
		}
		else
		{
			idleTimer -= elapsed; // decrements timer
		}
	}

	function chase(elapsed:Float)
	{
		if (!seesPlayer) // conditional if player is visible
		{
			brain.activeState = idle; // sets idle state
		}
		else
		{
			if (gruntPosition.x > playerPosition.x) // if player is left of grunt
			{
				moveDirection = 180; // move left
			}
			else
			{
				moveDirection = 0; // move right
			}
			velocity.set(SPEED, 0); // sets velocity to top speed
			velocity.rotate(FlxPoint.weak(), moveDirection); // sets movement direction found above
			if (velocity.x < 0) // if move left
			{
				facing = FlxObject.LEFT; // set animation left
			}
			else
			{
				facing = FlxObject.RIGHT; // set animation right
			}
			animation.play("walking"); // calls sprite animation
		}
	}
}