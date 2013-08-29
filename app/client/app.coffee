Meteor.startup ->
	console.log "Client Start!!"

Router.map ->
	@route "login", path: "/"
	@route "home"
	@route "town"

Router.configure
	layout: "layout"