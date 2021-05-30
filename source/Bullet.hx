package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.util.FlxTimer;

class Bullet extends FlxSprite
{
	var attackTimer = new FlxTimer();
	var _speed:Float;

	public function new()
	{
		super();

		loadGraphic("assets/images/bullet.png", true);
		width = 6;
		height = 6;
		offset.set(1, 1);

		animation.add("up", [0]);
		animation.add("down", [1]);
		animation.add("left", [2]);
		animation.add("right", [3]);
		animation.add("poof", [4, 5, 6, 7], 50, false);

		attackTimer.start(0.3, timesUp);
		_speed = 0;
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

		velocity.set(0, 0);

		alive = false;
		solid = false;
		animation.play("poof");
	}

	public function shoot(Location:FlxPoint, Aim:Int):Void
	{
		super.reset(Location.x - width / 2, Location.y - height / 2);

		solid = true;

		switch (Aim)
		{
			case FlxObject.UP:
				animation.play("up");
				velocity.y = -_speed;
			case FlxObject.DOWN:
				animation.play("down");
				velocity.y = _speed;
			case FlxObject.LEFT:
				animation.play("left");
				velocity.x = -_speed;
			case FlxObject.RIGHT:
				animation.play("right");
				velocity.x = _speed;
		}
	}

	function timesUp(timer:FlxTimer):Void
	{
		kill();
	}
}
