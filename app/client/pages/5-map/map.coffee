setPageNameToList "map"

# town
town = new RandomTown
	floors: [
		[
			[{ground: RandomTown.Road}, {ground: RandomTown.Wall}, {ground: RandomTown.Road}]
			[{ground: RandomTown.Road}, {ground: RandomTown.Road}, {ground: RandomTown.Road}]
			[{ground: RandomTown.Road}, {ground: RandomTown.Road}, {ground: RandomTown.Wall}]
		]
		[
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Road}, {ground: RandomTown.Road}, {ground: RandomTown.Road}]
			[{ground: RandomTown.Road}, {ground: RandomTown.Road}, {ground: RandomTown.Wall}]
		]
	]
	hero:
		name: "SuperManXX"
		attack: 100
		defense: 80
		health: 1000
		exp: 0
		money: 200
	heroFloorIndex: 0
	heroLocation: [1, 0]

CommandHandle = {}
CommandHandle.up = ->
	town.moveUp()
	CommandHandle.f()

CommandHandle.down = ->
	town.moveDown()
	CommandHandle.f()

CommandHandle.left = ->
	town.moveLeft()
	CommandHandle.f()

CommandHandle.right = ->
	town.moveRight()
	CommandHandle.f()

CommandHandle.f = (params) ->

	drawMap town.getCurFloor(), town.heroLocation, collie.Renderer.getLayers()[0]

	floorIndex = if params?[0]? and 0 < params[0] <= town.floors.length
	then Number(params[0]) - 1
	else town.heroFloorIndex

	floor = town.getSimpleFloors()[floorIndex]

	floor[town.heroLocation[0]][town.heroLocation[1]] = "Hero" if town.heroFloorIndex is floorIndex
	
	console.log "floor : #{floorIndex + 1}/#{town.floors.length}\n" + (cols.join "\t" for cols in floor).join "\n"

CommandHandle["ctrl + \\"] = ->

	initLocation = [0, 0]
	floors = GenerateFloors 4, 8, 8, initLocation

	town = new RandomTown
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

	CommandHandle.f()
	
# functions

getHolderImage = (imageName) ->
	image = $(document.createElement("img")).attr("data-src" : imageName)
	Holder.run({
		images: image[0]
	})
	image.attr("src")

isPlayingMission = () ->
	collie.Renderer.isPlaying()

stopPlayMissionResult = () ->
	collie.Renderer.stop()
	collie.Renderer.removeAllLayer()
	collie.Renderer.unload()
	collie.Timer.removeAll()

drawMap = (floor, heroLocation, layer) ->

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
			).text(grid.object.type) if grid?.object?.type? and town.isExistObject Number(tileY), Number(tileX)

playMissionResult = (elParent, generator) ->

	rowCount = 11
	colCount = 11
	initLocation = [0, 0]
	floors = GenerateFloors 4, rowCount, colCount, initLocation, (row, col) ->
		if row % 2 is 0 and col % 2 is 0 then 0.5 else 0.8

	town = new RandomTown
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
	
	drawMap town.getCurFloor(), town.heroLocation, collie.Renderer.getLayers()[0]

Template.map.created = ->
	KeyboardJS.on "a", ->
    	console.log "you pressed a!"

    for key, handler of CommandHandle
    	KeyboardJS.on key, handler
    

Template.map.destroyed = ->
	# KeyboardJS.clear "a"
	for key, handler of CommandHandle
    	KeyboardJS.clear key

	stopPlayMissionResult()

Template.map.events "click #start" : ->

	generator = new MazeGenerator(10, 10)
	generator.createBlocks 0.3

	if isPlayingMission()
		stopPlayMissionResult()
	else
		playMissionResult document.getElementById("fight"), generator

Template.map.events "click .mapControlButton" : ->
	# console.log @key
	# console.log CommandHandle[@key]
	CommandHandle[@key]?()

Template.map.mapControlButtons = ->
	(key: key for key, func of CommandHandle)