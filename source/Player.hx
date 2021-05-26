package;

import flixel.addons.effects.chainable.FlxRainbowEffect;
import flixel.addons.effects.chainable.FlxTrailEffect;
import flixel.addons.effects.chainable.FlxEffectSprite;
import haxe.iterators.StringIterator;
import js.html.audio.DelayNode;
import haxe.Timer;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

class Player extends FlxSprite
{
	// constant unchanging value, so we use UPPERCASE and static inline class
	public static inline var GRAVITY:Float = 600;
	// declares finite state machine variable
	public var fsm:FlxFSM<FlxSprite>;

	public function new(x:Float = 0, y:Float = 0)
	{
		// super goes up chain to parent class (flxSprite) and calls constructor (new)
		// passing x and y as arguments
		super(x, y);

		// tells the sprite to use player.png, that it's animated and 16x16
		loadGraphic("assets/images/player.png", true, 16, 16);

		// tells sprite which in which order to play animation for which direction
		// this also ensures that the player always ends in the stopped frame. Also
		// tells sprite to play in 6 frames per second.
		animation.add("facingRight", [0], 6);
		animation.add("facingLeft", [3], 6);
		animation.add("walkingRight", [1, 0, 2, 0], 6);
		animation.add("walkingLeft", [4, 3, 5, 3], 6);
		animation.add("jumping", [6], 6);

		// adds in gravity and sets max velocity
		acceleration.y = GRAVITY;
		maxVelocity.set(100, GRAVITY);

		setSize(8, 16); // sets player size smaller so he can fit through doorways
		offset.set(4, 0); // sets player offset from actual size and 16x16 dimensions

		fsm = new FlxFSM<FlxSprite>(this);
		fsm.transitions.add(Idle, Jump, Conditions.jump).add(Jump, Idle, Conditions.grounded).start(Idle);
		fsm.transitions.add(Idle, Attack, Conditions.attack).add(Attack, Idle, Conditions.attackFinished).start(Idle);
		fsm.transitions.add(Jump, Attack, Conditions.attack).add(Attack, Idle, Conditions.attackFinished).start(Idle);
	}

	// overrides update() function so this is called everytime update() is called
	override function update(elapsed:Float):Void
	{
		// calls fsm so player state can be determined and set
		fsm.update(elapsed);
		super.update(elapsed);
	}

	override public function hurt(damage:Float):Void
	{
		if (!Player.Conditions.attackOver) return;

		if (FlxSpriteUtil.isFlickering(this)) return;

		FlxSpriteUtil.flicker(this, 1, 0.02, true);

		super.hurt(damage);
	}

	override public function kill():Void
	{
		if (!alive)
			return;

		super.kill();

		exists = true;
		active = false;
		visible = false;
		moves = false;
		velocity.set();
		acceleration.set();
		FlxG.camera.shake(0.005, 1);
		FlxG.camera.fade(0x000000, 1);

		new FlxTimer().start(1, function(_)
		{
			FlxG.switchState(new MenuState());
		});
	}
}

class Conditions
{
	public static var attackOver:Bool;
	public static function jump(Owner:FlxSprite):Bool
	{
		// conditional if player just pressed jump, and if they're grounded
		return (FlxG.keys.justPressed.UP && Owner.isTouching(FlxObject.DOWN));
	}

	public static function attack(Owner:FlxSprite):Bool
	{
		return (FlxG.keys.justPressed.SPACE);
	}

	public static function grounded(Owner:FlxSprite):Bool
	{
		// conditional if player is grounded
		return Owner.isTouching(FlxObject.DOWN);
	}

	public static function attackFinished(Owner:FlxSprite):Bool
		{
			return (attackOver);
		}

	public static function animationFinished(Owner:FlxSprite):Bool
	{
		// conditional animation is finished
		return (Owner.animation.finished);
	}
}

class Idle extends FlxFSMState<FlxSprite>
{
	override public function enter(owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		owner.maxVelocity.set(100, 600);
		owner.acceleration.x = 0;
		// this is the intial and idle state
		if (owner.facing == FlxObject.LEFT)
		{
			owner.animation.play("facingLeft");
		}
		else
		{
			owner.animation.play("facingRight");
		}
	}

	override public function update(elapsed:Float, owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		owner.acceleration.x = 0;
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			// conditional, if pressing left, set FlxObject to left, else set FLxObject to right.
			owner.facing = FlxG.keys.pressed.LEFT ? FlxObject.LEFT : FlxObject.RIGHT;
			// plays walking animation
			if (owner.facing == FlxObject.LEFT)
			{
				owner.animation.play("walkingLeft");
			}
			else
			{
				owner.animation.play("walkingRight");
			}
			// if left key pressed set acceleration to -300 else set it to 300
			owner.acceleration.x = FlxG.keys.pressed.LEFT ? -300 : 300;
		}
		else
		{
			// plays standing animation
			if (owner.facing == FlxObject.LEFT)
			{
				owner.animation.play("facingLeft");
			}
			else
			{
				owner.animation.play("facingRight");
			}
			// reduces velocity
			owner.velocity.x *= 0.9;
		}
	}
}

class Attack extends FlxFSMState<FlxSprite>
{
	var attackTimer = new FlxTimer();
	override public function enter(owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		Player.Conditions.attackOver = false;
		attackTimer.start(0.5, attackOver, 1);
		if (owner.facing == FlxObject.LEFT) {
			owner.animation.play("walkingLeft");
			owner.maxVelocity.x = 10000;
			owner.acceleration.x = -700;
		} else {
			owner.animation.play("walkingRight");
			owner.maxVelocity.x = 10000;
			owner.acceleration.x = 700;
		}
	}

	function attackOver(timer:FlxTimer):Void
	{
		Player.Conditions.attackOver = true;
	}
}

class Jump extends FlxFSMState<FlxSprite>
{
	override public function enter(owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		// plays jumping animation
		owner.animation.play("jumping");
		// sets y velocity to -200 (so player moves against gravity)
		owner.velocity.y = -200;
	}

	override public function update(elapsed:Float, owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		// initializes acceleration to 0
		owner.acceleration.x = 0;
		// if either right or left key pressed
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			// if left key pressed set acceleration to -300 else set it to 300
			owner.acceleration.x = FlxG.keys.pressed.LEFT ? -300 : 300;
		}
	}
}

class SuperJump extends Jump
{
	override public function enter(owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		owner.animation.play("jumping");
		owner.velocity.y = -300;
	}
}