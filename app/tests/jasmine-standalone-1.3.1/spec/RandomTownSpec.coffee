describe "RandomTownSpec", ->
	hero = {}
	beforeEach ->
		hero = 
			name: "SuperManXX"
			attack: 100
			defense: 80
			health: 1000
			exp: 0
			money: 200

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
			floors: floors
			hero: hero
			heroFloorIndex: 0
			heroLocation: [1, 0]
		
		expect(town.floors[0][1][0].object.type).toBe("entry")
		
		expect(town.hero.name).toBe("SuperManXX")
		expect(town.hero.attack).toBe(100)
		expect(town.hero.defense).toBe(80)
		expect(town.hero.money).toBe(200)

		expect(town.heroFloorIndex).toBe(0)
		expect(town.heroLocation).toEqual([1, 0])

	it "使用英雄进行探索", ->
		floors = []
		floors.push [
			[{ground: -1}, {ground: -1}, {ground: -1}]
			[{ground: 0}, {ground: 0}, {ground: 0}]
			[{ground: -1}, {ground: -1}, {ground: -1}]
		]
		floors.push [
			[{ground: -1}, {ground: -1}, {ground: -1}]
			[{ground: 0}, {ground: 0}, {ground: 0}]
			[{ground: -1}, {ground: -1}, {ground: -1}]
		]

		floors[0][1][2].object = 
			type: "hole"
			floorIndex: 1
			location: [1, 2]

		floors[1][1][2].object = 
			type: "hole"
			floorIndex: 0
			location: [1, 1]

		town = new RandomTown
			floors: floors
			hero: hero
			heroFloorIndex: 0
			heroLocation: [1, 0]

		expect(town.heroFloorIndex).toBe(0)
		expect(town.heroLocation).toEqual([1, 0])

		town.moveUp()
		expect(town.heroLocation).toEqual([1, 0])
		town.moveDown()
		town.moveLeft()
		expect(town.heroLocation).toEqual([1, 0])

		town.moveRight()
		expect(town.heroFloorIndex).toBe(0)
		expect(town.heroLocation).toEqual([1, 1])

		town.moveRight()
		expect(town.heroFloorIndex).toBe(1)
		expect(town.heroLocation).toEqual([1, 2])

		town.moveLeft()
		expect(town.heroFloorIndex).toBe(1)
		expect(town.heroLocation).toEqual([1, 1])

		town.moveRight()
		expect(town.heroFloorIndex).toBe(0)
		expect(town.heroLocation).toEqual([1, 1])

	it "测试改变hero属性", ->
		town = new RandomTown
			floors: [[0]]
			hero: hero
			heroFloorIndex: 0
			heroLocation: [0, 0]

		expect(town.hero.attack).toBe 100
		expect(town.hero.money).toBe 200
		town.changeHeroProperty
			money: -10
			attack: +5
		expect(town.hero.attack).toBe 105
		expect(town.hero.money).toBe 190

	it "测试plus对象", ->
		floors = []
		floors.push [
			[{ground: -1}, {ground: 0}]
			[{ground: -1}, {ground: 0}]
		]
		floors[0][1][1].object =
			type: "plus"
			attack: 2
			exp: 10
			errorProperty: 10

		town = new RandomTown
			floors: floors
			hero: hero
			heroFloorIndex: 0
			heroLocation: [0, 1]

		expect(town.hero.attack).toBe(100)
		expect(town.hero.exp).toBe(0)
		town.moveDown()
		expect(town.heroLocation).toEqual([0, 1])
		expect(town.hero.attack).toBe(102)
		expect(town.hero.exp).toBe(10)
		expect(town.hero.errorProperty?).toBe(false)

		town.moveDown()
		expect(town.heroLocation).toEqual([1, 1])
		expect(town.hero.attack).toBe(102)
		expect(town.hero.exp).toBe(10)
		expect(town.hero.errorProperty?).toBe(false)
	
	it "测试钥匙与门对象", ->
		floors = []
		floors.push [
			[{ground: 0}, {ground: 0}]
			[{ground: 0}, {ground: 0}]
		]
		floors[0][0][1].object =
			type: "key"
			color: "yellow"
		floors[0][1][0].object =
			type: "door"
			color: "yellow"

		town = new RandomTown
			floors: floors
			hero: hero
			heroFloorIndex: 0
			heroLocation: [0, 0]

		expect(town.heroLocation).toEqual([0, 0])
		town.moveDown()
		expect(town.heroLocation).toEqual([0, 0])

		town.moveRight()
		expect(town.heroLocation).toEqual([0, 0])
		town.moveRight()
		expect(town.heroLocation).toEqual([0, 1])

		town.moveLeft()
		expect(town.heroLocation).toEqual([0, 0])
		town.moveDown()
		expect(town.heroLocation).toEqual([0, 0])
		town.moveDown()
		expect(town.heroLocation).toEqual([1, 0])

	it "生成简易地图数据", ->
		floors = []
		floors.push [
			[{ground: 0}, {ground: 0}]
			[{ground: 0}, {ground: 0}]
		]

		town = new RandomTown
			floors: floors
			hero: hero
			heroFloorIndex: 0
			heroLocation: [0, 0]

		expect(town.getSimpleFloors()).toEqual [
			[
				["0", "0"]
				["0", "0"]
			]
		]

		floors[0][0][1].object =
			type: "key"
			color: "yellow"
		floors[0][1][0].object =
			type: "door"
			color: "yellow"
		floors[0][1][1].object =
			type: "plus"
			attack: 2

		expect(town.getSimpleFloors()).toEqual [
			[
				["0", "key"]
				["door", "plus"]
			]
		]
		town.moveRight()
		expect(town.getSimpleFloors()).toEqual [
			[
				["0", "0"]
				["door", "plus"]
			]
		]
		town.moveDown()
		expect(town.getSimpleFloors()).toEqual [
			[
				["0", "0"]
				["0", "plus"]
			]
		]
		town.moveDown()
		town.moveRight()
		expect(town.getSimpleFloors()).toEqual [
			[
				["0", "0"]
				["0", "0"]
			]
		]
		
	it "生成攻击数据", ->
		attacker =
			attack: 100
			defense: 80
			health: 120

		defenser =
			attack: 100
			defense: 70
			health: 40

		heroFight = new HeroFight
			attacker: attacker
			defenser: defenser
			maxTurnCount: 100

		expect(heroFight.maxTurnCount).toBe(100)
		expect(heroFight.attacker.attack).toBe(100)
		expect(heroFight.attacker.defense).toBe(80)
		expect(heroFight.defenser.attack).toBe(100)
		expect(heroFight.defenser.defense).toBe(70)

		expect(heroFight.attacker.health).toBe(100)
		expect(heroFight.defenser.health).toBe(-20)

		expect(attacker.health).toBe(120)
		expect(defenser.health).toBe(40)

	it "测试敌人", ->
		floors = []
		floors.push [
			[{ground: 0}, {ground: 0}]
			[{ground: 0}, {ground: 0}]
		]
		floors[0][0][1].object =
			type: "enemy"
			attack: 100
			defense: 10
			health: 10
			exp: 10
			money: 10

		town = new RandomTown
			floors: floors
			hero: hero
			heroFloorIndex: 0
			heroLocation: [0, 0]

		expect(town.hero.exp).toBe 0
		expect(town.hero.money).toBe 200
		town.moveRight()
		expect(town.hero.exp).toBe 10
		expect(town.hero.money).toBe 210
		expect(town.heroLocation).toEqual([0, 0])
		town.moveRight()
		expect(town.heroLocation).toEqual([0, 1])
