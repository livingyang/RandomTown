testAdd = (num1, num2) -> num1 + num2

@testAdd = testAdd

class MazeGenerator
	constructor: (rows, cols, grids) ->
		@rows = if Number(rows) > 0 then Number(rows) else 0
		@cols = if Number(cols) > 0 then Number(cols) else 0


		@grids = if grids instanceof Array and grids.length is rows * cols
		then (i for i in grids)
		else (MazeGenerator.InitGrid for i in [0...rows * cols])
	
	print: ->
		result = ""
		for row in [0...@rows]
			for col in [0...@cols]
				result += "#{@getGrid row, col}\t"

			result += "\n"

		console.log result;

	isValidIndex: (row, col) ->
		(0 <= row < @rows) and (0 <= col < @cols)
	
	getGridIndex: (row, col) ->
		if @isValidIndex(row, col) then row * @cols + col else 0

	getRowColFromGridIndex: (gridIndex) ->
		if (0 <= gridIndex < @grids.length) and @grids.length > 0 then [Math.floor(gridIndex / @cols), gridIndex % @cols] else []

	getGrid: (row, col) ->
		if @isValidIndex(row, col) then @grids[@getGridIndex(row, col)] else MazeGenerator.InvalidGrid

	setGrid: (row, col, value) ->
		@grids[@getGridIndex(row, col)] = value if @isValidIndex row, col

	getAroundIndexes: (row, col) ->
		if @isValidIndex row, col
		then ([row + gridOffset[0], col + gridOffset[1]] for gridOffset in [[-1, 0], [1, 0], [0, -1], [0, 1]] when @isValidIndex row + gridOffset[0], col + gridOffset[1])
		else []

	markConnectGrid: (row, col, value) ->
		if @getGrid(row, col) is MazeGenerator.InitGrid

			growIndexes = [[row, col]]
			while growIndexes.length > 0
				newGrowIndexes = []
				for index in growIndexes
					@setGrid index[0], index[1], value
					(newGrowIndexes.push aroundIndex for aroundIndex in @getAroundIndexes(index[0], index[1]) when @getGrid(aroundIndex[0], aroundIndex[1]) is MazeGenerator.InitGrid)
				growIndexes = newGrowIndexes
		
		# console.log "mark done!"

	getConnectGridArray: () ->
		for grid in @grids
			if grid isnt MazeGenerator.InitGrid and grid isnt MazeGenerator.BlockGrid
				console.log "getConnectGridArray grid info invalid"
				return []

		startMarkValue = MazeGenerator.MinMarkValue
		for grid, index in @grids
			if grid is MazeGenerator.InitGrid
				gridRowColIndex = @getRowColFromGridIndex index
				@markConnectGrid gridRowColIndex[0], gridRowColIndex[1], startMarkValue
				startMarkValue++ 
		
		
		(([@getRowColFromGridIndex(index)[0], @getRowColFromGridIndex(index)[1]] for grid, index in @grids when grid is markValue) for markValue in [MazeGenerator.MinMarkValue...startMarkValue])

	createBlocks: (blockPercent) ->
		@grids[i] = MazeGenerator.BlockGrid for i in [0...@grids.length] when @grids[i] is MazeGenerator.InitGrid and (0 < Math.random() < blockPercent)
		
		

MazeGenerator.InitGrid = 0
MazeGenerator.MinMarkValue = 1
MazeGenerator.InvalidGrid = -1
MazeGenerator.BlockGrid = -2

@MazeGenerator = MazeGenerator
