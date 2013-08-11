class HeroFight
	constructor: (options) ->
		options ?= {}

		@attacker = JSON.parse(JSON.stringify(options.attacker ? {}))
		@defenser = JSON.parse(JSON.stringify(options.defenser ? {}))
		@maxTurnCount = options.maxTurnCount

		for turnIndex in [0...@maxTurnCount]
			[attacker, defenser] = if turnIndex % 2 is 0
			then [@attacker, @defenser]
			else [@defenser, @attacker]

			defenser.health -= attacker.attack - defenser.defense
			break if defenser.health <= 0

@HeroFight = HeroFight
