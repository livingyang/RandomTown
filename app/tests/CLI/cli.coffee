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

CommandHandle = {}

rl = readline.createInterface process.stdin, process.stdout
rl.setPrompt "> "
rl.prompt()

rl.on("line", (line) ->
	if typeof CommandHandle[line.trim()] is "function"
	then console.log CommandHandle[line.trim()]()
	else console.log "No comand handle : #{line.trim()}"
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
	@.floor()

CommandHandle.s = ->
	town.moveDown()
	@.floor()

CommandHandle.a = ->
	town.moveLeft()
	@.floor()

CommandHandle.d = ->
	town.moveRight()
	@.floor()

CommandHandle.floor = ->
	result = ""
	for row, cols of town.getCurFloor()
		for col, grid of cols
			if Number(row) is town.heroLocation[0] and Number(col) is town.heroLocation[1]
				result += "Hero\t"
			else
				result += if grid.object?.type?
				then "#{grid.object.type}\t"
				else "#{grid.ground}\t"
		result += "\n"
	result

CommandHandle.town = ->
	JSON.stringify town

CommandHandle.hero = ->
	JSON.stringify town.hero


