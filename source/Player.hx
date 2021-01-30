package;

import AssetsPaths.AssetPaths;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM.FlxFSMState;
import flixel.addons.util.FlxFSM;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

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

		// tells the sprite to use player.png, that it's animated and 32x32
		loadGraphic("assets/images/player.png", true, 32, 32);

		// tells sprite not to flip when facing left, but to flip when facing right
		// this is because I'm lazy and the sprite only faces left in my png
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);

		// tells sprite which in which order to play animation for which direction
		// this also ensures that the player always ends in the stopped frame. Also
		// tells sprite to play in 6 frames per second.
		animation.add("standing", [3], 9);
		animation.add("walking", [4, 3, 5, 3], 9);
		animation.add("jumping", [3], 9);

		// adds in gravity and sets max velocity
		acceleration.y = GRAVITY;
		maxVelocity.set(100, GRAVITY);

		setSize(12, 27); // sets player size smaller so he can fit through doorways
		offset.set(10, 3); // sets player offset from actual size and 32x32 dimensions

		fsm = new FlxFSM<FlxSprite>(this);
		fsm.transitions.add(Idle, Jump, Conditions.jump).add(Jump, Idle, Conditions.grounded).start(Idle);
	}

	// overrides update() function so this is called everytime update() is called
	override function update(elapsed:Float):Void
	{
		// calls fsm so player state can be determined and set
		fsm.update(elapsed);
		super.update(elapsed);
	}
}

class Conditions
{
	public static function jump(Owner:FlxSprite):Bool
	{
		// conditional if player just pressed jump, and if they're grounded
		return (FlxG.keys.justPressed.UP && Owner.isTouching(FlxObject.DOWN));
	}

	public static function grounded(Owner:FlxSprite):Bool
	{
		// conditional if player is grounded
		return Owner.isTouching(FlxObject.DOWN);
	}

	public static function animationFinished(Owner:FlxSprite):Bool
	{
		// conditional animation is finished
		return Owner.animation.finished;
	}
}

class Idle extends FlxFSMState<FlxSprite>
{
	override public function enter(owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		// this is the intial and idle state
		owner.animation.play("standing");
	}

	override public function update(elapsed:Float, owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		owner.acceleration.x = 0;
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			// conditional, if pressing left, set FlxObject to left, else set FLxObject to right.
			owner.facing = FlxG.keys.pressed.LEFT ? FlxObject.LEFT : FlxObject.RIGHT;
			// plays walking animation
			owner.animation.play("walking");
			// if left key pressed set acceleration to -300 else set it to 300
			owner.acceleration.x = FlxG.keys.pressed.LEFT ? -300 : 300;
		}
		else
		{
			// plays standing animation
			owner.animation.play("standing");
			// reduces velocity
			owner.velocity.x *= 0.9;
		}
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
