readline = require("readline")
RandomTown = require("../../lib/RandomTown.coffee").RandomTown
GenerateFloor = require("../../lib/RandomTown.coffee").GenerateFloor
GenerateFloors = require("../../lib/RandomTown.coffee").GenerateFloors
GeneratePath = require("../../lib/RandomTown.coffee").GeneratePath
GenerateFloorObject = require("../../lib/RandomTown.coffee").GenerateFloorObject
MazeGenerator = require("../../lib/MazeGenerator.coffee").MazeGenerator

town = new RandomTown
	floors: [
		[
			[{ground: RandomTown.Road}, {ground: RandomTown.Wall}, {ground: RandomTown.Road}]
			[{ground: RandomTown.Road}, {ground: RandomTown.Road}, {ground: RandomTown.Road}]
			[{ground: RandomTown.Road}, {ground: RandomTown.Road}, {ground: RandomTown.Wall}]
		]
		[
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Road}, {ground: RandomTown.Road}, {ground: RandomTown.Road}]
			[{ground: RandomTown.Road}, {ground: RandomTown.Road}, {ground: RandomTown.Wall}]
		]
	]
	hero:
		name: "SuperManXX"
		attack: 100
		defense: 80
		health: 1000
		exp: 0
		money: 200
	heroFloorIndex: 0
	heroLocation: [1, 0]

town.floors[0][1][2].object =
	type: "plus"
	attack: 2
	exp: 10
	errorProperty: 10

town.floors[0][0][0].object =
	type: "key"
	color: "yellow"

town.floors[0][0][2].object =
	type: "hole"
	floorIndex: 1
	location: [1, 1]

town.floors[1][1][1].object =
	type: "hole"
	floorIndex: 0
	location: [0, 2]

town.floors[0][1][1].object =
	type: "door"
	color: "yellow"

town.floors[0][2][1].object =
	type: "enemy"
	attack: 100
	defense: 30
	health: 100
	exp: 10
	money: 10

CommandHandle = {}

rl = readline.createInterface process.stdin, process.stdout
rl.setPrompt "> "
rl.prompt()

rl.on("line", (line) ->
	[command, params...] = line.trim().split " "
	if typeof CommandHandle[command] is "function"
	then console.log CommandHandle[command](params)
	else console.log "No command handle : #{command}\ntype 'help' to get help"
	rl.prompt()
).on "close", ->
	console.log "Have a great day!"
	process.exit 0

CommandHandle.help = ->
	"
	[w|s|a|d] to move hero\n
	floor|f to show current floor\n
	hero|h to show hero info\n
	exp to use exp to up attack\n
	money to use money to up defense"

CommandHandle.exit = ->
	rl.close()

CommandHandle.w = ->
	town.moveUp()
	@floor()

CommandHandle.s = ->
	town.moveDown()
	@floor()

CommandHandle.a = ->
	town.moveLeft()
	@floor()

CommandHandle.d = ->
	town.moveRight()
	@floor()

CommandHandle.f = (params) ->
	@floor params

CommandHandle.e = ->
	@exit()

CommandHandle.h = ->
	@hero()

CommandHandle.floor = (params) ->
	floorIndex = if params?[0]? and 0 < params[0] <= town.floors.length
	then Number(params[0]) - 1
	else town.heroFloorIndex

	floor = town.getSimpleFloors()[floorIndex]

	floor[town.heroLocation[0]][town.heroLocation[1]] = "Hero" if town.heroFloorIndex is floorIndex
	
	"floor : #{floorIndex + 1}/#{town.floors.length}\n" + (cols.join "\t" for cols in floor).join "\n"

CommandHandle.exp = ->
	town.changeHeroProperty
		exp: -10
		attack: 1

CommandHandle.money = ->
	town.changeHeroProperty
		money: -10
		defense: 1

CommandHandle.town = ->
	JSON.stringify town

CommandHandle.hero = ->
	JSON.stringify town.hero

CommandHandle.g = (params) ->
	@grid params

CommandHandle.grid = (params) ->
	if params? and params.length >= 2
	then JSON.stringify town.getCurFloor()[params[0]][params[1]]
	else "grid not find"
	
CommandHandle.damage = (params) ->
	town.getEnemyDamage params?[0], params?[1]

CommandHandle.reset = (params) ->

	initLocation = [0, 0]
	floors = GenerateFloors 4, 8, 8, initLocation

	town = new RandomTown
		floors: floors
		hero:
			name: "SuperManXX"
			attack: 100
			defense: 80
			health: 1000
			exp: 0
			money: 200
		heroFloorIndex: 0
		heroLocation: initLocation

	@town()
	