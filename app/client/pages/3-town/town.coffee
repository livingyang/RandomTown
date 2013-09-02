Template.town.rendered = ->
	collie.Renderer.load document.getElementById "fight"
	collie.Renderer.start()
	new collie.FPSConsole().load()
	
Template.town.destroyed = ->
	RandomTownController.getInstance().stopGame()
	Mousetrap.reset()
	stopCollie()


Template.town.events "click .mapControlButton" : ->
	RandomTownController.getInstance().keyboardHandle[@key]?()

Template.town.events "click #start" : ->
	return
	RandomTownController.getInstance().startGame
		divElement: document.getElementById "fight"
		floorCount: 4
		rows: 11
		cols: 11
		initLocation: [0, 0]
		heroFloorIndex: 0
		hero:
			name: "SuperManXX"
			attack: 100
			defense: 80
			health: 1000
			exp: 0
			money: 200
			key:
				yellow: 1

	Session.set "hero", RandomTownController.getInstance().town.hero if RandomTownController.getInstance()?.town?.hero?

Template.town.mapControlButtons = ->
	(key: key for key, func of RandomTownController.getInstance().keyboardHandle)

Template.town.hasHero = ->
	(Session.get "hero")?

Template.hero.hero = ->
	Session.get "hero"

Template.town.lastEnemy = ->
	(Session.get "lastEnemy")?

Template.enemy.enemy = ->
	Session.get "lastEnemy"

drawMap = (floor, heroLocation, layer, town) ->

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
			if grid?.object?.type? and town.isExistObject Number(tileY), Number(tileX)	
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

stopCollie = ->
	if collie.Renderer.isPlaying()
		collie.Renderer.stop()
		collie.Renderer.removeAllLayer()
		collie.Renderer.unload()
		collie.Timer.removeAll()

resetTown = (town) ->
	# stopCollie()

	layerWidth = 32 * town.getFloorCols()
	layerHeight = 32 * town.getFloorRows()

	layer = new collie.Layer
		width : layerWidth
		height : layerHeight

	collie.Renderer.removeAllLayer()
	collie.Renderer.addLayer layer

	drawMap town.getCurFloor(), town.heroLocation, layer, town

createRandomTown = (options) ->
	new RandomTown
		floors: GenerateFloors options.floorCount, options.rows, options.cols, options.initLocation, (row, col) ->
			if row % 2 is 0 and col % 2 is 0 then 0.5 else 0.8
		hero: options.hero
		heroFloorIndex: options.heroFloorIndex
		heroLocation: options.initLocation

class @TownController extends RouteController
	template: "town"

	run: ->
		# 1 创建RandomTown
		@randomTown = Session.get "randomTown"
		if @randomTown?
			@randomTown = new RandomTown @randomTown
		else
			@randomTown = createRandomTown
				floorCount: 4
				rows: 11
				cols: 11
				initLocation: [0, 0]
				heroFloorIndex: 0
				hero:
					name: "SuperManXX"
					attack: 100
					defense: 80
					health: 1000
					exp: 0
					money: 200
					key:
						yellow: 1
			Session.set "randomTown", @randomTown

		@randomTown.delegate = this

		# resetTown @randomTown
		

		# drawMap town.getCurFloor(), town.heroLocation, layer, town

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

		# layer.removeChildren layer.getChildren()

		# gridWidth = 32
		# gridHeight = 32

		# # mapData = ({backgroundColor: if floor[row][col].ground is RandomTown.Road then "green" else "red"} for col in [0...floor[0].length] for row in [0...floor.length])
		# mapData = for row in [0...@randomTown.getCurFloor().length]
		# 	for col in [0...@randomTown.getCurFloor()[0].length]
		# 		# backgroundColor: if floor[row][col].ground is RandomTown.Road then "green" else "red"
		# 		# spriteX: if floor[row][col].ground is RandomTown.Road then 2 else 1
		# 		backgroundImage: if @randomTown.getCurFloor()[row][col].ground is RandomTown.Road then "road" else "wall"

		# @map = (new collie.Map gridWidth, gridHeight,
		# 	useEvent : true
		# ).addTo(layer).addObjectTo layer

		# @map.setMapData mapData

		# for tileY, cols of @randomTown.getCurFloor()
		# 	for tileX, grid of cols				
		# 		if grid?.object?.type? and @randomTown.isExistObject Number(tileY), Number(tileX)	
		# 			@map.addObject tileX, tileY, new collie.DisplayObject
		# 				width: gridWidth
		# 				height: gridHeight
		# 				x: @map.getTileIndexToPos(tileX, tileY).x
		# 				y: @map.getTileIndexToPos(tileX, tileY).y
		# 				backgroundImage: grid.object.type
						
		# heroTileX = @randomTown.heroLocation[1]
		# heroTileY = @randomTown.heroLocation[0]
		# @heroObject = new collie.DisplayObject
		# 	width: gridWidth
		# 	height: gridHeight
		# 	x: @map.getTileIndexToPos(heroTileX, heroTileY).x
		# 	y: @map.getTileIndexToPos(heroTileX, heroTileY).y
		# 	# backgroundImage: "sample"
		# 	# spriteSheet: "hero"
		# 	backgroundImage: "hero"
		# @map.addObject heroTileX, heroTileY, @heroObject
		@resetMap()
		
		# 绑定事件
		Mousetrap.bind "up", =>
			@randomTown.moveUp()
			# resetTown @randomTown
		Mousetrap.bind "down", =>
			@randomTown.moveDown()
			# resetTown @randomTown
		Mousetrap.bind "left", =>
			@randomTown.moveLeft()
			# resetTown @randomTown
		Mousetrap.bind "right", =>
			@randomTown.moveRight()
			# resetTown @randomTown
		super

	data: ->
		hero: Session.get "hero"

	# RandomTownDelegate
	onFloorChanged: (oldFloorIndex, newFloorIndex) ->
	onHeroMove: (oldLocation, newLocation, direction) ->
		# console.log arguments
		# console.log @map.getObjects oldLocation[1], oldLocation[0]
		# @map.moveObject newLocation[1], newLocation[0], @heroObject
		# @heroObject.set
		# 	x: @map.getTileIndexToPos(newLocation[1], newLocation[0]).x
		# 	y: @map.getTileIndexToPos(newLocation[1], newLocation[0]).y
		@moveHeroObject @heroObject, newLocation, @map
	onHeroChanged: ->
	onUsePlus: (plusLocation) ->
		@map.removeObject (@map.getObjects plusLocation[1], plusLocation[0])[0]
	onPickupKey: (keyLocation) ->
		@map.removeObject (@map.getObjects keyLocation[1], keyLocation[0])[0]
	onOpenDoor: (doorLocation) ->
		@map.removeObject (@map.getObjects doorLocation[1], doorLocation[0])[0]
	onFightEnemy: (enemyLocation, heroFight) ->
		@map.removeObject (@map.getObjects enemyLocation[1], enemyLocation[0])[0]
	
	createHeroObject: (hero) ->
		new collie.DisplayObject
			width: 32
			height: 32
			backgroundImage: "hero"
	
	resetMap: ->
		# clear
		collie.Renderer.removeAllLayer()

		# create
		layerWidth = 32 * @randomTown.getFloorCols()
		layerHeight = 32 * @randomTown.getFloorRows()

		layer = new collie.Layer
			width : layerWidth
			height : layerHeight

		collie.Renderer.addLayer layer

		mapData = for row in [0...@randomTown.getCurFloor().length]
			for col in [0...@randomTown.getCurFloor()[0].length]
				backgroundImage: if @randomTown.getCurFloor()[row][col].ground is RandomTown.Road then "road" else "wall"

		@map = (new collie.Map 32, 32,
			useEvent : true
		).addTo(layer).addObjectTo layer

		@map.setMapData mapData
		@heroObject = @createHeroObject @randomTown.hero
		@map.addObject 0, 0, @heroObject
		@moveHeroObject @heroObject, @randomTown.heroLocation, @map

	moveHeroObject: (heroObject, heroLocation, map) ->
		map.moveObject heroLocation[1], heroLocation[0], heroObject
		heroObject.set
			x: map.getTileIndexToPos(heroLocation[1], heroLocation[0]).x
			y: map.getTileIndexToPos(heroLocation[1], heroLocation[0]).y