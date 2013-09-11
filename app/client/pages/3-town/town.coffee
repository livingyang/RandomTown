Template.town.rendered = ->
	collie.Renderer.load document.getElementById "fight"
	collie.Renderer.start()
	new collie.FPSConsole().load()
	
Template.town.destroyed = ->
	Mousetrap.reset()
	stopCollie()

Template.town.events "click .mapControlButton" : ->
	Mousetrap.trigger @key

Template.town.mapControlButtons = ->
	(key: key for key in ["up", "down", "left", "right"])

Template.hero.hero = ->
	Session.get "hero"

Template.town.floorInfo = ->
	Session.get "floorInfo"

stopCollie = ->
	if collie.Renderer.isPlaying()
		collie.Renderer.stop()
		collie.Renderer.removeAllLayer()
		collie.Renderer.unload()
		collie.Timer.removeAll()

createRandomTown = (options) ->
	new RandomTown
		floors: GenerateFloors options.floorCount, options.rows, options.cols, options.initLocation, (row, col) ->
			if row % 2 is 0 and col % 2 is 0 then 0.5 else 0.8
		hero: options.hero
		heroFloorIndex: options.heroFloorIndex
		heroLocation: options.initLocation

randomTownCache = null
saveRandomTown = (randomTown) ->
	randomTownCache = JSON.parse JSON.stringify randomTown

loadRandomTown = ->
	randomTownCache

class @TownController extends RouteController
	template: "town"

	run: ->
		# 1 创建RandomTown
		@randomTown = loadRandomTown()
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
			saveRandomTown @randomTown

		# set delegate func
		@randomTown.onFloorChanged = (oldFloorIndex, newFloorIndex) =>
			@resetMap()
			saveRandomTown @randomTown
			Session.set "floorInfo", "#{@randomTown.heroFloorIndex + 1}/#{@randomTown.floors.length}"

		@randomTown.onHeroMove = (oldLocation, newLocation, direction) =>
			@moveHeroObject @heroObject, newLocation, @map
		@randomTown.onHeroChanged = =>
			Session.set "hero", @randomTown.hero
		@randomTown.onUsePlus = (plusLocation) =>
			@map.removeObject (@map.getObjects plusLocation[1], plusLocation[0])[0]
		@randomTown.onPickupKey = (keyLocation) =>
			@map.removeObject (@map.getObjects keyLocation[1], keyLocation[0])[0]
		@randomTown.onOpenDoor = (doorLocation) =>
			@map.removeObject (@map.getObjects doorLocation[1], doorLocation[0])[0]
		@randomTown.onFightEnemy = (enemyLocation, heroFight, enemy) =>
			@map.removeObject (@map.getObjects enemyLocation[1], enemyLocation[0])[0]
			fightLayer = new FightLayer
				width: 320
				height: 320
				start: -> Mousetrap.pause()
				stop: -> Mousetrap.unpause()
			.addTo()

		Session.set "hero", @randomTown.hero
		Session.set "floorInfo", "#{@randomTown.heroFloorIndex + 1}/#{@randomTown.floors.length}"

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

		# create
		layerWidth = 32 * @randomTown.getFloorCols()
		layerHeight = 32 * @randomTown.getFloorRows()

		@mapLayer = new collie.Layer
			width : layerWidth
			height : layerHeight
		collie.Renderer.addLayer @mapLayer
		@heroObject = @createHeroObject()
		@resetMap()

		# 绑定事件
		Mousetrap.bind ["up", "w"], =>
			@randomTown.moveUp()
		Mousetrap.bind ["down", "s"], =>
			@randomTown.moveDown()
		Mousetrap.bind ["left", "a"], =>
			@randomTown.moveLeft()
		Mousetrap.bind ["right", "d"], =>
			@randomTown.moveRight()
		super

	data: ->
		hero: Session.get "hero"

	createHeroObject: (hero) ->
		new collie.DisplayObject
			width: 32
			height: 32
			backgroundImage: "hero"
	
	resetMap: ->

		@mapLayer.removeChildren @mapLayer.getChildren()

		mapData = for row in [0...@randomTown.getCurFloor().length]
			for col in [0...@randomTown.getCurFloor()[0].length]
				backgroundImage: if @randomTown.getCurFloor()[row][col].ground is RandomTown.Road then "road" else "wall"

		@map = (new collie.Map 32, 32,
			useEvent : true
		).addTo(@mapLayer).addObjectTo @mapLayer
		
		for tileY, cols of @randomTown.getCurFloor()
			for tileX, grid of cols				
				if grid?.object?.type? and @randomTown.isExistObject Number(tileY), Number(tileX)	
					@map.addObject tileX, tileY, new collie.DisplayObject
						width: 32
						height: 32
						x: @map.getTileIndexToPos(tileX, tileY).x
						y: @map.getTileIndexToPos(tileX, tileY).y
						backgroundImage: grid.object.type
		
		@map.setMapData mapData
		@map.addObject 0, 0, @heroObject
		@moveHeroObject @heroObject, @randomTown.heroLocation, @map

		@map.attach
			mapclick: ->
				new FightLayer
					width: 320
					height: 320
				.addTo()
	moveHeroObject: (heroObject, heroLocation, map) ->
		map.moveObject heroLocation[1], heroLocation[0], heroObject
		heroObject.set
			x: map.getTileIndexToPos(heroLocation[1], heroLocation[0]).x
			y: map.getTileIndexToPos(heroLocation[1], heroLocation[0]).y