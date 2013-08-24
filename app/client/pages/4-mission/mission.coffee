# setPageNameToList "mission"

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

playMissionResult = (elParent, generator) ->

	layerWidth = 320
	layerHeight = 320

	gridWidth = 320 / generator.cols
	gridHeight = 320 / generator.rows
	gridSize = "#{gridWidth}x#{gridHeight}"

	collie.ImageManager.add
		road : getHolderImage("holder.js/#{gridSize}/#aaa:#fff/text: ")
		block : getHolderImage("holder.js/#{gridSize}/#555:#fff/text: ")
		role : getHolderImage("holder.js/#{gridSize}/#f00:#fff/text: ")

	layer = new collie.Layer
		width : layerWidth
		height : layerHeight

	role = new collie.DisplayObject(
			x: 0
			y: 0
			zIndex: 10
			backgroundImage: "role"
		)

	for index, grid of generator.grids
		rowColIndex = generator.getRowColFromGridIndex(index)

		road = new collie.DisplayObject(
			x: gridWidth * rowColIndex[1]
			y: gridHeight * rowColIndex[0]
			backgroundImage: if grid is MazeGenerator.BlockGrid then "block" else "road"
		).addTo(layer)

		road.rowColIndex = rowColIndex
		road.maze = generator

		road.attach
			"click" : (oEvent) ->
				rowColIndex = oEvent.displayObject.rowColIndex
				if oEvent.displayObject.maze.getGrid(rowColIndex[0], rowColIndex[1]) is MazeGenerator.InitGrid
					console.log "move to #{rowColIndex}" 
					if role.getParent() isnt false
						role.getParent().removeChild(role)
					oEvent.displayObject.addChild role

	new collie.FPSConsole().load();
	collie.Renderer.addLayer layer
	collie.Renderer.load elParent
	collie.Renderer.start()
	collie.Renderer.resize layer.get("width"), layer.get("height"), true

	console.log layer
	console.log layer.get "height"
	console.log layer.get "x"

Template.mission.destroyed = ->
	stopPlayMissionResult()

Template.mission.events "click #start" : ->

	generator = new MazeGenerator(10, 10)
	generator.createBlocks 0.3

	if isPlayingMission()
		stopPlayMissionResult()
	else
		playMissionResult document.getElementById("fight"), generator