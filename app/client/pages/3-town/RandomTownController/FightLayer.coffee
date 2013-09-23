collie.ImageManager.add
	arrow: "arrow.png"

FightLayer = collie.Class
	$init: (options) ->
		options ?= {}
		options.width ?= 100
		options.height ?= 100
		@set options

		console.log options
		
		new collie.DisplayObject
			x: 0
			y: 0
			width: options.width
			height: options.height
			backgroundColor: "gray"
			opacity: 0.9
		.addTo this

		@arrowObject = new ArrowObject
			arrowImage: "arrow"
		.addTo this

		@arrowObject.set x: 100, y: 100

		options.start?()
		runTimeWork = (options) ->
			collie.Timer.cycle (oEvent) ->
				options.do oEvent.value
			, options.delay * options.count,
				from: 0
				to: options.count - 1
				loop: 1
			.attach
				complete: -> options.complete()

		# 加入头像
		options.heroObject.set x: 50, y: 100
		options.enemyObject.set x: 250, y: 100
		options.heroObject.addTo this
		options.enemyObject.addTo this
		healthList = options.heroFight.healthList #[80, 150, 40, 100, 20, 68, 0]
		
		oText = new collie.Text
			x : 50
			y : 150
			fontSize : 30
			fontColor : "#000000"
		.addTo(this).text options.heroFight.attacker.initHealth

		oCurText = new collie.Text
			x : 250
			y : 150
			fontSize : 30
			fontColor : "#000000"
		.addTo(this).text options.heroFight.defenser.initHealth

		# attack
		oAAttack = new collie.Text
			x : 50
			y : 200
			fontSize : 18
			fontColor : "#ff0000"
		.addTo(this).text "attack:#{options.heroFight.attacker.attack}"

		oDAttack = new collie.Text
			x : 250
			y : 200
			fontSize : 18
			fontColor : "#ff0000"
		.addTo(this).text "attack:#{options.heroFight.defenser.attack}"
		# defense
		oADefense = new collie.Text
			x : 50
			y : 250
			fontSize : 18
			fontColor : "#0000ff"
		.addTo(this).text "defense:#{options.heroFight.attacker.defense}"

		oDDefense = new collie.Text
			x : 250
			y : 250
			fontSize : 18
			fontColor : "#0000ff"
		.addTo(this).text "defense:#{options.heroFight.defenser.defense}"

		oTurnCount = new collie.Text
			x : 200
			y : 300
			fontSize : 18
			fontColor : "#ffffff"
		.addTo(this).text options.heroFight.healthList.length

		runTimeWork
			delay: 300
			count: healthList.length
			do: (index) =>
				# console.log "health = #{healthList[index]}"
				if index % 2 is 1
					collie.Timer.delay (-> oText.text healthList[index]), 300
					@arrowObject.arrowLeft()
				else
					collie.Timer.delay (-> oCurText.text healthList[index]), 300
					# oCurText.text healthList[index]
					@arrowObject.arrowRight()
				oTurnCount.text healthList.length - index
				options.step?()
			complete: =>
				collie.Renderer.removeLayer this
				options.stop?()

	onFightStart: ->
		console.log "FightLayer#onFightStart"
	onFightStop: ->
		console.log "FightLayer#onFightStop"

	createFightObjectDetails: (fightObject, x, y) ->
		

, collie.Layer

@FightLayer = FightLayer