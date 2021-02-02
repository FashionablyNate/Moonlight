package;

import AssetsPaths.AssetPaths;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import js.html.CaretPosition;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	// defines player variable
	var player:Player;
	// variable to hold ogmo map
	var map:FlxOgmo3Loader;
	// variable to hold FlxTilemap
	var walls:FlxTilemap;
	// variable for potion entity
	var potion:FlxTypedGroup<Potion>;
	// variable for grunt entity
	var grunt:FlxTypedGroup<Grunt>;

	// variable for heads up display
	public var hud:HUD;

	// variable for health
	var health:Int = 6;

	override public function create()
	{
		bgColor = 0xff37003B;
		map = new FlxOgmo3Loader(AssetPaths.moonlight__ogmo, AssetPaths.room_002__json); // initializes map to variable
		walls = map.loadTilemap("assets/images/platformer.png", "platforms"); // generates FlxTilemap from platforms layer
		walls.follow();
		walls.setTileProperties(1, FlxObject.ANY); // sets tile 1 to allow passover
		add(walls); // add walls to state

		potion = new FlxTypedGroup<Potion>(); // initializes potion group
		add(potion); // adds potion to state

		grunt = new FlxTypedGroup<Grunt>();
		add(grunt);

		player = new Player();
		map.loadEntities(placeEntities, "entities"); // goes through entities layer and places each one

		// assigns new instance of Player sprite to player variable
		add(player);

		// tells the camera to follow the player
		FlxG.camera.follow(player, TOPDOWN, 1);

		hud = new HUD(); // creates new instance of HUD
		add(hud); // adds HUD to state

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.collide(player, walls); // checks for collisions between player and walls, and disallows overlap
		FlxG.collide(potion, walls); // checks for collisions between potion and walls, disallows overlap

		FlxG.overlap(player, potion, playerTouchPotion); // after every frame, check for overlaps and call playerTouchPotion if one exists.

		FlxG.collide(grunt, walls);
		grunt.forEachAlive(checkEnemyVision);

		FlxG.collide(player, grunt, collided);

		if (health == 0)
		{
			FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
			{
				FlxG.switchState(new MenuState());
			});
		}
	}

	function placeEntities(entity:EntityData)
	{
		switch (entity.name)
		{
			case "player": // conditional if the entities name is player
				player.setPosition(entity.x, entity.y); // assigns the entities position to player
			case "potion": // conditional if the entities name is potion
				potion.add(new Potion(entity.x + 4, entity.y + 4)); // assigns the entities position to potion
			case "enemy": // conditional if entities name is grunt
				grunt.add(new Grunt(entity.x + 4, entity.y, REGULAR)); // assigns entities position to grunt
		}
	}

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

	function checkEnemyVision(grunt:Grunt)
	{
		if (walls.ray(grunt.getMidpoint(), player.getMidpoint()))
		{
			grunt.seesPlayer = true;
			grunt.playerPosition = player.getMidpoint();
			grunt.gruntPosition = grunt.getMidpoint();
		}
		else
		{
			grunt.seesPlayer = false;
		}
	}

	function collided(player:Player, grunt:Grunt):Void
	{
		if (grunt.playerPosition.x > grunt.gruntPosition.x)
		{
			player.velocity.set(50, -100);
			grunt.velocity.set(-50, -100);
		}
		else
		{
			player.velocity.set(-50, -100);
			grunt.velocity.set(50, -100);
		}

		player.flicker(1.3);
		switch (health)
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
		}
	}
}
