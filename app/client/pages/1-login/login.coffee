Template.login.events "click #btnLogout" : ->
	Meteor.logout -> console.log "logout!!"
