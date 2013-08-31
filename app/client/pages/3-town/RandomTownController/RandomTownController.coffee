
class RandomTownController

	@getInstance: => @instance ?= new this

	constructor: ->
		@keyboardHandle =
			"up": =>
				@town.moveUp()
				@keyboardHandle.f()
			"down": =>
				@town.moveDown()
				@keyboardHandle.f()
			"left": =>
				@town.moveLeft()
				@keyboardHandle.f()
			"right": =>
				@town.moveRight()
				@keyboardHandle.f()

			"f": =>
				@drawMap @town.getCurFloor(), @town.heroLocation, collie.Renderer.getLayers()[0]
				Session.set "hero", @town.hero

	drawMap: (floor, heroLocation, layer) ->

		collie.ImageManager.add "hero", "011-Braver01.png"
		collie.ImageManager.add "map", "203-other03.png"
		collie.ImageManager.add "road", "road2.png"
		collie.ImageManager.add "wall", "wall.png"
		# collie.ImageManager.add "sample", "item/plus.png"
		# collie.ImageManager.addSprite "sample",
		# 	hero: [0, 32]

		#  hole
		collie.ImageManager.add "hole", "hole1.png"
		
		# enemy
		collie.ImageManager.add "enemy", "monster/01.png"

		# plus
		collie.ImageManager.add "plus", "103-item03.png"
		collie.ImageManager.addSprite "plus",
			plus: [0, 0]

		# key
		collie.ImageManager.add "key", "101-item01.png"
		collie.ImageManager.addSprite "key",
			key: [0, 0]
		
		# door
		collie.ImageManager.add "door", "202-other02.png"
		collie.ImageManager.addSprite "door",
			door: [0, 0]

		layer.removeChildren layer.getChildren()

		gridWidth = 32
		gridHeight = 32

		# mapData = ({backgroundColor: if floor[row][col].ground is RandomTown.Road then "green" else "red"} for col in [0...floor[0].length] for row in [0...floor.length])
		mapData = for row in [0...floor.length]
			for col in [0...floor[0].length]
				# backgroundColor: if floor[row][col].ground is RandomTown.Road then "green" else "red"
				# spriteX: if floor[row][col].ground is RandomTown.Road then 2 else 1
				backgroundImage: if floor[row][col].ground is RandomTown.Road then "road" else "wall"

		map = (new collie.Map gridWidth, gridHeight,
			useEvent : true
		).addTo(layer).addObjectTo layer

		map.setMapData mapData

		for tileY, cols of floor
			for tileX, grid of cols				
				if grid?.object?.type? and @town.isExistObject Number(tileY), Number(tileX)	
					map.addObject tileX, tileY, new collie.DisplayObject
						width: gridWidth
						height: gridHeight
						x: map.getTileIndexToPos(tileX, tileY).x
						y: map.getTileIndexToPos(tileX, tileY).y
						backgroundImage: grid.object.type
						
		heroTileX = heroLocation[1]
		heroTileY = heroLocation[0]
		map.addObject heroTileX, heroTileY, new collie.DisplayObject
			width: gridWidth
			height: gridHeight
			x: map.getTileIndexToPos(heroTileX, heroTileY).x
			y: map.getTileIndexToPos(heroTileX, heroTileY).y
			# backgroundImage: "sample"
			# spriteSheet: "hero"
			backgroundImage: "hero"

		map.attach
			mapclick: ->
				new FightLayer
					width: 320
					height: 320
				.addTo()

	startGame: (options) ->

		if not options.divElement?
			return

		for key, handler of @keyboardHandle
			KeyboardJS.on key, handler

		@town = new RandomTown
			floors: GenerateFloors options.floorCount, options.rows, options.cols, options.initLocation, (row, col) ->
				if row % 2 is 0 and col % 2 is 0 then 0.5 else 0.8
			hero: options.hero
			heroFloorIndex: options.heroFloorIndex
			heroLocation: options.initLocation

		layerWidth = 32 * options.cols
		layerHeight = 32 * options.rows

		layer = new collie.Layer
			width : layerWidth
			height : layerHeight

		new collie.FPSConsole().load()
		collie.Renderer.addLayer layer
		collie.Renderer.load options.divElement
		collie.Renderer.start()
		
		@drawMap @town.getCurFloor(), @town.heroLocation, collie.Renderer.getLayers()[0]

	isPlaying: ->
		collie.Renderer.isPlaying()

	stopGame: ->
		Session.set "hero", null
		
		if @isPlaying()
			for key, handler of @keyboardHandle
				KeyboardJS.clear key

			collie.Renderer.stop()
			collie.Renderer.removeAllLayer()
			collie.Renderer.unload()
			collie.Timer.removeAll()


@RandomTownController = RandomTownController
