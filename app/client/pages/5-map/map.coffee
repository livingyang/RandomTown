setPageNameToList "map"

Template.map.rendered = ->
	
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

Template.map.destroyed = ->
	RandomTownController.getInstance().stopGame()

Template.map.events "click .mapControlButton" : ->
	RandomTownController.getInstance().keyboardHandle[@key]?()

Template.map.mapControlButtons = ->
	(key: key for key, func of RandomTownController.getInstance().keyboardHandle)