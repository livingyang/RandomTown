describe "RandomTownSpec", ->
	it "测试创建", ->
		town = new RandomTown()
		expect(town).toEqual(jasmine.any(RandomTown))
	
	it "测试常量", ->

		expect(RandomTown.Wall).toBe(-1)
		expect(RandomTown.Road).toBe(0)
		expect(RandomTown.ObjectHandle).toEqual(jasmine.any(Object))

	it "测试楼层设置", ->
		floors = []
		floors.push [
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Road, object: {type: "entry"}}, {ground: RandomTown.Road, object: {type: "exit"}}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
		]
		floors.push [
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Wall}, {ground: RandomTown.Road}, {ground: RandomTown.Road}]
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
		]
		town = new RandomTown
			floors : floors

		expect(town.floors.length).toBe(2)
		expect(town.floors[0][0][0].ground).toBe(RandomTown.Wall)
		expect(town.floors[0][1][0].ground).toBe(RandomTown.Road)
		expect(town.floors[0][1][0].object.type).toBe("entry")
		expect(town.floors[0][1][1].object.type).toBe("exit")
		expect(town.floors[0][1][2].object?).toBe(false)

	it "初始化探索英雄", ->
		floors = []
		floors.push [
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Road, object: {type: "entry"}}, {ground: RandomTown.Road, object: {type: "exit"}}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
		]
		town = new RandomTown
			floors : floors
		
		expect(town.floors[0][1][0].object.type).toBe("entry")
		expect(town.getHeroFloorIndex()?).toBe(false)
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

		expect(town.getHeroFloorIndex()).toBe(0)
		expect(town.getHeroLocation()).toEqual([1, 0])

	it "使用英雄进行探索", ->
		floors = []
		floors.push [
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Road, object: {type: "entry"}}, {ground: RandomTown.Road}, {ground: RandomTown.Road, object: {type: "exit"}}]
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
		]
		floors.push [
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Road}, {ground: RandomTown.Road, object: {type: "exit"}}, {ground: RandomTown.Road, object: {type: "entry"}}]
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

		expect(town.getHeroFloorIndex()).toBe(0)
		expect(town.getHeroLocation()).toEqual([1, 0])

		town.moveUp()
		expect(town.getHeroLocation()).toEqual([1, 0])
		town.moveDown()
		town.moveLeft()
		expect(town.getHeroLocation()).toEqual([1, 0])

		town.moveRight()
		expect(town.getHeroLocation()).toEqual([1, 1])

		town.moveRight()
		expect(town.getHeroFloorIndex()).toBe(1)
		expect(town.getHeroLocation()).toEqual([1, 2])

		town.moveLeft()
		expect(town.getHeroFloorIndex()).toBe(1)
		expect(town.getHeroLocation()).toEqual([1, 1])

		town.moveRight()
		expect(town.getHeroFloorIndex()).toBe(0)
		expect(town.getHeroLocation()).toEqual([1, 2])

	it "测试crystal对象", ->
		floors = []
		floors.push [
			[{ground: RandomTown.Entry}, {ground: RandomTown.Road}]
			[{ground: RandomTown.Road, object: {type: "crystal", attack: 2}}, {ground: RandomTown.Road}]
		]

		town = new RandomTown
			floors : floors
		
		town.startWithHero
			name: "SuperManXX"
			attack: 100
			defense: 80
			health: 1000
			money: 200

		expect(town.getFloorGrid(town.getCurFloor(), 1, 0).object.type).toBe("crystal")
		expect(town.getFloorGrid(town.getCurFloor(), 1, 0).object.attack).toBe(2)
		expect(town.hero.attack).toBe(100)
		town.moveDown()
		# expect(town.hero.attack).toBe(102)