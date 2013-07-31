
describe "MazeGeneratorSpec", ->
	it "测试常量", ->
		expect(MazeGenerator.InitGrid).toBe(0)
		expect(MazeGenerator.MinMarkValue).toBe(1)
		expect(MazeGenerator.InvalidGrid).toBe(-1)
		expect(MazeGenerator.BlockGrid).toBe(-2)

	it "测试对象初始化", ->
		generator = new MazeGenerator(2, 3)
		expect(generator.rows).toBe(2)
		expect(generator.cols).toBe(3)
		expect(generator.grids.length).toBe(2 * 3)
		for grid in generator.grids
			expect(grid).toBe(MazeGenerator.InitGrid)

		generator = new MazeGenerator(2, 3, [1, 0, 0, 0, 0, 2])
		expect(generator.grids[0]).toBe(1)
		expect(generator.grids[1]).toBe(0)
		expect(generator.grids[5]).toBe(2)
		
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

	it "获取周边格子索引", ->
		generator = new MazeGenerator(3, 4, [0, 0, 0, 0,
											 0, 0, 0, 0,
											 0, 0, 0, 0])

		expect(generator.getAroundIndexes(1, 1).length).toBe(4)
		expect(generator.getAroundIndexes(0, 4).length).toBe(0)

	it "标记联通格子", ->
		generator = new MazeGenerator(2, 3, [0, 1, 0,
											 1, 0, 0])
		generator.markConnectGrid 0, 0, 3
		expect(generator.grids).toEqual([3, 1, 0,
										 1, 0, 0])

		generator.markConnectGrid 1, 1, 6
		expect(generator.grids).toEqual([3, 1, 6,
										 1, 6, 6])

	it "获取联通格子数组", ->
		generator = new MazeGenerator(2, 3, [0, -2, 0,
											 -2, 0, 0])

		connectGridArray = generator.getConnectGridArray()

		expect(generator.grids).toEqual([1, -2, 2,
										 -2, 2, 2])

		expect(connectGridArray.length).toBe(2)
		expect(connectGridArray[0].length).toBe(1)
		expect(connectGridArray[1].length).toBe(3)
	
	it "稍微复杂点的获取联通格子数组", ->
		generator = new MazeGenerator(3, 4, [0, -2, 0, 0,
											 -2, 0, 0, 0,
											 0, -2, 0, 0])

		connectGridArray = generator.getConnectGridArray()

		expect(generator.grids).toEqual([1, -2, 2, 2,
										 -2, 2, 2, 2,
										 3, -2, 2, 2])

		expect(connectGridArray.length).toBe(3)
		expect(connectGridArray[0].length).toBe(1)
		expect(connectGridArray[1].length).toBe(7)
		expect(connectGridArray[2].length).toBe(1)
