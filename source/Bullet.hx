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

		loadGraphic("assets/images/sword.png", true);
		width = 8;
		height = 1;
		offset.set(0, 0);

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
	}

	public function shoot(Location:FlxPoint, Aim:Int):Void
	{
		super.reset(Location.x - width / 2, Location.y - height / 2);

		solid = true;
	}

	function timesUp(timer:FlxTimer):Void
	{
		kill();
	}
}
