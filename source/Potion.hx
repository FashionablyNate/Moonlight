package;

import flixel.tweens.FlxEase;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class Potion extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);
		loadGraphic("assets/images/potion_blue.png", false, 8, 8);
	}

	override function kill()
	{
		alive = false; // sets alive to false
		// animates object to fade out and then move upwards, calls finish kill afterward
		FlxTween.tween(this, {alpha: 0, y: y - 16}, 0.33, {ease: FlxEase.circOut, onComplete: finishKill});
	}

	function finishKill(_)
	{
		exists = false; // removes potion
	}
}
