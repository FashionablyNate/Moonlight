package;

import AssetsPaths.AssetPaths;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState
{
	// defines player variable
	var player:Player;
	// variable to hold ogmo map
	var map:FlxOgmo3Loader;
	// variable to hold FlxTilemap
	var walls:FlxTilemap;

	override public function create()
	{
		map = new FlxOgmo3Loader(AssetPaths.moonlight__ogmo, AssetPaths.room_001__json); // initializes map to variable
		walls = map.loadTilemap(AssetPaths.tiles__png, "walls"); // generates FlxTilemap from walls layer
		walls.follow();
		walls.setTileProperties(1, FlxObject.NONE); // sets tile 1 to allow passover
		walls.setTileProperties(2, FlxObject.ANY); // sets tile 2 to collide
		add(walls); // add walls to state

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
	}

	function placeEntities(entity:EntityData)
	{
		if (entity.name == "player") // conditional if the entities name is player
		{
			player.setPosition(entity.x, entity.y); // assigns the entities position to player
		}
	}
}
