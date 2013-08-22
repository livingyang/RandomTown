
class RandomTownController
	constructor: (options) ->
		# @town = new RandomTown
		# 	floors: GenerateFloors options.floorCount, options.rows, options.cols, options.initLocation
		# 	hero: options.hero
		# 	heroFloorIndex: options.heroFloorIndex
		# 	heroLocation: options.initLocation

		# KeyboardJS.on "up", =>
		# 	@town.moveUp()
		# KeyboardJS.on "down", => @town.moveDown()
		# KeyboardJS.on "left", => @town.moveLeft()
		# KeyboardJS.on "right", => @town.moveRight()

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

	drawMap: (floor, heroLocation, layer) ->

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
		map.addObject heroTileX, heroTileY, (new collie.Text
			width: gridWidth
			height: gridHeight
			x: map.getTileIndexToPos(heroTileX, heroTileY).x
			y: map.getTileIndexToPos(heroTileX, heroTileY).y
			fontColor: "#000000"
		).text("英雄")

		for tileY, cols of floor
			for tileX, grid of cols
				map.addObject tileX, tileY, (new collie.Text
					width: gridWidth
					height: gridHeight
					x: map.getTileIndexToPos(tileX, tileY).x
					y: map.getTileIndexToPos(tileX, tileY).y
					fontColor: "#000000"
				).text(grid.object.type) if grid?.object?.type? and @town.isExistObject Number(tileY), Number(tileX)

	playMissionResult: (elParent) ->
		# console.log CommandHandle
		
		for key, handler of @keyboardHandle
			KeyboardJS.on key, handler

		rowCount = 11
		colCount = 11
		initLocation = [0, 0]
		floors = GenerateFloors 4, rowCount, colCount, initLocation, (row, col) ->
			if row % 2 is 0 and col % 2 is 0 then 0.5 else 0.8

		@town = new RandomTown
			floors: floors
			hero:
				name: "SuperManXX"
				attack: 100
				defense: 80
				health: 1000
				exp: 0
				money: 200
			heroFloorIndex: 0
			heroLocation: initLocation

		layerWidth = 320
		layerHeight = 320

		layer = new collie.Layer
			width : layerWidth
			height : layerHeight

		new collie.FPSConsole().load()
		collie.Renderer.addLayer layer
		collie.Renderer.load elParent
		collie.Renderer.start()
		
		@drawMap @town.getCurFloor(), @town.heroLocation, collie.Renderer.getLayers()[0]

	isPlaying: ->
		collie.Renderer.isPlaying()

	stopPlay: ->
		if @isPlaying()
			for key, handler of @keyboardHandle
				KeyboardJS.clear key

			collie.Renderer.stop()
			collie.Renderer.removeAllLayer()
			collie.Renderer.unload()
			collie.Timer.removeAll()

@RandomTownController = RandomTownController

# # town
# town = new RandomTown
# 	floors: [
# 		[
# 			[{ground: RandomTown.Road}, {ground: RandomTown.Wall}, {ground: RandomTown.Road}]
# 			[{ground: RandomTown.Road}, {ground: RandomTown.Road}, {ground: RandomTown.Road}]
# 			[{ground: RandomTown.Road}, {ground: RandomTown.Road}, {ground: RandomTown.Wall}]
# 		]
# 		[
# 			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
# 			[{ground: RandomTown.Road}, {ground: RandomTown.Road}, {ground: RandomTown.Road}]
# 			[{ground: RandomTown.Road}, {ground: RandomTown.Road}, {ground: RandomTown.Wall}]
# 		]
# 	]
# 	hero:
# 		name: "SuperManXX"
# 		attack: 100
# 		defense: 80
# 		health: 1000
# 		exp: 0
# 		money: 200
# 	heroFloorIndex: 0
# 	heroLocation: [1, 0]

# CommandHandle = {}
# CommandHandle.up = ->
# 	town.moveUp()
# 	CommandHandle.f()

# CommandHandle.down = ->
# 	town.moveDown()
# 	CommandHandle.f()

# CommandHandle.left = ->
# 	town.moveLeft()
# 	CommandHandle.f()

# CommandHandle.right = ->
# 	town.moveRight()
# 	CommandHandle.f()

# CommandHandle.f = (params) ->

# 	drawMap town.getCurFloor(), town.heroLocation, collie.Renderer.getLayers()[0]

# 	floorIndex = if params?[0]? and 0 < params[0] <= town.floors.length
# 	then Number(params[0]) - 1
# 	else town.heroFloorIndex

# 	floor = town.getSimpleFloors()[floorIndex]

# 	floor[town.heroLocation[0]][town.heroLocation[1]] = "Hero" if town.heroFloorIndex is floorIndex
	
# 	console.log "floor : #{floorIndex + 1}/#{town.floors.length}\n" + (cols.join "\t" for cols in floor).join "\n"

# CommandHandle["ctrl + \\"] = ->

# 	initLocation = [0, 0]
# 	floors = GenerateFloors 4, 8, 8, initLocation

# 	town = new RandomTown
# 		floors: floors
# 		hero:
# 			name: "SuperManXX"
# 			attack: 100
# 			defense: 80
# 			health: 1000
# 			exp: 0
# 			money: 200
# 		heroFloorIndex: 0
# 		heroLocation: initLocation

# 	CommandHandle.f()
	
# # functions

# getHolderImage = (imageName) ->
# 	image = $(document.createElement("img")).attr("data-src" : imageName)
# 	Holder.run({
# 		images: image[0]
# 	})
# 	image.attr("src")

# isPlayingMission = () ->
# 	collie.Renderer.isPlaying()

# stopPlayMissionResult = () ->
# 	if isPlayingMission
# 		for key, handler of CommandHandle
# 			KeyboardJS.clear key

# 		collie.Renderer.stop()
# 		collie.Renderer.removeAllLayer()
# 		collie.Renderer.unload()
# 		collie.Timer.removeAll()

# drawMap = (floor, heroLocation, layer) ->

# 	layer.removeChildren layer.getChildren()

# 	gridWidth = layer.get("width") / floor[0].length
# 	gridHeight = layer.get("height") / floor.length

# 	mapData = ({backgroundColor: if floor[row][col].ground is RandomTown.Road then "green" else "red"} for col in [0...floor[0].length] for row in [0...floor.length])

# 	map = (new collie.Map gridWidth, gridHeight,
# 		useEvent : true
# 	).addTo(layer).addObjectTo layer

# 	map.setMapData mapData

# 	heroTileX = heroLocation[1]
# 	heroTileY = heroLocation[0]
# 	map.addObject heroTileX, heroTileY, (new collie.Text
# 		width: gridWidth
# 		height: gridHeight
# 		x: map.getTileIndexToPos(heroTileX, heroTileY).x
# 		y: map.getTileIndexToPos(heroTileX, heroTileY).y
# 		fontColor: "#000000"
# 	).text("英雄")

# 	for tileY, cols of floor
# 		for tileX, grid of cols
# 			map.addObject tileX, tileY, (new collie.Text
# 				width: gridWidth
# 				height: gridHeight
# 				x: map.getTileIndexToPos(tileX, tileY).x
# 				y: map.getTileIndexToPos(tileX, tileY).y
# 				fontColor: "#000000"
# 			).text(grid.object.type) if grid?.object?.type? and town.isExistObject Number(tileY), Number(tileX)
	
# playMissionResult = (elParent) ->
# 	console.log CommandHandle
	
# 	for key, handler of CommandHandle
# 		KeyboardJS.on key, handler

# 	rowCount = 11
# 	colCount = 11
# 	initLocation = [0, 0]
# 	floors = GenerateFloors 4, rowCount, colCount, initLocation, (row, col) ->
# 		if row % 2 is 0 and col % 2 is 0 then 0.5 else 0.8

# 	town = new RandomTown
# 		floors: floors
# 		hero:
# 			name: "SuperManXX"
# 			attack: 100
# 			defense: 80
# 			health: 1000
# 			exp: 0
# 			money: 200
# 		heroFloorIndex: 0
# 		heroLocation: initLocation

# 	layerWidth = 320
# 	layerHeight = 320

# 	layer = new collie.Layer
# 		width : layerWidth
# 		height : layerHeight

# 	new collie.FPSConsole().load()
# 	collie.Renderer.addLayer layer
# 	collie.Renderer.load elParent
# 	collie.Renderer.start()
	
# 	drawMap town.getCurFloor(), town.heroLocation, collie.Renderer.getLayers()[0]

# @CommandHandle = CommandHandle
# @stopPlayMissionResult = stopPlayMissionResult
# @isPlayingMission = isPlayingMission
# @playMissionResult = playMissionResult