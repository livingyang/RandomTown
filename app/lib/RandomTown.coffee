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
		for floor in @floors
			for cols in floor
				for grid in cols
					if grid.ground is RandomTown.Road and grid.object?.type? and RandomTown.ObjectHandle[grid.object.type]?.getSimpleData?
					then RandomTown.ObjectHandle[grid.object.type].getSimpleData grid.object, String(grid.ground)
					else String(grid.ground)

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

	isExistObject: (row, col, floorIndex) ->
		floorIndex ?= @heroFloorIndex
		grid = @getFloorGrid (@getFloor floorIndex), row, col
		grid?.object?.type? and RandomTown.ObjectHandle[grid.object.type].isVisible grid.object, grid.ground

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

rowsOfFloor = (floor) ->
	if floor instanceof Array then floor.length else 0

colsOfFloor = (floor) ->
	if floor.length > 0 then floor[0].length else 0

isValidFloorLocation = (rows, cols, location) ->
	(0 <= location[0] < rows and 0 <= location[1] < cols)

###
arroundLocation index:

    0
3  loc  2
    1
###
getArroundLocation = (rows, cols, location) ->
	if isValidFloorLocation rows, cols, location
	then ([location[0] + offset[0], location[1] + offset[1]] for offset in [[-1, 0], [1, 0], [0, -1], [0, 1]])
	else null

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

GeneratePath = (rows, cols, startLocation, maxStep) ->
	if isValidFloorLocation rows, cols, startLocation
		maxStep ?= rows * cols
		martix = ((RandomTown.Road for col in [0...cols]) for row in [0...rows])
		nextStepSet = [startLocation]
		while maxStep-- > 0 and nextStepSet.length > 0			
			nextStep = nextStepSet[Math.floor Math.random() * nextStepSet.length]
			martix[step[0]][step[1]] = RandomTown.Wall for step in nextStepSet
			nextStepSet = (arroundLocation for arroundLocation in getArroundLocation rows, cols, nextStep when (isValidFloorLocation rows, cols, arroundLocation) and martix[arroundLocation[0]][arroundLocation[1]] is RandomTown.Road)
			nextStep
	else
		[startLocation]

GenerateFloor = (rows, cols, wallPercent) ->
	for row in [0...rows]
		for col in [0...cols]
			if Math.random() < if typeof wallPercent is "function" then wallPercent(row, col) else wallPercent
			then {ground: RandomTown.Wall}
			else {ground: RandomTown.Road}

GenerateFloorObject = (floor, path, objectsPercent) ->

	distanceOfGrid = (grid1, grid2) ->
		if grid1? and grid2?
		then (Math.abs grid1[0] - grid2[0]) + (Math.abs grid1[1] - grid2[1])
		else undefined

	for step in path
		floor[step[0]][step[1]].ground = RandomTown.Road

	for row, cols of floor
		for col, grid of cols
			countObjectsPercent = {}
			for type, percent of objectsPercent
				location = [Number(row), Number(col)]
				countObjectsPercent[type] = RandomTown.ObjectHandle[type]?.getPercent? percent, floor, location, (distanceOfGrid path[0], location), (distanceOfGrid path[path.length - 1], location)
			grid.object = {type: getPercentObject countObjectsPercent} if isHitPercentObject countObjectsPercent
	floor

GenerateFloors = (floorCount, rows, cols, initLocation, wallPercent) ->
	
	wallPercent ?= 1
	startLocation = initLocation

	floors = for floorIndex in [0...floorCount]
		path = GeneratePath rows, cols, startLocation

		floor = GenerateFloorObject (GenerateFloor rows, cols, wallPercent), path,
					"key": 0.1
					"door": 0.1
					"plus": 0.1
					"enemy": 0.1

		for colGrids in floor
			for grid in colGrids
				switch grid.object?.type
					when "key"
						grid.object.color = "yellow"
					when "door"
						grid.object.color = "yellow"
					when "plus"
						if Math.random() < 0.5
						then grid.object.attack = 2
						else grid.object.defense = 2
					when "enemy"
						grid.object.health = 100
						grid.object.attack = 50
						grid.object.defense = 30
						grid.object.exp = 10
						grid.object.money = 10

		floor[startLocation[0]][startLocation[1]].object = 
			type: "hole"
			floorIndex: floorIndex - 1
			location: startLocation
		startLocation = path[path.length - 1]
		floor[startLocation[0]][startLocation[1]].object = 
			type: "hole"
			floorIndex: floorIndex + 1
			location: startLocation

		floor
	floors

@rowsOfFloor = rowsOfFloor
@colsOfFloor = colsOfFloor
@getArroundLocation = getArroundLocation
@isValidFloorLocation = isValidFloorLocation

@GeneratePath = GeneratePath
@GenerateFloor = GenerateFloor
@GenerateFloorObject = GenerateFloorObject
@GenerateFloors = GenerateFloors

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

			damage = attacker.attack - defenser.defense
			defenser.health -= damage if damage > 0
			break if defenser.health <= 0

@HeroFight = HeroFight

###
	RandomTown object handles
###

RandomTown.ObjectHandle["hole"] =
	onEnter: (town, object, enterLocation, objectLocation) ->
		if object.floorIndex is -1
			console.log "Town Start Point enter"
		else if object.floorIndex is town.floors.length
			console.log "Town End Point enter"
		else
			town.heroFloorIndex = object.floorIndex
		
		town.heroLocation = object.location

	getSimpleData: (object, ground) ->
		object.type

	getPercent: (percent, floor, location, startDistance, endDistance) ->
		0

	isVisible: (object, ground) ->
		true

RandomTown.ObjectHandle["plus"] =
	onEnter: (town, object, enterLocation, objectLocation) ->
		if object.isUsed is true
			town.heroLocation = objectLocation
		else
			object.isUsed = true
			town.changeHeroProperty object
			
	getSimpleData: (object, ground) ->
		if object.isUsed is true then ground else object.type

	getPercent: (percent, floor, location, startDistance, endDistance) ->
		percent

	isVisible: (object, ground) ->
		not object.isUsed and ground is RandomTown.Road

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

	getPercent: (percent, floor, location, startDistance, endDistance) ->
		percent

	isVisible: (object, ground) ->
		not object.isPickup and ground is RandomTown.Road

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

	getPercent: (percent, floor, location, startDistance, endDistance) ->
		flags = ((isValidFloorLocation floor.length, floor[0].length, arroundLocation) and floor[arroundLocation[0]][arroundLocation[1]].ground is RandomTown.Road for arroundLocation in getArroundLocation floor.length, floor[0].length, location)
		if flags[0] is flags[1] and flags[2] is flags[3] and flags[0] isnt flags[2]
		then percent
		else 0

	isVisible: (object, ground) ->
		not object.isUnlock and ground is RandomTown.Road

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
			town.hero.exp += object.exp if object.exp?
			town.hero.money += object.money if object.money?

	getSimpleData: (object, ground) ->
		if object.health <= 0 then ground else object.type

	getPercent: (percent, floor, location, startDistance, endDistance) ->
		if startDistance > 1 and endDistance > 1 then percent else 0

	isVisible: (object, ground) ->
		object.health > 0 and ground is RandomTown.Road
