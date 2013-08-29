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

		(expect town.heroFloorIndex).toBe(0)
		(expect town.heroLocation).toEqual([1, 0])

		town.moveUp()
		(expect town.heroLocation).toEqual([1, 0])
		town.moveDown()
		town.moveLeft()
		(expect town.heroLocation).toEqual([1, 0])

		town.moveRight()
		(expect town.heroFloorIndex).toBe(0)
		(expect town.heroLocation).toEqual([1, 1])

		town.moveRight()
		(expect town.heroFloorIndex).toBe(1)
		(expect town.heroLocation).toEqual([1, 2])

		town.moveLeft()
		(expect town.heroFloorIndex).toBe(1)
		(expect town.heroLocation).toEqual([1, 1])

		town.moveRight()
		(expect town.heroFloorIndex).toBe(0)
		(expect town.heroLocation).toEqual([1, 1])

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

		delegate =
			onHeroMove: (oldLocation, newLocation, direction) ->
			onUsePlus: (plusLocation) ->
			onHeroChanged: ->

		spyOn delegate, "onHeroMove"
		spyOn delegate, "onUsePlus"
		spyOn delegate, "onHeroChanged"

		town = new RandomTown
			floors: floors
			hero: hero
			heroFloorIndex: 0
			heroLocation: [0, 1]
			delegate: delegate
		
		(expect town.isExistObject 0, 0).toBe(false)
		
		(expect town.hero.attack).toBe(100)
		(expect town.hero.exp).toBe(0)
		(expect floors[0][1][1].object.isUsed).not.toBe(true)
		(expect town.isExistObject 1, 1).toBe(true)
		
		town.moveDown()

		(expect delegate.onHeroMove.mostRecentCall.args).toEqual [[0, 1], [0, 1], "down"]
		(expect delegate.onUsePlus.mostRecentCall.args).toEqual [[1, 1]]
		(expect delegate.onHeroChanged.calls.length).toBe 1
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

		delegate =
			onHeroMove: (oldLocation, newLocation, direction) ->
			onPickupKey: (keyLocation) ->
			onOpenDoor: (doorLocation) ->
			onHeroChanged: ->

		spyOn delegate, "onHeroMove"
		spyOn delegate, "onPickupKey"
		spyOn delegate, "onOpenDoor"
		spyOn delegate, "onHeroChanged"

		town = new RandomTown
			floors: floors
			hero: hero
			heroFloorIndex: 0
			heroLocation: [0, 0]
			delegate: delegate

		(expect town.heroLocation).toEqual [0, 0]
		town.moveDown()

		# pick up key
		(expect town.heroLocation).toEqual [0, 0]
		(expect town.isExistObject 0, 1).toBe true
		(expect town.floors[0][0][1].object.isPickup).not.toBe true
		
		town.moveRight()
		(expect delegate.onHeroMove.mostRecentCall.args).toEqual [[0, 0], [0, 0], "right"]
		(expect delegate.onPickupKey.mostRecentCall.args).toEqual [[0, 1]]
		(expect delegate.onHeroChanged.calls.length).toBe 1
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
		(expect delegate.onHeroMove.mostRecentCall.args).toEqual [[0, 0], [0, 0], "down"]
		(expect delegate.onOpenDoor.mostRecentCall.args).toEqual [[1, 0]]
		(expect delegate.onHeroChanged.calls.length).toBe 2
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

		(expect heroFight.maxTurnCount).toBe(100)
		(expect heroFight.attacker.attack).toBe(100)
		(expect heroFight.attacker.defense).toBe(80)
		(expect heroFight.defenser.attack).toBe(100)
		(expect heroFight.defenser.defense).toBe(70)

		(expect heroFight.attacker.health).toBe(100)
		(expect heroFight.defenser.health).toBe(-20)

		(expect attacker.health).toBe(120)
		(expect defenser.health).toBe(40)

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
			health: 100
			exp: 10
			money: 10

		delegate =
			onHeroMove: (oldLocation, newLocation, direction) ->
			onHeroChanged: ->

		spyOn delegate, "onHeroMove"
		spyOn delegate, "onHeroChanged"

		town = new RandomTown
			floors: floors
			hero: hero
			heroFloorIndex: 0
			heroLocation: [0, 0]
			delegate: delegate

		(expect town.getEnemyDamage 0, 1).toEqual 20

		(expect town.hero.exp).toBe 0
		(expect town.hero.money).toBe 200
		town.moveRight()
		(expect delegate.onHeroChanged.calls.length).toBe 1
		(expect town.hero.exp).toBe 10
		(expect town.hero.money).toBe 210
		(expect town.heroLocation).toEqual([0, 0])
		town.moveRight()
		(expect town.heroLocation).toEqual([0, 1])
	
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
		delegate =
			onHeroMove: (oldLocation, newLocation, direction) ->

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
			delegate: delegate

		spyOn delegate, 'onHeroMove'
		town.moveUp()
		(expect delegate.onHeroMove.mostRecentCall.args).toEqual [[0, 0], [0, 0], "up"]

		town.moveRight()
		(expect delegate.onHeroMove.mostRecentCall.args).toEqual [[0, 0], [0, 1], "right"]

