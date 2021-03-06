Template.town.rendered = ->
	collie.Renderer.load document.getElementById "fight"
	collie.Renderer.start()
	new collie.FPSConsole().load()
	
Template.town.destroyed = ->
	Mousetrap.reset()
	stopCollie()

Template.town.events "click #backToHome": ->
	Mousetrap.trigger "h"

Template.hero.hero = ->
	Session.get "hero"

Template.town.floorInfo = ->
	Session.get "floorInfo"

joystickEventHandle = (eleEvents, handle) ->
	angle = Math.atan2 eleEvents.offsetY - eleEvents.toElement.clientHeight / 2, eleEvents.offsetX - eleEvents.toElement.clientWidth / 2
	area = Math.floor (angle + Math.PI) / Math.PI * 4
	flag = 
		7: "left"
		0: "left"
		1: "up"
		2: "up"
		3: "right"
		4: "right"
		5: "down"
		6: "down"

	handle?[flag[area]]?()

Template.town.events "click #joystick": (events) ->
	joystickEventHandle events,
		"up": -> Mousetrap.trigger "up"
		"down": -> Mousetrap.trigger "down"
		"left": -> Mousetrap.trigger "left"
		"right": -> Mousetrap.trigger "right"

stopCollie = ->
	if collie.Renderer.isPlaying()
		collie.Renderer.stop()
		collie.Renderer.removeAllLayer()
		collie.Renderer.unload()
		collie.Timer.removeAll()

class @TownController extends RouteController
	template: "town"

	onAfterRun: ->

		if not isRandomTownExist()
			Router.go "home"
			return super

		# 1 创建RandomTown
		options = loadRandomTown()
		options.hero = loadHero()
		@randomTown = new RandomTown options
		
		# set delegate func
		@randomTown.onFloorChanged = (oldFloorIndex, newFloorIndex) =>
			@resetMap()
			saveRandomTown @randomTown
			Session.set "floorInfo", "#{@randomTown.heroFloorIndex + 1}/#{@randomTown.floors.length}"

		@randomTown.onHeroMove = (oldLocation, newLocation, direction) =>
			@moveHeroObject @heroObject, newLocation, @map
		@randomTown.onHeroChanged = =>
			saveHero @randomTown.hero
		@randomTown.onUsePlus = (plusLocation) =>
			@map.removeObject (@map.getObjects plusLocation[1], plusLocation[0])[0]
		@randomTown.onPickupKey = (keyLocation) =>
			@map.removeObject (@map.getObjects keyLocation[1], keyLocation[0])[0]
		@randomTown.onOpenDoor = (doorLocation) =>
			@map.removeObject (@map.getObjects doorLocation[1], doorLocation[0])[0]
		@randomTown.onFightEnemy = (enemyLocation, heroFight, enemy) =>
			enemyObject = (@map.getObjects enemyLocation[1], enemyLocation[0])[0]
			curFightTurn = 0
			fightLayer = new FightLayer
				width: @mapLayer.get "width"
				height: @mapLayer.get "height"
				start: -> Mousetrap.pause()
				step: -> ++curFightTurn
				stop: ->
					Mousetrap.unpause()
					heroFight.enableFight curFightTurn
					# if heroFight.isLose()
						# deadInRandomTown()
				heroFight: heroFight
				heroObject: @heroObject.clone()
				enemyObject: enemyObject.clone()
			.addTo()
			# @map.removeObject enemyObject if heroFight.isWin()
		@randomTown.onHeroDead = =>
			deadInRandomTown()
		@randomTown.onEnemyDead = (enemyLocation, enemy) =>
			enemyObject = (@map.getObjects enemyLocation[1], enemyLocation[0])[0]
			@map.removeObject enemyObject
		@randomTown.onEnterBeginHole = =>
			backToHome @randomTown
		@randomTown.onEnterEndHole = =>
			completeRandomTown @randomTown

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
		Mousetrap.unpause()
		Mousetrap.bind ["up", "w"], =>
			@randomTown.moveUp()
		Mousetrap.bind ["down", "s"], =>
			@randomTown.moveDown()
		Mousetrap.bind ["left", "a"], =>
			@randomTown.moveLeft()
		Mousetrap.bind ["right", "d"], =>
			@randomTown.moveRight()
		Mousetrap.bind ["h"], =>
			backToHome @randomTown
		super

	data: ->
		hero: loadHero()

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

		# @map.attach
		# 	mapclick: ->
		# 		new FightLayer
		# 			width: @mapLayer.get "width"
		# 			height: @mapLayer.get "height"
		# 		.addTo()
	moveHeroObject: (heroObject, heroLocation, map) ->
		map.moveObject heroLocation[1], heroLocation[0], heroObject
		heroObject.set
			x: map.getTileIndexToPos(heroLocation[1], heroLocation[0]).x
			y: map.getTileIndexToPos(heroLocation[1], heroLocation[0]).y