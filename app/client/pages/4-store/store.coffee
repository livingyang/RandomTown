Template.store.isIntoRandomTown = ->
	isIntoRandomTown()

Template.store.events "click #cancelToHome": ->
	cancelToHome()

Template.store.events "click #coinToAttack": ->
	hero = loadHero()
	if hero.money >= 5
		hero.money -= 5
		hero.attack += 2
		saveHero hero
Template.store.events "click #coinToDefense": ->
	hero = loadHero()
	if hero.money >= 5
		hero.money -= 5
		hero.defense += 2
		saveHero hero
Template.store.events "click #expToAttack": ->
	hero = loadHero()
	if hero.exp >= 5
		hero.exp -= 5
		hero.attack += 2
		saveHero hero
Template.store.events "click #expToDefense": ->
	hero = loadHero()
	if hero.exp >= 5
		hero.exp -= 5
		hero.defense += 2
		saveHero hero
	
