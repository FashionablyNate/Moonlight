package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import haxe.PosInfos;

enum GruntType
{
	REGULAR;
	BOSS;
}

class Grunt extends FlxSprite
{
	static inline var SPEED:Float = 50;
	public static inline var GRAVITY:Float = 600;

	var type:GruntType;
	var brain:FSM;
	var idleTimer:Float;
	var moveDirection:Float;

	public var seesPlayer:Bool;
	public var playerPosition:FlxPoint;
	public var gruntPosition:FlxPoint;

	public function new(x:Float, y:Float, type:GruntType)
	{
		super(x, y);
		this.type = type;
		var graphic = if (type == BOSS) "assets/images/boss.png" else "assets/images/player.png";
		loadGraphic(graphic, true, 16, 16);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animation.add("lr", [1, 0, 2, 0], 6, false);
		drag.x = drag.y = 10;
		setSize(8, 16);
		offset.set(4, 0);

		acceleration.y = GRAVITY;
		maxVelocity.set(100, GRAVITY);

		brain = new FSM(idle);
		idleTimer = 0;
		seesPlayer = false;
		playerPosition = FlxPoint.get();
		gruntPosition = FlxPoint.get();
	}

	override public function update(elapsed:Float)
	{
		if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE)
		{
			if (velocity.x < 0)
			{
				facing = FlxObject.LEFT;
			}
			else
			{
				facing = FlxObject.RIGHT;
			}
			animation.play("lr");
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
		else if (idleTimer <= 0)
		{
			if (FlxG.random.bool(1))
			{
				moveDirection = -1;
				velocity.x = velocity.y = 0;
			}
			else
			{
				moveDirection = FlxG.random.int(0, 1) * 180;

				velocity.set(SPEED * 0.5, 0);
				velocity.rotate(FlxPoint.weak(), moveDirection);
			}
			idleTimer = FlxG.random.int(1, 4);
		}
		else
		{
			idleTimer -= elapsed;
		}
	}

	function chase(elapsed:Float)
	{
		if (!seesPlayer)
		{
			brain.activeState = idle;
		}
		else
		{
			if (gruntPosition.x > playerPosition.x)
			{
				moveDirection = 180;
			}
			else
			{
				moveDirection = 0;
			}
			velocity.set(SPEED, 0);
			velocity.rotate(FlxPoint.weak(), moveDirection);
			if (velocity.x < 0)
			{
				facing = FlxObject.LEFT;
			}
			else
			{
				facing = FlxObject.RIGHT;
			}
			animation.play("lr");
			// var position = FlxPoint.get(playerPosition.x, 0);
			// FlxVelocity.moveTowardsPoint(this, position, Std.int(SPEED));
		}
	}
}
