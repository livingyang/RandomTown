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
		@heroFloor = 0

		for row, cols of @getCurFloor()
			for col, grid of cols
				@heroLocation = [Number(row), Number(col)] if grid.ground is RandomTown.Entry
		
	getHeroFloor: ->
		@heroFloor

	getHeroLocation: ->
		@heroLocation

	getFloor: (floor) ->
		@floors[floor]

	getCurFloor: ->
		@getFloor(@heroFloor)

	getFloorGrid: (floor, row, col) ->
		floor[row][col]

	searchGridLocation: (floor, searchGrid) ->
		floor ?= []
		for row, cols of floor
			for col, grid of cols
				return [Number(row), Number(col)] if grid.ground is searchGrid
		null

	moveHandle: (row, col) ->
		switch @getFloorGrid(@getCurFloor(), row, col).ground
			when RandomTown.Road
				@heroLocation = [row, col]
			when RandomTown.Exit
				nextFloor = @heroFloor + 1
				if nextFloor < @floors.length and @searchGridLocation(@getFloor(nextFloor), RandomTown.Entry)?
					@heroFloor = nextFloor
					@heroLocation = @searchGridLocation @getCurFloor(), RandomTown.Entry
				else
					@heroLocation = [row, col]
			when RandomTown.Entry
				prevFloor = @heroFloor - 1
				if prevFloor >= 0 and @searchGridLocation(@getFloor(prevFloor), RandomTown.Exit)?
					@heroFloor = prevFloor
					@heroLocation = @searchGridLocation @getCurFloor(), RandomTown.Exit
				else
					@heroLocation = [row, col]

	moveUp: ->
		if @getHeroLocation()[0] > 0
			@moveHandle @getHeroLocation()[0] - 1, @getHeroLocation()[1]

	moveDown: ->
		if @getHeroLocation()[0] < @getCurFloor.length - 1
			@moveHandle @getHeroLocation()[0] + 1, @getHeroLocation()[1]

	moveLeft: ->
		if @getHeroLocation()[1] > 0
			@moveHandle @getHeroLocation()[0], @getHeroLocation()[1] - 1

	moveRight: ->
		if @getHeroLocation()[1] < @getCurFloor()[0].length - 1
			@moveHandle @getHeroLocation()[0], @getHeroLocation()[1] + 1

RandomTown.Wall = -1
RandomTown.Road = 0
RandomTown.Entry = 1
RandomTown.Exit = 2

@RandomTown = RandomTown