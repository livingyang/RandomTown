
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
			"h": =>
				console.log @town.hero


	drawMap: (floor, heroLocation, layer) ->

		# collie.ImageManager.add "hero", "monster/01.png"
		collie.ImageManager.add "sample", "item/plus.png"
		collie.ImageManager.addSprite "sample",
			hero: [0, 32]

		layer.removeChildren layer.getChildren()

		gridWidth = layer.get("width") / floor[0].length
		gridHeight = layer.get("height") / floor.length

		mapData = ({backgroundColor: if floor[row][col].ground is RandomTown.Road then "green" else "red"} for col in [0...floor[0].length] for row in [0...floor.length])

		map = (new collie.Map gridWidth, gridHeight,
			useEvent : true
		).addTo(layer).addObjectTo layer

		map.setMapData mapData

		heroTileX = heroLocation[1]
		heroTileY = heroLocation[0]
		# map.addObject heroTileX, heroTileY, (new collie.Text
		# 	width: gridWidth
		# 	height: gridHeight
		# 	x: map.getTileIndexToPos(heroTileX, heroTileY).x
		# 	y: map.getTileIndexToPos(heroTileX, heroTileY).y
		# 	fontColor: "#000000"
		# ).text("英雄")

		map.addObject heroTileX, heroTileY, new collie.DisplayObject
			width: gridWidth
			height: gridHeight
			x: map.getTileIndexToPos(heroTileX, heroTileY).x
			y: map.getTileIndexToPos(heroTileX, heroTileY).y
			backgroundImage: "sample"
			spriteSheet: "hero"

		for tileY, cols of floor
			for tileX, grid of cols
				map.addObject tileX, tileY, (new collie.Text
					width: gridWidth
					height: gridHeight
					x: map.getTileIndexToPos(tileX, tileY).x
					y: map.getTileIndexToPos(tileX, tileY).y
					fontColor: "#000000"
				).text(grid.object.type) if grid?.object?.type? and @town.isExistObject Number(tileY), Number(tileX)

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

		layerWidth = 400
		layerHeight = 400

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
