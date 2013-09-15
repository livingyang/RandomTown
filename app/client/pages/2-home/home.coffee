# home 为主城页面，对英雄进行属性加成，有商店，训练所等功能
# 两个状态，准备中，探索中
# 游戏未开始时，处于准备中，开始后，处于探索中，此时可通过回到起始点，或者回城功能回到城中

# RandomTown save and load
saveRandomTown = (randomTown) ->
	Session.set "randomTown", randomTown

@saveRandomTown = saveRandomTown

loadRandomTown = ->
	Session.get "randomTown"

@loadRandomTown = loadRandomTown

cleanRandomTown = ->
	Session.set "randomTown", null

isRandomTownExist = ->
	(Session.get "randomTown")?

createRandomTown = ->
	new RandomTown
		floors: GenerateFloors getTownLevel(), 11, 11, [0, 0], (row, col) ->
			if row % 2 is 0 and col % 2 is 0 then 0.5 else 0.8
		hero: getDefaultHero()
		heroFloorIndex: 0
		heroLocation: [0, 0]
# hero manage

# 玩家是否在探索中
isIntoRandomTown = ->
	isRandomTownExist()

getDefaultHero = ->
	attack: 1
	defense: 122
	health: 100
	exp: 0
	money: 0
	key:
		yellow: 1

saveHero = (hero) ->
	Session.set "hero", hero

@saveHero = saveHero

loadHero = ->
	Session.get "hero"

@loadHero = loadHero

backToHome = (randomTown) ->
	saveRandomTown randomTown
	saveHero randomTown.hero
	Router.go "home"

@backToHome = backToHome

completeRandomTown = (randomTown) ->
	setTownLevel randomTown.floors.length + 1
	saveRandomTown null
	Router.go "home"

@completeRandomTown = completeRandomTown

deadInRandomTown =  ->
	saveRandomTown null
	Router.go "home"

@deadInRandomTown = deadInRandomTown
# home template

Template.home.rendered = ->
	console.log "Template.home.rendered"

Template.home.townLevel = ->
	getTownLevel()

Template.home.events "click #resetLevel": ->
	setTownLevel 1
	cleanRandomTown()

Template.home.events "click #startRandomTown": ->
	if isIntoRandomTown()
		randomTown = loadRandomTown()
		randomTown.hero = loadHero()
		saveRandomTown randomTown
	else
		randomTown = createRandomTown()
		saveRandomTown randomTown
		saveHero randomTown.hero

	Router.go "town"



class @HomeController extends RouteController
	template: "home"

	run: ->
		console.log "home run1"
		super
		console.log document.getElementById "home-title"
		console.log "home run2"
	onBeforeRun: ->
		console.log "home onBeforeRun"
		super
	onAfterRun: ->
		console.log "home onAfterRun1"
		super
		console.log document.getElementById "home-title"
		console.log "home onAfterRun2"
	render: ->
		console.log "home render1"
		super
		console.log document.getElementById "home-title"
		console.log "home render2"
	rendered: ->
		console.log "home rendered"
		super

