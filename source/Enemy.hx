package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.tile.FlxTilemap;
import flixel.util.FlxSpriteUtil;
import haxe.PosInfos;

enum EnemyType // specify the type of enemy we want
{
	REGULAR;
	ARCHER;
}

class Enemy extends FlxSprite
{
	// physics variables
	static inline var SPEED:Float = 50; // sets speed of the enemy
	public static inline var GRAVITY:Float = 600; // sets gravity acting on enemy (same as player)

	// public variables
	public var _tileMap:FlxTilemap;
	public var _enemyMidpoint:FlxPoint;
	public var _seesPlayer:Bool;
	public var _playerMidpoint:FlxPoint;

	var _moveDirection:Float; // declare variable for direction enemy should move

	// intrinsic variables
	var _type:EnemyType; // declare enemy type variable

	// logic variables
	var _brain:FSM; // define FSM logic variabe
	var _idleTimer:Float; // declares idleTimer variable, directs time interval for random movements

	// player variables
	var _player:Player;

	// misc variables
	var _bullets:FlxTypedGroup<EnemyBullet>;

	// contructor for enemy class
	public function new(x:Float, y:Float, _type:EnemyType)
	{
		super(x, y);

		// loads type and sprite
		this._type = _type;
		var graphic = if (_type == ARCHER) "assets/images/boss.png" else "assets/images/grunt.png"; // conditional loads sprite for specific type of enemy
		loadGraphic(graphic, true, 16, 16); // loads specified graphic and indicates it is 16x16

		// animations
		animation.add("walkingRight", [1, 0, 2, 0], 6);
		animation.add("walkingLeft", [4, 3, 5, 3], 6);
		animation.add("jumping", [6], 6);
		animation.add("attackLeft", [10, 11], 6);
		animation.add("attackRight", [14, 15], 6);

		// physics
		drag.x = drag.y = 10; // amount of drag on entity (allows slowdown)
		setSize(8, 16); // sets offset
		offset.set(4, 0); // for entity inside it's 16x16 box
		acceleration.y = GRAVITY; // applies gravitational constant
		maxVelocity.set(100, GRAVITY); // sets max velocity

		// logic
		_brain = new FSM(idle); // starts new instance of FSM class
		_idleTimer = 0; // initializes idleTimer to 0
		_seesPlayer = false; // intializes seesPlayer to false
		_playerMidpoint = FlxPoint.get();

		// intrinsic
		_enemyMidpoint = FlxPoint.get();
		health = 2;
	}

	// updates everything inside once a frame
	override public function update(elapsed:Float)
	{
		if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE) // conditional if enemy is moving
		{
			if (velocity.x < 0) // if moving left
			{
				animation.play("walkingLeft"); // set animation left
			}
			else // else moving right
			{
				animation.play("walkingRight"); // set animation right
			}
		}
		_brain.update(elapsed);
		super.update(elapsed);
	}

	// garbage collection
	override public function destroy():Void
	{
		super.destroy();

		_player = null;
		_bullets = null;

		_playerMidpoint = null;
	}

	function idle(elapsed:Float)
	{
		if (_seesPlayer) // conditional if player is in sight
		{
			_brain.activeState = chase; // switch to chase state
		}
		else if (_idleTimer <= 0) // if timer is over
		{
			if (FlxG.random.bool(1)) // random chance to change direction or stop
			{
				_moveDirection = -1; // stops
				velocity.x = velocity.y = 0; // sets velocity to 0
			}
			else
			{
				_moveDirection = FlxG.random.int(0, 1) * 180; // sets random direction

				velocity.set(SPEED * 0.5, 0); // sets velocity to half of top speed
				velocity.rotate(FlxPoint.weak(), _moveDirection); // moves in direction found above
			}
			_idleTimer = FlxG.random.int(1, 4); // starts timer again
		}
		else
		{
			_idleTimer -= elapsed; // decrements timer
		}
	}

	function chase(elapsed:Float)
	{
		if (!_seesPlayer) // conditional if player isn't visible
		{
			_brain.activeState = idle; // sets idle state
		}
		else
		{
			var distance = _playerMidpoint.x - _enemyMidpoint.x; // declares distance between enemy and player
			if (!(distance < 15) || !(-15 < distance)) // if enemy has not yet reacher player
			{
				if (_enemyMidpoint.x > _playerMidpoint.x) // if player is left of enemy
				{
					_moveDirection = 180; // move left
				}
				else // else player is right of enemy
				{
					_moveDirection = 0; // move right
				}
				velocity.set(SPEED, 0); // sets velocity to top speed
				velocity.rotate(FlxPoint.weak(), _moveDirection); // sets movement direction found above
				if (velocity.x < 0) // if moving left
				{
					animation.play("walkingLeft"); // set animation left
				}
				else // else moving right
				{
					animation.play("walkingRight"); // set animation right
				}
			}
			else // enemy has reached player
			{
				_brain.activeState = attack; // sets state to attack
			}
		}
	}

	function attack(elapsed:Float)
	{
		var distance = _playerMidpoint.x - _enemyMidpoint.x;
		if (isTouching(FlxObject.DOWN))
		{
			if (distance < 15 && distance > -15)
			{
				if (distance > 0)
				{
					animation.play("attackLeft");
				}
				else
				{
					animation.play("attackRight");
				}
			}
			else
			{
				_brain.activeState = chase;
			}
		}
	}

	override public function hurt(Damage:Float):Void
	{
		if (!FlxSpriteUtil.isFlickering(this)) super.hurt(Damage);
		FlxSpriteUtil.flicker(this, 0.5, 0.02, true);
	}

	override public function kill():Void
	{
		if (!alive)
			return;

		super.kill();
		FlxG.camera.shake(0.003, 0.25);
		FlxSpriteUtil.flicker(this, 0, 0.02, true);
	}

	public function checkEnemyVision()
	{
		if (_tileMap.ray(_enemyMidpoint, _playerMidpoint)) // conditional if player is in direct line of site
		{
			_seesPlayer = true; // sets seesPlayer variable to true
		}
		else
		{
			_seesPlayer = false; // sets seesPlayer variable to false
		}
	}
}
