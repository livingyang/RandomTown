describe "RandomTownSpec", ->
	it "测试创建", ->
		town = new RandomTown()
		expect(town).toEqual(jasmine.any(RandomTown))
	
	it "测试常量", ->

		expect(RandomTown.Wall).toBe(-1)
		expect(RandomTown.Entry).toBe(1)
		expect(RandomTown.Exit).toBe(2)

	it "测试楼层设置", ->
		floors = []
		floors.push [
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Wall}, {ground: RandomTown.Entry}, {ground: RandomTown.Exit}]
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
		]
		floors.push [
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Entry}, {ground: RandomTown.Exit}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
		]
		town = new RandomTown
			floors : floors

		expect(town.floors.length).toBe(2)
		expect(town.floors[0][0][0].ground).toBe(RandomTown.Wall)
		expect(town.floors[0][1][1].ground).toBe(RandomTown.Entry)
		expect(town.floors[0][1][2].ground).toBe(RandomTown.Exit)

	it "初始化探索英雄", ->
		floors = []
		floors.push [
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Entry}, {ground: RandomTown.Road}, {ground: RandomTown.Exit}]
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
		]
		town = new RandomTown
			floors : floors
		
		expect(town.floors[0][1][0].ground).toBe(RandomTown.Entry)
		expect(town.getHeroFloor()?).toBe(false)
		expect(town.getHeroLocation()?).toBe(false)
		
		town.startWithHero
			name: "SuperManXX"
			attack: 100
			defense: 80
			health: 1000
			money: 200
		
		expect(town.hero.name).toBe("SuperManXX")
		expect(town.hero.attack).toBe(100)
		expect(town.hero.money).toBe(200)

		expect(town.getHeroFloor()).toBe(0)
		expect(town.getHeroLocation()).toEqual([1, 0])

	it "使用英雄进行探索", ->
		floors = []
		floors.push [
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Entry}, {ground: RandomTown.Road}, {ground: RandomTown.Exit}]
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
		]
		floors.push [
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Wall}, {ground: RandomTown.Exit}, {ground: RandomTown.Entry}]
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
		]
		town = new RandomTown
			floors : floors
		
		town.startWithHero
			name: "SuperManXX"
			attack: 100
			defense: 80
			health: 1000
			money: 200

		expect(town.getHeroFloor()).toBe(0)
		expect(town.getHeroLocation()).toEqual([1, 0])

		town.moveUp()
		expect(town.getHeroLocation()).toEqual([1, 0])
		town.moveDown()
		town.moveLeft()
		expect(town.getHeroLocation()).toEqual([1, 0])

		town.moveRight()
		expect(town.getHeroLocation()).toEqual([1, 1])

		town.moveRight()
		expect(town.getHeroFloor()).toBe(1)
		expect(town.getHeroLocation()).toEqual([1, 2])

		town.moveLeft()
		expect(town.getHeroFloor()).toBe(1)
		expect(town.getHeroLocation()).toEqual([1, 1])

		town.moveRight()
		expect(town.getHeroFloor()).toBe(0)
		expect(town.getHeroLocation()).toEqual([1, 2])
