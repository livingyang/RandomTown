Meteor.startup ->
	console.log "Client Start!!"

Router.map ->
	@route "login"
	@route "home", path: "/"
	@route "town"
	@route "store"

Router.configure
	layout: "layout"