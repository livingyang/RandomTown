Meteor.startup ->
	console.log "Client Start!!"

Router.map ->
	@route "login"
	@route "home", path: "/"
	@route "town"

Router.configure
	layout: "layout"