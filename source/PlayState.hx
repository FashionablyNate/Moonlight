package;

import AssetsPaths.AssetPaths;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.weapon.FlxBullet;
import flixel.addons.weapon.FlxWeapon.FlxTypedWeapon;
import flixel.addons.weapon.FlxWeapon;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton.FlxTypedButton;
import flixel.util.FlxColor;
import haxe.macro.Expr.ObjectField;
import js.html.CaretPosition;

using flixel.util.FlxSpriteUtil;

/* This is the class that controls the main play state of the game. */
class PlayState extends FlxState
{
	// Map variables
	var _map:FlxOgmo3Loader;
	var _tileMap:FlxTilemap;

	// Game object variables
	var _player:Player;
	var _potion:FlxTypedGroup<Potion>;
	var _enemies:FlxTypedGroup<Enemy>;
	var _enemyBullets:FlxTypedGroup<EnemyBullet>;
	var _bullets:FlxTypedGroup<Bullet>;

	public var _hud:HUD;

	var health:Int = 6;

	// Meta groups
	var _objects:FlxGroup;
	var _hazards:FlxGroup;

	/* This is a built in function for creating sprites, maps and objects. */
	override public function create()
	{
		FlxG.mouse.visible = false;

		// Game objects and groups
		bgColor = 0xff37003B;
		_enemies = new FlxTypedGroup<Enemy>(50);
		_hud = new HUD();
		_enemyBullets = new FlxTypedGroup<EnemyBullet>(100);
		_bullets = new FlxTypedGroup<Bullet>(20);
		_potion = new FlxTypedGroup<Potion>();

		// Player
		_player = new Player();

		// Map setup
		_map = new FlxOgmo3Loader(AssetPaths.moonlight__ogmo, AssetPaths.room_002__json);
		_tileMap = _map.loadTilemap("assets/images/platformer.png", "platforms");
		_tileMap.follow();
		_tileMap.setTileProperties(1, FlxObject.ANY);
		add(_tileMap);
		_map.loadEntities(placeEntities, "entities");

		// add items and enemies to state
		add(_potion);
		add(_enemies);

		// add player and set up camera
		add(_player);
		FlxG.camera.follow(_player, TOPDOWN, 1);

		// add bullets and HUD on top of everything
		add(_enemyBullets);
		add(_bullets);
		add(_hud);

		// collision group setup
		_hazards = new FlxGroup();
		_hazards.add(_enemyBullets);
		_hazards.add(_enemies);
		_objects = new FlxGroup();
		_objects.add(_enemyBullets);
		_objects.add(_bullets);
		_objects.add(_enemies);
		_objects.add(_player);

		super.create();
	}

	// garbage collection when state closes, frees memory
	override public function destroy():Void
	{
		super.destroy();

		_bullets = null;
		_player = null;
		_enemies = null;
		_enemyBullets = null;
		_hud = null;

		_objects = null;
		_hazards = null;

		_map = null;
		_tileMap = null;

		super.destroy();
	}

	/* This is a built in function that updates everything inside it every frame */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// collisions with environment
		FlxG.collide(_tileMap, _objects);
		FlxG.overlap(_hazards, _player, overlapped);
		FlxG.overlap(_bullets, _hazards, overlapped);

		// returns to main menu
		if (FlxG.keys.pressed.ESCAPE)
			FlxG.switchState(new MenuState());
	}

	/* This is a function for assigning entity names from the map to variables */
	function placeEntities(entity:EntityData)
	{
		switch (entity.name)
		{
			case "player": // conditional if the entities name is player
				_player.setPosition(entity.x, entity.y); // assigns the entities position to player
			case "potion": // conditional if the entities name is potion
				_potion.add(new Potion(entity.x + 4, entity.y + 4)); // assigns the entities position to potion
			case "enemy": // conditional if entities name is grunt
				_enemies.add(new Enemy(entity.x + 4, entity.y, REGULAR)); // assigns entities position to grunt
		}
	}

	/* This is the overlap callback function, triggered by FlxG.overlap(). */
	function overlapped(Sprite1:FlxObject, Sprite2:FlxObject):Void
	{
		if ((Sprite1 is EnemyBullet) || (Sprite1 is Bullet)) // conditional to see if bullet
			Sprite1.kill(); // deletes bullet

		Sprite2.hurt(1); // calls hurt function on FlxObject
	}
}
/* this is a function that decides what happens when a player touches a potion object 
	function playerTouchPotion(player:Player, potion:Potion)
	{
		// verifies player and potion both exist when they overlap
		if (player.alive && player.exists && potion.alive && potion.exists)
		{
			// gives player ability
			player.fsm.transitions.replace(Player.Jump, Player.SuperJump);
			player.fsm.transitions.add(Player.Jump, Player.Idle, Player.Conditions.grounded);

			// removes potion
			potion.kill();
		}
	}

	/* this is a function that determines if the player is close enough for an enemy to see them
	function checkEnemyVision(grunt:Grunt)
	{
		if (walls.ray(grunt.getMidpoint(), player.getMidpoint())) // conditional if player is in direct line of site
		{
			grunt.seesPlayer = true; // sets seesPlayer variable to true
			grunt.playerPosition = player.getMidpoint(); // assigns player postion to Grunt class variable
			grunt.gruntPosition = grunt.getMidpoint(); // assigns grunt postion to Grunt class variable
		}
		else
		{
			grunt.seesPlayer = false; // sets seesPlayer variable to false
		}
	}

	function attack(player:Player, grunt:Grunt):Void
	{
		if (!player.isFlickering())
		{
			grunt.kill();
		}
	}

	function overlapped(Sprite1:FlxObject, Sprite2:FlxObject):Void
	{
		if (Sprite1 is bullet)
			Sprite1.kill();

		sprite2.hurt(1);
	}

	/* this is a function that gets called when colliding with a melee enemy.
	function hurt(Sprite1:FlxObject):Void
	{
		if (Sprite1 is player)
		{
			if (!player.isFlickering())
			{
				if (grunt.playerPosition.x > grunt.gruntPosition.x) // if player is to the right of grunt
				{
					player.velocity.set(50, -100); // push player right
				}
				else // if player is to the left of grunt
				{
					player.velocity.set(-50, -100); // push player left
				}

				player.flicker(1.3); // puts flicker effect on player
				switch (health) // switch statement that decrements health GUI
				{
					case 6:
						hud.healthIcon6.kill();
						health = 5;
					case 5:
						hud.healthIcon5.kill();
						health = 4;
					case 4:
						hud.healthIcon4.kill();
						health = 3;
					case 3:
						hud.healthIcon3.kill();
						health = 2;
					case 2:
						hud.healthIcon2.kill();
						health = 1;
					case 1:
						hud.healthIcon1.kill();
						health = 0;
					case 0:
						FlxG.camera.fade(FlxColor.BLACK, 1, false, function() // game over
						{
							FlxG.switchState(new MenuState()); // main menu
						});
				}
			}
		}
		else
		{
			if (grunt.playerPosition.x > grunt.gruntPosition.x) // if player is to the right of grunt
			{
				player.velocity.set(50, -100); // push player right
			}
			else // if player is to the left of grunt
			{
				player.velocity.set(-50, -100); // push player left
			}
		}
	}
	}
 */
