setPageNameToList "map"

Template.map.created = ->
	KeyboardJS.on "a", ->
    	console.log "you pressed a!"

    for key, handler of CommandHandle
    	KeyboardJS.on key, handler
    

Template.map.destroyed = ->
	for key, handler of CommandHandle
    	KeyboardJS.clear key

	stopPlayMissionResult()

Template.map.events "click #start" : ->
	if isPlayingMission()
		stopPlayMissionResult()
	else
		playMissionResult document.getElementById("fight")

Template.map.events "click .mapControlButton" : ->
	# console.log @key
	# console.log CommandHandle[@key]
	CommandHandle[@key]?()

Template.map.mapControlButtons = ->
	(key: key for key, func of CommandHandle)