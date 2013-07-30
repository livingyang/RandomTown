testAdd = (num1, num2) -> num1 + num2

@testAdd = testAdd

class MazeGenerator
	constructor: (rows, cols) ->
		@rows = if Number(rows) > 0 then Number(rows) else 0
		@cols = if Number(cols) > 0 then Number(cols) else 0

		@grids = (MazeGenerator.InitGrid for i in [0...rows * cols])
	
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

	setGrid: (value, row, col) ->
		@grids[@getGridIndex(row, col)] = value if @isValidIndex row, col

	getAroundIndexes: (row, col) ->
		gridOffsetArray = [[-1, 0], [1, 0], [0, -1], [0, 1]]
		([row + gridOffset[0], col + gridOffset[1]] for gridOffset in gridOffsetArray when @isValidIndex row + gridOffset[0], col + gridOffset[1])

MazeGenerator.InitGrid = 0
MazeGenerator.InvalidGrid = -1
MazeGenerator.BlockGrid = -2

@MazeGenerator = MazeGenerator
