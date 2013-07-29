
Template.container.currentPage = ->
	if Template[Session.get "currentPage"]? then Template[Session.get "currentPage"]() else "no page"

gotoPage = (name) ->
	if Template[name]? then Session.set "currentPage", name else console.log "Cannot go to page: #{name}" 

getPageNameList = ->
	(Session.get "pageList") ? []

setPageNameToList = (pageName) ->
	oldList = getPageNameList()
	for name in oldList
		return if name is pageName
	oldList.push pageName
	Session.set "pageList", oldList

@gotoPage = gotoPage
@getPageNameList = getPageNameList
@setPageNameToList = setPageNameToList