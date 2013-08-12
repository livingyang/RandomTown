readline = require("readline")

HeroFight = require("../../lib/HeroFight.coffee").HeroFight
RandomTown = require("../../lib/RandomTown.coffee").RandomTown

town = new RandomTown
	floors: [
		[
			[{ground: RandomTown.Road}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
			[{ground: RandomTown.Road}, {ground: RandomTown.Road}, {ground: RandomTown.Road}]
			[{ground: RandomTown.Wall}, {ground: RandomTown.Wall}, {ground: RandomTown.Wall}]
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

town.floors[0][1][1].object =
	type: "plus"
	attack: 2
	exp: 10
	errorProperty: 10

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
	JSON.stringify town

CommandHandle.s = ->
	town.moveDown()
	JSON.stringify town

CommandHandle.a = ->
	town.moveLeft()
	JSON.stringify town

CommandHandle.d = ->
	town.moveRight()
	JSON.stringify town

CommandHandle.floor = ->
	result = ""
	for rows in town.getCurFloor()
		for grid in rows
			result += "#{grid.ground}\t"
		result += "\n"
	result

CommandHandle.town = ->
	JSON.stringify town

CommandHandle.hero = ->
	JSON.stringify town.hero


