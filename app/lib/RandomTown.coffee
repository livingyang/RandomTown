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

	getCurFloor: ->
		@floors[@heroFloor]

	getFloorGrid: (floor, row, col) ->
		floor[row][col]

	moveHandle: (row, col) ->
		switch @getFloorGrid @getCurFloor(), row, col
			when RandomTown.Road
				@heroLocation = [row, col]
			when RandomTown.Exit
				if @heroFloor + 1 < @floors.length
					@heroFloor += 1

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