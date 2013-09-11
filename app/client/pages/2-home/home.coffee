
Template.home.events "click #homeTest" : ->
	console.log "homeTest"
	console.log IronRouter


Template.home.rendered = ->
	console.log "home rendered"
	console.log document.getElementById "home-title"

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

	destory: ->
		console.log "home destory"
		super
	destoried: ->
		console.log "home destory"
		super

