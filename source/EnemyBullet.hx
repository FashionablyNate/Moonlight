package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;

class EnemyBullet extends FlxSprite
{
	public var speed:Float;

	public function new()
	{
		super();
		loadGraphic("assets/images/bot_bullet.png", true);
		animation.add("idle", [0, 1], 50);
		animation.add("poof", [2, 3, 4], 50, false);
		speed = 120;
	}

	override public function update(elapsed:Float):Void
	{
		if (!alive)
		{
			if (animation.finished)
				exists = false;
		}
		else if (touching != 0)
		{
			kill();
		}

		super.update(elapsed);
	}

	override public function kill():Void
	{
		if (!alive)
			return;

		velocity.set();

		alive = false;
		solid = false;
		animation.play("poof");
	}

	public function shoot(Location:FlxPoint, Angle:Float):Void
	{
		super.reset(Location.x - width / 2, Location.y - height / 2);
		_point.set(0, -speed);
		_point.rotate(FlxPoint.weak(0, 0), Angle);
		velocity.x = _point.x;
		velocity.y = _point.y;
		solid = true;
		animation.play("idle");
	}
}
