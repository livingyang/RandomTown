setPageNameToList "map"

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

	layerWidth = 700
	layerHeight = 700

	gridWidth = layerWidth / generator.cols
	gridHeight = layerHeight / generator.rows
	gridSize = "#{gridWidth}x#{gridHeight}"

	collie.ImageManager.add
		road : getHolderImage("holder.js/#{gridSize}/#aaa:#fff/text: ")
		block : getHolderImage("holder.js/#{gridSize}/#555:#fff/text: ")
		role : getHolderImage("holder.js/#{gridSize}/#f00:#fff/text: ")

	layer = new collie.Layer
		width : layerWidth
		height : layerHeight

	rowLength = 20
	colLength = 20
	objectCount = 10
	tileSize = 30 # px
	mapData = []
	row = 0

	while row < rowLength
	  rowData = []
	  col = 0

	  while col < colLength
	    rowData.push backgroundColor: (if Math.random() > 0.5 then "red" else "yellow") # A Tile data doesn't necessary to contain dimension and position.
	    col++
	  mapData.push rowData
	  row++

	# Create a Map instance
	map = new collie.Map(tileSize, tileSize,
	  useEvent: true
	  useLiveUpdate: false
	).addTo(layer).addObjectTo(layer)

	# Add a mapdata.
	map.setMapData mapData

	# Add objects for display on the map.
	i = 0

	while i < objectCount
	  tileX = Math.round(Math.random() * (colLength - 1))
	  tileY = Math.round(Math.random() * (rowLength - 1))
	  pos = map.getTileIndexToPos(tileX, tileY)
	  map.addObject tileX, tileY, new collie.DisplayObject(
	    x: pos.x + 5
	    y: pos.y + 5
	    width: tileSize - 10
	    height: tileSize - 10
	    backgroundColor: "blue"
	  )
	  i++

	# Attach a event handler.
	map.attach mapclick: (e) ->
	  console.log e.tileX, e.tileY

	new collie.FPSConsole().load();
	collie.Renderer.addLayer layer
	collie.Renderer.load elParent
	collie.Renderer.start()

Template.map.destroyed = ->
	stopPlayMissionResult()

Template.map.events "click #start" : ->

	generator = new MazeGenerator(10, 10)
	generator.createBlocks 0.3

	if isPlayingMission()
		stopPlayMissionResult()
	else
		playMissionResult document.getElementById("fight"), generator