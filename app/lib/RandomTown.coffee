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
		floor[row][col] if @isValidRowAndCol row, col

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

	changeHeroProperty: (properties) ->
		@hero[propertyName] += value for propertyName, value of properties when typeof @hero[propertyName] is "number" and typeof value is "number"

	isValidRowAndCol: (row, col) ->
		0 <= row < @floors[0].length and 0 <= col < @floors[0][0].length

	getEnemyDamage: (row, col) ->
		if @isValidRowAndCol row, col
			grid = @getFloorGrid @getCurFloor(), row, col
			if grid.object?.type is "enemy"
				heroFight = new HeroFight
					attacker: @hero
					defenser: grid.object

				return @hero.health - heroFight.attacker.health
		0

	moveHandle: (row, col) ->
		if @isValidRowAndCol row, col
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
function GenerateFloor
###

isHitPercentObject = (percentObjects) ->
	notHitPercent = 1
	for object, percent of percentObjects when 0 <= percent <= 1
		notHitPercent *= (1 - percent)
	Math.random() >= notHitPercent

getPercentObject = (percentObjects) ->
	totalPercent = 0
	totalPercent += percent for object, percent of percentObjects when 0 <= percent <= 1
	
	targetPercent = Math.random() * totalPercent
	for object, percent of percentObjects when 0 <= percent <= 1
		targetPercent -= percent
		if targetPercent <= 0
			return object
	return null

GeneratePath = (options) ->
	
	if 0 <= options.startLocation[0] < options.rows and
	0 <= options.startLocation[1] < options.cols and
	options.rows * options.cols > 1
		options.maxStep ?= options.rows * options.cols
		martix = ((0 for col in [0...options.cols]) for row in [0...options.rows])
		path = []
		nextStepSet = [options.startLocation]
		while path.length < options.maxStep and nextStepSet.length > 0			
			nextStep = nextStepSet[Math.floor Math.random() * nextStepSet.length]
			martix[step[0]][step[1]] = -1 for step in nextStepSet
			path.push nextStep
			nextStepSet = []
			for stepOffset in [[1, 0], [0, 1], [-1, 0], [0, -1]]
				step = [nextStep[0] + stepOffset[0], nextStep[1] + stepOffset[1]]
				if 0 <= step[0] < options.rows and
				0 <= step[1] < options.cols and
				martix[step[0]][step[1]] is 0
					nextStepSet.push step
		path
	else
		[options.startLocation]

GenerateFloor = (options) ->
	options ?= {}
	rows = options.rows ? 2
	cols = options.cols ? 2
	road = options.road ? 0
	wall = options.wall ? -1
	wallPercent = options.wallPercent ? 0

	(((if Math.random() < wallPercent then {ground: wall} else {ground: road}) for col in [0...cols]) for row in [0...rows])

GenerateFloorObject = (options) ->
	floor = options.floor ? []
	path = options.path ? []
	road = options.road ? 0
	objects = options.objects ? {}

	for step in path
		floor[step[0]][step[1]].ground = road

	for cols in floor
		for grid in cols
			if grid.ground is road and isHitPercentObject objects
				grid.object = {type: getPercentObject objects}
	floor
	

@GeneratePath = GeneratePath
@GenerateFloor = GenerateFloor
@GenerateFloorObject = GenerateFloorObject

###
class HeroFight
###

class HeroFight
	constructor: (options) ->
		options ?= {}

		@attacker = JSON.parse(JSON.stringify(options.attacker ? {}))
		@defenser = JSON.parse(JSON.stringify(options.defenser ? {}))
		@maxTurnCount = options.maxTurnCount ? 100

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
			town.changeHeroProperty object
			
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
