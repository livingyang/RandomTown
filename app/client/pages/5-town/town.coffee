setPageNameToList "town"

Template.town.rendered = ->

Template.town.destroyed = ->
	RandomTownController.getInstance().stopGame()

Template.town.events "click .mapControlButton" : ->
	RandomTownController.getInstance().keyboardHandle[@key]?()

Template.town.events "click #start" : ->
	RandomTownController.getInstance().startGame
		divElement: document.getElementById "fight"
		floorCount: 4
		rows: 11
		cols: 11
		initLocation: [0, 0]
		heroFloorIndex: 0
		hero:
			name: "SuperManXX"
			attack: 100
			defense: 80
			health: 1000
			exp: 0
			money: 200
			key:
				yellow: 1

	Session.set "hero", RandomTownController.getInstance().town.hero if RandomTownController.getInstance()?.town?.hero?

Template.town.mapControlButtons = ->
	(key: key for key, func of RandomTownController.getInstance().keyboardHandle)

Template.town.hasHero = ->
	(Session.get "hero")?

Template.hero.hero = ->
	Session.get "hero"

Template.town.lastEnemy = ->
	(Session.get "lastEnemy")?

Template.enemy.enemy = ->
	Session.get "lastEnemy"
	