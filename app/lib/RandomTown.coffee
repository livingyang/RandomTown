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

	moveHandle: (row, col) ->
		return if not (0 <= row < @getCurFloor().length) or not (0 <= col < @getCurFloor()[0].length)
		
		grid = @getFloorGrid @getCurFloor(), row, col

		if grid.object?.type? and RandomTown.ObjectHandle[grid.object.type]?
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
	RandomTown object handles
###

RandomTown.ObjectHandle["hole"] =
	onEnter: (town, object, enterLocation, objectLocation) ->
		town.heroFloorIndex = object.floorIndex
		town.heroLocation = object.location

RandomTown.ObjectHandle["plus"] =
	onEnter: (town, object, enterLocation, objectLocation) ->
		if object.isUsed is true
			town.heroLocation = objectLocation
		else
			object.isUsed = true
			for property, value of object
				town.hero[property] += value if typeof town.hero[property] is "number" and typeof object[property] is "number"

RandomTown.ObjectHandle["key"] =
	onEnter: (town, object, enterLocation, objectLocation) ->
		if object.isPickup is true
			town.heroLocation = objectLocation
		else
			object.isPickup = true
			town.hero.key ?= {}
			town.hero.key[object.color] ?= 0
			++town.hero.key[object.color]

RandomTown.ObjectHandle["door"] =
	onEnter: (town, object, enterLocation, objectLocation) ->
		if object.isUnlock is true
			town.heroLocation = objectLocation
		else
			if town.hero.key?[object.color] > 0
				object.isUnlock = true
				--town.hero.key[object.color]
