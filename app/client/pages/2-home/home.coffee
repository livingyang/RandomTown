
Template.backHome.events "click .backHome" : ->
	gotoPage "home"

Template.home.events "click .pageButton" : ->
	gotoPage this.pageName

class @HomeController extends RouteController
	Template: "home"

	run: ->
		console.log "home run"
		super