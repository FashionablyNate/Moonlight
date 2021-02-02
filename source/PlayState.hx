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

/* This is the class that controls the main play state of the game. */
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

	/* This is a built in function for creating sprites, maps and objects. */
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

	/* This is a built in function that updates everything inside it every frame */
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.collide(player, walls); // checks for collisions between player and walls, and disallows overlap
		FlxG.collide(potion, walls); // checks for collisions between potion and walls, disallows overlap

		FlxG.overlap(player, potion, playerTouchPotion); // after every frame, check for overlaps and call playerTouchPotion if one exists.

		FlxG.collide(grunt, walls); // allows grunts to not fall through floor
		grunt.forEachAlive(checkEnemyVision); // checks to see if grunt can see the player

		FlxG.collide(player, grunt, collided); // checks to see if the grunt has collided with the player
	}

	/* This is a function for assigning entity names from the map to variables */
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

	/* this is a function that decides what happens when a player touches a potion object */
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

	/* this is a function that determines if the player is close enough for an enemy to see them */
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

	/* this is a function that gets called when colliding with a melee enemy. */
	function collided(player:Player, grunt:Grunt):Void
	{
		if (!player.isFlickering())
		{
			if (grunt.playerPosition.x > grunt.gruntPosition.x) // if player is to the right of grunt
			{
				player.velocity.set(50, -100); // push player right
				grunt.velocity.set(-50, -100); // push grunt left
			}
			else // if player is to the left of grunt
			{
				player.velocity.set(-50, -100); // push player left
				grunt.velocity.set(50, -100); // push grunt right
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
}
