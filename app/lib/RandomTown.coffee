class RandomTown
	constructor: (options) ->
		options ?= {}
		@floors ?= options.floors

	startWithHero: (hero) ->
		@hero = hero ? {}
		@heroFloor = 0
		curFloors = @getCurFloor()

		console.log @floors

		for row, cols of curFloors
			for col, grid of cols
				@heroLocation = [Number(row), Number(col)] if grid is RandomTown.Entry
		
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
				return [Number(row), Number(col)] if grid is searchGrid
		null

	moveHandle: (row, col) ->
		switch @getFloorGrid @getCurFloor(), row, col
			when RandomTown.Road
				@heroLocation = [row, col]
			when RandomTown.Exit
				nextFloor = @heroFloor + 1
				if nextFloor < @floors.length and @searchGridLocation(@getFloor(nextFloor), RandomTown.Entry)?
					@heroFloor = nextFloor
					@heroLocation = @searchGridLocation @getCurFloor(), RandomTown.Entry

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