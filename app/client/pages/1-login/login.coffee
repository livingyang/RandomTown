setPageNameToList "login"

Template.login.events "click #btnLogout" : ->
	Meteor.logout -> console.log "logout!!"

Meteor.startup ->
	gotoPage "login"