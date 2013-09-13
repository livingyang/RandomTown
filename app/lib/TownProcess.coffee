TownProcess = new Meteor.Collection "townProcess"

@getTownLevel = ->
	(TownProcess.findOne owner: Meteor.userId())?.level or 1

@setTownLevel = (level) ->
	levelRecord = TownProcess.findOne owner: Meteor.userId()
	if levelRecord?
		TownProcess.update levelRecord._id, $set: level: level
	else
		TownProcess.insert owner: Meteor.userId(), level: level
		
@TownProcess = TownProcess