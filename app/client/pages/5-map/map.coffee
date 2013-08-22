setPageNameToList "map"

controller = null

Template.map.created = ->

Template.map.rendered = ->
	controller = new RandomTownController()
	controller.playMissionResult document.getElementById "fight"
	# playMissionResult document.getElementById("fight")

Template.map.destroyed = ->
	controller.stopPlay()
	controller = null
	# stopPlayMissionResult()

Template.map.events "click .mapControlButton" : ->
	# console.log @key
	# console.log CommandHandle[@key]
	# CommandHandle[@key]?()
	controller.keyboardHandle[@key]?()

Template.map.mapControlButtons = ->
	(key: key for key, func of controller?.keyboardHandle or [])