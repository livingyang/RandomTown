###
floors = [], object = floor, indexName = floorIndex
floor = [], object = grid, indexName = [row, col]
grid = {ground: xxx, object: xxx}
###

class RandomTown
	constructor: (options) ->
		options ?= {}
		{@floors, @hero, @heroFloorIndex, @heroLocation} = options

	getFloor: (floorIndex) ->
		@floors[floorIndex]

	getCurFloor: ->
		@getFloor(@heroFloorIndex)

	getFloorGrid: (floor, row, col) ->
		floor[row][col]

	getSimpleFloors: ->
		simpleFloors = []
		for floor in @floors
			simpleFloor = []
			simpleFloors.push simpleFloor	
			for cols in floor
				simpleFloorCols = []
				simpleFloor.push simpleFloorCols
				for grid in cols
					simpleFloorCols.push if grid.object?.type? and RandomTown.ObjectHandle[grid.object.type]?.getSimpleData?
					then RandomTown.ObjectHandle[grid.object.type].getSimpleData grid.object, String(grid.ground)
					else String(grid.ground)
		simpleFloors

	moveHandle: (row, col) ->
		return if not (0 <= row < @getCurFloor().length) or not (0 <= col < @getCurFloor()[0].length)
		
		grid = @getFloorGrid @getCurFloor(), row, col

		if grid.ground is RandomTown.Road and grid.object?.type? and RandomTown.ObjectHandle[grid.object.type]?
			RandomTown.ObjectHandle[grid.object.type].onEnter @, grid.object, @heroLocation, [row, col]
		else
			@heroLocation = [row, col] if grid.ground is RandomTown.Road

	moveUp: ->
		@moveHandle @heroLocation[0] - 1, @heroLocation[1]

	moveDown: ->
		@moveHandle @heroLocation[0] + 1, @heroLocation[1]

	moveLeft: ->
		@moveHandle @heroLocation[0], @heroLocation[1] - 1

	moveRight: ->
		@moveHandle @heroLocation[0], @heroLocation[1] + 1

RandomTown.Wall = -1
RandomTown.Road = 0
RandomTown.ObjectHandle = {}

@RandomTown = RandomTown

###
class HeroFight
###

class HeroFight
	constructor: (options) ->
		options ?= {}

		@attacker = JSON.parse(JSON.stringify(options.attacker ? {}))
		@defenser = JSON.parse(JSON.stringify(options.defenser ? {}))
		@maxTurnCount = options.maxTurnCount

		for turnIndex in [0...@maxTurnCount]
			[attacker, defenser] = if turnIndex % 2 is 0
			then [@attacker, @defenser]
			else [@defenser, @attacker]

			defenser.health -= attacker.attack - defenser.defense
			break if defenser.health <= 0

@HeroFight = HeroFight

###
	RandomTown object handles
###

RandomTown.ObjectHandle["hole"] =
	onEnter: (town, object, enterLocation, objectLocation) ->
		town.heroFloorIndex = object.floorIndex
		town.heroLocation = object.location

	getSimpleData: (object, ground) ->
		object.type

RandomTown.ObjectHandle["plus"] =
	onEnter: (town, object, enterLocation, objectLocation) ->
		if object.isUsed is true
			town.heroLocation = objectLocation
		else
			object.isUsed = true
			for property, value of object
				town.hero[property] += value if typeof town.hero[property] is "number" and typeof object[property] is "number"

	getSimpleData: (object, ground) ->
		if object.isUsed is true then ground else object.type

RandomTown.ObjectHandle["key"] =
	onEnter: (town, object, enterLocation, objectLocation) ->
		if object.isPickup is true
			town.heroLocation = objectLocation
		else
			object.isPickup = true
			town.hero.key ?= {}
			town.hero.key[object.color] ?= 0
			++town.hero.key[object.color]

	getSimpleData: (object, ground) ->
		if object.isPickup is true then ground else object.type

RandomTown.ObjectHandle["door"] =
	onEnter: (town, object, enterLocation, objectLocation) ->
		if object.isUnlock is true
			town.heroLocation = objectLocation
		else
			if town.hero.key?[object.color] > 0
				object.isUnlock = true
				--town.hero.key[object.color]

	getSimpleData: (object, ground) ->
		if object.isUnlock is true then ground else object.type

RandomTown.ObjectHandle["enemy"] =
	onEnter: (town, object, enterLocation, objectLocation) ->
		if object.health <= 0
			town.heroLocation = objectLocation
		else
			heroFight = new HeroFight
				attacker: town.hero
				defenser: object
				maxTurnCount: 100

			town.hero.health = heroFight.attacker.health
			object.health = heroFight.defenser.health
			town.hero.exp += object.exp
			town.hero.money += object.money

	getSimpleData: (object, ground) ->
		if object.health <= 0 then ground else object.type
