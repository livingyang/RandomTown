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
		(expect town).toEqual(jasmine.any(RandomTown))
	
	it "测试克隆", ->
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

		(expect town).toEqual new RandomTown JSON.parse JSON.stringify town

	it "测试常量", ->

		(expect RandomTown.Wall).toBe(-1)
		(expect RandomTown.Road).toBe(0)
		(expect RandomTown.ObjectHandle).toEqual(jasmine.any(Object))

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

		(expect town.isValidRowAndCol 1, 1).toBe true
		(expect town.isValidRowAndCol 0, 2).toBe true
		(expect town.isValidRowAndCol 0, "1").toBe true
		(expect town.isValidRowAndCol 0, 3).toBe false
		(expect town.isValidRowAndCol 0).toBe false

		(expect town.floors.length).toBe(2)
		(expect town.floors[0][0][0].ground).toBe(RandomTown.Wall)
		(expect town.floors[0][1][0].ground).toBe(RandomTown.Road)
		(expect town.floors[0][1][0].object.type).toBe("entry")
		(expect town.floors[0][1][1].object.type).toBe("exit")
		(expect town.floors[0][1][2].object?).toBe(false)

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
		
		(expect town.floors[0][1][0].object.type).toBe("entry")
		
		(expect town.hero.name).toBe("SuperManXX")
		(expect town.hero.attack).toBe(100)
		(expect town.hero.defense).toBe(80)
		(expect town.hero.money).toBe(200)

		(expect town.heroFloorIndex).toBe(0)
		(expect town.heroLocation).toEqual([1, 0])

	it "使用英雄进行探索", ->
		floors = []
		floors.push [
			[{ground: -1}, {ground: -1}, {ground: -1}]
			[{ground: 0}, {ground: 0, object: {type: "hole", floorIndex: -1, location: [1, 1]}}, {ground: 0, object: {type: "hole", floorIndex: 1, location: [1, 2]}}]
			[{ground: -1}, {ground: -1}, {ground: -1}]
		]
		floors.push [
			[{ground: -1}, {ground: -1}, {ground: -1}]
			[{ground: 0}, {ground: 0, object: {type: "hole", floorIndex: 2, location: [1, 1]}}, {ground: 0, object: {type: "hole", floorIndex: 0, location: [1, 1]}}]
			[{ground: -1}, {ground: -1}, {ground: -1}]
		]

		town = new RandomTown
			floors: floors
			hero: hero
			heroFloorIndex: 0
			heroLocation: [1, 0]

		spyOn town, "onHeroMove"
		spyOn town, "onFloorChanged"
		spyOn town, "onEnterBeginHole"
		spyOn town, "onEnterEndHole"

		(expect town.heroFloorIndex).toBe 0
		(expect town.heroLocation).toEqual [1, 0]

		town.moveUp()
		(expect town.heroLocation).toEqual [1, 0]
		town.moveDown()
		town.moveLeft()
		(expect town.heroLocation).toEqual [1, 0]
		(expect town.onEnterBeginHole.calls.length).toBe 0
		
		town.moveRight()
		(expect town.heroFloorIndex).toBe 0
		(expect town.heroLocation).toEqual [1, 1]
		(expect town.onEnterBeginHole.calls.length).toBe 1

		town.moveRight()

		(expect town.onHeroMove.mostRecentCall.args).toEqual [[1, 1], [1, 2], "right"]
		(expect town.onFloorChanged.mostRecentCall.args).toEqual [0, 1]
		(expect town.onFloorChanged.calls.length).toBe 1
		(expect town.heroFloorIndex).toBe 1
		(expect town.heroLocation).toEqual [1, 2]
		(expect town.onEnterEndHole.calls.length).toBe 0
		
		town.moveLeft()
		(expect town.heroFloorIndex).toBe 1
		(expect town.heroLocation).toEqual [1, 1]
		(expect town.onEnterEndHole.calls.length).toBe 1

		town.moveRight()
		(expect town.onFloorChanged.mostRecentCall.args).toEqual [1, 0]
		(expect town.onFloorChanged.calls.length).toBe 2
		(expect town.heroFloorIndex).toBe 0
		(expect town.heroLocation).toEqual [1, 1]

	it "测试改变hero属性", ->
		town = new RandomTown
			floors: [[0]]
			hero: hero
			heroFloorIndex: 0
			heroLocation: [0, 0]

		(expect town.hero.attack).toBe 100
		(expect town.hero.money).toBe 200
		town.changeHeroProperty
			money: -10
			attack: +5
		(expect town.hero.attack).toBe 105
		(expect town.hero.money).toBe 190

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
		
		spyOn town, "onHeroMove"
		spyOn town, "onUsePlus"
		spyOn town, "onHeroChanged"

		(expect town.isExistObject 0, 0).toBe(false)
		
		(expect town.hero.attack).toBe(100)
		(expect town.hero.exp).toBe(0)
		(expect floors[0][1][1].object.isUsed).not.toBe(true)
		(expect town.isExistObject 1, 1).toBe(true)
		
		town.moveDown()

		(expect town.onHeroMove.mostRecentCall.args).toEqual [[0, 1], [0, 1], "down"]
		(expect town.onUsePlus.mostRecentCall.args).toEqual [[1, 1]]
		(expect town.onHeroChanged.calls.length).toBe 1
		(expect floors[0][1][1].object.isUsed).toBe(true)
		(expect town.isExistObject 1, 1).toBe(false)
		(expect town.heroLocation).toEqual([0, 1])
		(expect town.hero.attack).toBe(102)
		(expect town.hero.exp).toBe(10)
		(expect town.hero.errorProperty?).toBe(false)

		town.moveDown()

		(expect town.heroLocation).toEqual([1, 1])
		(expect town.hero.attack).toBe(102)
		(expect town.hero.exp).toBe(10)
		(expect town.hero.errorProperty?).toBe(false)
	
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

		spyOn town, "onHeroMove"
		spyOn town, "onPickupKey"
		spyOn town, "onOpenDoor"
		spyOn town, "onHeroChanged"

		(expect town.heroLocation).toEqual [0, 0]
		town.moveDown()

		# pick up key
		(expect town.heroLocation).toEqual [0, 0]
		(expect town.isExistObject 0, 1).toBe true
		(expect town.floors[0][0][1].object.isPickup).not.toBe true
		
		town.moveRight()
		(expect town.onHeroMove.mostRecentCall.args).toEqual [[0, 0], [0, 0], "right"]
		(expect town.onPickupKey.mostRecentCall.args).toEqual [[0, 1]]
		(expect town.onHeroChanged.calls.length).toBe 1
		(expect town.isExistObject 0, 1).toBe false
		(expect town.floors[0][0][1].object.isPickup).toBe true
		(expect town.heroLocation).toEqual [0, 0]
		town.moveRight()
		(expect town.heroLocation).toEqual [0, 1]

		town.moveLeft()

		# open the door
		(expect town.isExistObject 1, 0).toBe true
		(expect town.heroLocation).toEqual [0, 0]
		
		town.moveDown()
		(expect town.onHeroMove.mostRecentCall.args).toEqual [[0, 0], [0, 0], "down"]
		(expect town.onOpenDoor.mostRecentCall.args).toEqual [[1, 0]]
		(expect town.onHeroChanged.calls.length).toBe 2
		(expect town.isExistObject 1, 0).toBe false
		(expect town.heroLocation).toEqual [0, 0]
		town.moveDown()
		(expect town.heroLocation).toEqual [1, 0]

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

		(expect town.getSimpleFloors()).toEqual [
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

		(expect town.getSimpleFloors()).toEqual [
			[
				["0", "key"]
				["door", "plus"]
			]
		]
		town.moveRight()
		(expect town.getSimpleFloors()).toEqual [
			[
				["0", "0"]
				["door", "plus"]
			]
		]
		town.moveDown()
		(expect town.getSimpleFloors()).toEqual [
			[
				["0", "0"]
				["0", "plus"]
			]
		]
		town.moveDown()
		town.moveRight()
		(expect town.getSimpleFloors()).toEqual [
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

		(expect HeroFight.DefaultTownCount).toBe 20
		(expect heroFight.maxTurnCount).toBe 100
		(expect heroFight.attacker.attack).toBe 100
		(expect heroFight.attacker.defense).toBe 80
		(expect heroFight.defenser.attack).toBe 100
		(expect heroFight.defenser.defense).toBe 70

		(expect heroFight.attacker.health).toBe 100
		(expect heroFight.defenser.health).toBe -20
		(expect heroFight.attacker.initHealth).toBe 120
		(expect heroFight.defenser.initHealth).toBe 40

		(expect heroFight.healthList).toEqual [10, 100, -20]
		(expect attacker.health).toBe 120
		(expect defenser.health).toBe 40

		(expect heroFight.getAttackerHealth 0).toBe 120
		(expect heroFight.getAttackerHealth 1).toBe 100
		(expect heroFight.getAttackerHealth 2).toBe 100
		(expect heroFight.getAttackerHealth()).toBe 0

		(expect heroFight.getDefenserHealth 0).toBe 10
		(expect heroFight.getDefenserHealth 1).toBe 10
		(expect heroFight.getDefenserHealth 2).toBe -20
		(expect heroFight.getDefenserHealth()).toBe 0

		(expect heroFight.isWin()).toBe true
		(expect heroFight.isLose()).toBe false
		(expect heroFight.isDraw()).toBe false

		drawHeroFight = new HeroFight
			attacker: attacker
			defenser:
				attack: attacker.defense
				defense: attacker.attack
				health: attacker.health 
		(expect drawHeroFight.isDraw()).toBe true

		loseHeroFight = new HeroFight
			attacker: attacker
			defenser:
				attack: attacker.attack * 10
				defense: attacker.defense * 10
				health: attacker.health 
		(expect loseHeroFight.isLose()).toBe true

	it "测试敌人", ->
		floors = []
		floors.push [
			[{ground: 0}, {ground: 0}]
			[{ground: 0}, {ground: 0}]
		]
		floors[0][0][1].object = enemy =
			type: "enemy"
			attack: 100
			defense: 60
			health: 100
			exp: 10
			money: 10

		town = new RandomTown
			floors: floors
			hero: hero
			heroFloorIndex: 0
			heroLocation: [0, 0]

		spyOn town, "onHeroMove"
		spyOn town, "onHeroChanged"
		spyOn town, "onFightEnemy"
		spyOn town, "onEnemyDead"

		(expect town.getEnemyDamage 0, 1).toEqual 40

		(expect town.hero.exp).toBe 0
		(expect town.hero.money).toBe 200
		town.moveRight()
		(expect town.onFightEnemy.calls.length).toBe 1
		(expect town.onFightEnemy.mostRecentCall.args[0]).toEqual [0, 1]
		(expect town.onFightEnemy.mostRecentCall.args[2].type).toEqual "enemy"
		(expect town.hero.exp).toBe 0
		(expect town.hero.money).toBe 200

		heroFight = town.onFightEnemy.mostRecentCall.args[1]
		(expect heroFight).toEqual jasmine.any(HeroFight)
		(expect heroFight.healthList.length).toBe 5
		
		# 无效的参数都相当于 enableFight heroFight.healthList.length - 1
		heroFight.enableFight 1
		
		(expect town.onHeroChanged.calls.length).toBe 1
		(expect town.hero.exp).toBe 0
		(expect town.hero.money).toBe 200
		(expect enemy.health).toBe 60

		heroFight.enableFight 3
		(expect town.onHeroChanged.calls.length).toBe 2
		(expect enemy.health).toBe 20

		(expect town.onEnemyDead.calls.length).toBe 0
		heroFight.enableFight()
		(expect town.onHeroChanged.calls.length).toBe 3
		(expect town.onEnemyDead.mostRecentCall.args[0]).toEqual [0, 1]
		(expect town.onEnemyDead.calls.length).toBe 1
		(expect enemy.health <= 0).toBe true
		(expect town.hero.exp).toBe 10
		(expect town.hero.money).toBe 210
		
		(expect town.heroLocation).toEqual([0, 0])
		town.moveRight()
		(expect town.heroLocation).toEqual([0, 1])
	
	it "测试玩家失败", ->
		floors = []
		floors.push [
			[{ground: 0}, {ground: 0}]
			[{ground: 0}, {ground: 0}]
		]
		floors[0][0][1].object =
			type: "enemy"
			attack: hero.attack * 10
			defense: hero.defense * 10
			health: hero.health * 10
			exp: 10
			money: 10

		town = new RandomTown
			floors: floors
			hero: hero
			heroFloorIndex: 0
			heroLocation: [0, 0]

		spyOn town, "onFightEnemy"
		spyOn town, "onHeroChanged"
		spyOn town, "onHeroDead"

		(expect (town.getEnemyDamage 0, 1) >= hero.health).toBe true

		town.moveRight()

		heroFight = town.onFightEnemy.mostRecentCall.args[1]

		(expect town.onHeroDead.calls.length).toBe 0
		(expect town.onHeroChanged.calls.length).toBe 0
		heroFight.enableFight()
		(expect town.onHeroDead.calls.length).toBe 1
		(expect town.onHeroChanged.calls.length).toBe 1

		(expect town.hero.health <= 0).toBe true
	
	it "随机生成路径", ->
		(expect GeneratePath 1, 4, [0, 0]
		).toEqual [
			[0, 0]
			[0, 1]
			[0, 2]
			[0, 3]
		]

		(expect GeneratePath 1, 4, [0, 0], 2
		).toEqual [
			[0, 0]
			[0, 1]
		]

		(expect GeneratePath 3, 1, [2, 0], 2
		).toEqual [
			[2, 0]
			[1, 0]
		]

	it "是否为有效位置", ->
		(expect (isValidFloorLocation 1, 2, [0, 0])).toBe true
		(expect (isValidFloorLocation 1, 2, [0, 1])).toBe true
		(expect (isValidFloorLocation 1, 2, [1, 0])).toBe false
		(expect (isValidFloorLocation 1, 2, [-1, -1])).toBe false
		(expect (isValidFloorLocation 0, 1, [0, 0])).toBe false

		(expect (getArroundLocation 1, 2, [0, 0])).toEqual [[-1, 0], [1, 0], [0, -1], [0, 1]]
		(expect (getArroundLocation 1, 2, [1, 0])).toEqual null

		(expect (getArroundLocation 1, 2, [0, 1])).toEqual [[-1, 1], [1, 1], [0, 0], [0, 2]]

	it "生成随机楼层", ->
		(expect GenerateFloor 2, 2, 0
		).toEqual [
			[{ground: 0}, {ground: 0}]
			[{ground: 0}, {ground: 0}]
		]

		(expect GenerateFloor 3, 3, (row, col) ->
			if row is 0 or col is 0 then 1 else 0
		).toEqual [
			[{ground: -1}, {ground: -1}, {ground: -1}]
			[{ground: -1}, {ground: 0}, {ground: 0}]
			[{ground: -1}, {ground: 0}, {ground: 0}]
		]

		(expect GenerateFloorObject [
				[{ground: -1}, {ground: -1}]
				[{ground: -1}, {ground: -1}]
				[{ground: -1}, {ground: -1}]
			],
			[
				[0, 0]
				[1, 0]
				[1, 1]
			],
			"enemy": 1
			"door": 0
		).toEqual [
			[{ground: 0}, {ground: -1}]
			[{ground: 0}, {ground: 0}]
			[{ground: -1, object: {type: "enemy"}}, {ground: -1}]
		]

		(expect GenerateFloorObject [
				[{ground: -1}, {ground: -1}]
				[{ground: -1}, {ground: -1}]
				[{ground: -1}, {ground: -1}]
			],
			[
				[0, 0]
				[1, 0]
				[1, 1]
			],
			"enemy": 0
			"plus": 1
		).toEqual [
			[{ground: 0, object: {type: "plus"}}, {ground: -1, object: {type: "plus"}}]
			[{ground: 0, object: {type: "plus"}}, {ground: 0, object: {type: "plus"}}]
			[{ground: -1, object: {type: "plus"}}, {ground: -1, object: {type: "plus"}}]
		]

		(expect GenerateFloorObject [
				[{ground: -1}, {ground: -1}]
				[{ground: -1}, {ground: 0}]
				[{ground: -1}, {ground: -1}]
				[{ground: -1}, {ground: 0}]
				[{ground: -1}, {ground: 0}]
				[{ground: -1}, {ground: -1}]
			],
			[
				[0, 0]
				[1, 0]
				[2, 0]
				[3, 0]
				[4, 0]
				[5, 0]
			],
			"door": 1
		).toEqual [
			[{ground: 0}, {ground: -1}]
			[{ground: 0}, {ground: 0}]
			[{ground: 0, object:{type: "door"}}, {ground: -1}]
			[{ground: 0}, {ground: 0}]
			[{ground: 0}, {ground: 0}]
			[{ground: 0}, {ground: -1}]
		]

	it "生成多个楼层", ->
		floors = GenerateFloors 4, 8, 8, [0, 0]

		(expect floors.length).toBe 4
		(expect floors[0].length).toBe 8
		(expect floors[0][0].length).toBe 8

	it "测试代理", ->
		town = new RandomTown
			floors: [
				[
					[{ground: 0}, {ground: 0}]
					[{ground: -1}, {ground: 0}]
				]
			]
			hero: hero
			heroFloorIndex: 0
			heroLocation: [0, 0]

		spyOn town, 'onHeroMove'
		town.moveUp()
		(expect town.onHeroMove.mostRecentCall.args).toEqual [[0, 0], [0, 0], "up"]

		town.moveRight()
		(expect town.onHeroMove.mostRecentCall.args).toEqual [[0, 0], [0, 1], "right"]

