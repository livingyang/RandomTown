###
floors = [], object = floor, indexName = floorIndex
floor = [], object = grid, indexName = [row, col]
grid = {ground: xxx, object: xxx}
###

class RandomTown
	constructor: (options) ->
		options ?= {}
		@floors ?= options.floors

	startWithHero: (hero) ->
		@hero = hero ? {}
		@heroFloorIndex = 0

		@heroLocation = @getEntryLocation @getCurFloor()
		if not @heroLocation then console.log "RandomTown.startWithHero cannot find entry"
		
	getHeroFloorIndex: ->
		@heroFloorIndex

	getHeroLocation: ->
		@heroLocation

	getFloor: (floorIndex) ->
		@floors[floorIndex]

	getCurFloor: ->
		@getFloor(@heroFloorIndex)

	getFloorGrid: (floor, row, col) ->
		floor[row][col]

	searchObjectByType: (floor, objectType) ->
		floor ?= []
		result = []
		for row, cols of floor
			for col, grid of cols
				result.push([Number(row), Number(col)]) if grid?.object?.type is objectType
		result

	moveHandle: (row, col) ->
		return if not (0 <= row < @getCurFloor().length) or not (0 <= col < @getCurFloor()[0].length)
		
		grid = @getFloorGrid @getCurFloor(), row, col

		if grid.object?.type? and RandomTown.ObjectHandle[grid.object.type]?
			RandomTown.ObjectHandle[grid.object.type].onEnter @, @hero, row, col
		else
			@heroLocation = [row, col] if grid.ground is RandomTown.Road			
		return
		switch @getFloorGrid(@getCurFloor(), row, col).ground
			when RandomTown.Road
				@heroLocation = [row, col]
			when RandomTown.Exit
				nextFloor = @heroFloorIndex + 1
				if nextFloor < @floors.length and @searchGridLocation(@getFloor(nextFloor), RandomTown.Entry)?
					@heroFloorIndex = nextFloor
					@heroLocation = @searchGridLocation @getCurFloor(), RandomTown.Entry
				else
					@heroLocation = [row, col]
			when RandomTown.Entry
				prevFloor = @heroFloorIndex - 1
				if prevFloor >= 0 and @searchGridLocation(@getFloor(prevFloor), RandomTown.Exit)?
					@heroFloorIndex = prevFloor
					@heroLocation = @searchGridLocation @getCurFloor(), RandomTown.Exit
				else
					@heroLocation = [row, col]

	moveUp: ->
		@moveHandle @getHeroLocation()[0] - 1, @getHeroLocation()[1]

	moveDown: ->
		@moveHandle @getHeroLocation()[0] + 1, @getHeroLocation()[1]

	moveLeft: ->
		@moveHandle @getHeroLocation()[0], @getHeroLocation()[1] - 1

	moveRight: ->
		@moveHandle @getHeroLocation()[0], @getHeroLocation()[1] + 1

RandomTown.Wall = -1
RandomTown.Road = 0
RandomTown.ObjectHandle = {}

@RandomTown = RandomTown

###
	RandomTown object handles
###

EntryHandle =
	onEnter: (town, hero, location) ->
		prevFloor = town.heroFloorIndex - 1
		if prevFloor >= 0 and @searchGridLocation(@getFloor(prevFloor), RandomTown.Exit)?
			@heroFloorIndex = prevFloor
			@heroLocation = @searchGridLocation @getCurFloor(), RandomTown.Exit
		else
			@heroLocation = [row, col]
