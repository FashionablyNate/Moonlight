package;

import AssetsPaths.AssetPaths;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import js.html.CaretPosition;

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
}
