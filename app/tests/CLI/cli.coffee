readline = require("readline")

HeroFight = require("../../lib/HeroFight.coffee").HeroFight
RandomTown = require("../../lib/RandomTown.coffee").RandomTown

town = new RandomTown
	floors: [
		[
			[{ground: RandomTown.Road}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Road}, {ground: RandomTown.Road}, {ground: RandomTown.Road}]
			[{ground: RandomTown.Road}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
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

town.floors[0][1][1].object =
	type: "door"
	color: "yellow"

town.floors[0][2][1].object =
	type: "enemy"
	attack: 100
	defense: 30
	exp: 10
	money: 10

CommandHandle = {}

rl = readline.createInterface process.stdin, process.stdout
rl.setPrompt "> "
rl.prompt()

rl.on("line", (line) ->
	if typeof CommandHandle[line.trim()] is "function"
	then console.log CommandHandle[line.trim()]()
	else console.log "No comand handle : #{line.trim()}\ntype 'help' to get help"
	rl.prompt()
).on "close", ->
	console.log "Have a great day!"
	process.exit 0

CommandHandle.help = ->
	"[w|s|a|d] to move hero\n"

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

CommandHandle.floor = ->
	floor = town.getSimpleFloors()[town.heroFloorIndex]
	floor[town.heroLocation[0]][town.heroLocation[1]] = "Hero"
	
	(cols.join "\t" for cols in floor).join "\n"

CommandHandle.town = ->
	JSON.stringify town

CommandHandle.hero = ->
	JSON.stringify town.hero
