
Template.backHome.events "click .backHome" : ->
	gotoPage "home"

Template.home.events "click .pageButton" : ->
	gotoPage this.pageName

Template.home.pageList = ->
	({pageName: pageName} for pageName in getPageNameList())
