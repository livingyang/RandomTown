
Template.backHome.events "click .backHome" : ->
	gotoPage "home"

Template.home.events "click .pageButton" : ->
	gotoPage this.pageName
