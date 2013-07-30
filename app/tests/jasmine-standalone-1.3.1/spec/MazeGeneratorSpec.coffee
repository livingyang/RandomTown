describe "MazeGeneratorSpec", ->
	it "测试常量", ->
		expect(MazeGenerator.InitGrid).toBe(0)
		expect(MazeGenerator.InvalidGrid).toBe(-1)
		expect(MazeGenerator.BlockGrid).toBe(-2)

	it "测试对象初始化", ->
		generator = new MazeGenerator(2, 3)
		expect(generator.rows).toBe(2)
		expect(generator.cols).toBe(3)
		expect(generator.grids.length).toBe(2 * 3)
		for grid in generator.grids
			expect(grid).toBe(MazeGenerator.InitGrid)
	
	it "测试 Grid 索引", ->
		generator = new MazeGenerator(2, 3)
		expect(generator.isValidIndex 0, 0).toBe(true)
		expect(generator.isValidIndex 1, 2).toBe(true)
		expect(generator.isValidIndex -1, 0).toBe(false)
		expect(generator.isValidIndex 1, 3).toBe(false)
		expect(generator.isValidIndex 0, 'a').toBe(false)

		expect(generator.getGridIndex 0, 0).toBe(0)
		expect(generator.getGridIndex 1, 0).toBe(3)
		expect(generator.getGridIndex 1, 2).toBe(5)
		expect(generator.getGridIndex -1, 0).toBe(0)

		index = generator.getRowColFromGridIndex 0
		expect(index[0]).toBe(0)
		expect(index[1]).toBe(0)

		index = generator.getRowColFromGridIndex 4
		expect(index[0]).toBe(1)
		expect(index[1]).toBe(1)

		index = generator.getRowColFromGridIndex -1
		expect(index.length).toBe(0)
		
	it "测试 Grid setter, getter", ->
		generator = new MazeGenerator(2, 3)
		expect(generator.getGrid 1, 1).toBe(MazeGenerator.InitGrid)
		generator.setGrid 2, 1, 1
		expect(generator.getGrid 1, 1).toBe(2)
		expect(generator.getGrid -1, 1).toBe(MazeGenerator.InvalidGrid)
		generator.print()

		console.log generator.getAroundIndexes(1, 1)
		console.log generator.getAroundIndexes(0, 0)
