collie.ImageManager.add
	arrow: "arrow.png"

FightLayer = collie.Class
	$init: (options) ->
		options ?= {}
		options.width ?= 100
		options.height ?= 100
		@set options
		
		new collie.DisplayObject
			x: 0
			y: 0
			width: options.width
			height: options.height
			backgroundColor : "gray"
			opacity: 0.7
		.addTo this

		@arrowObject = new ArrowObject
			arrowImage: "arrow"
		.addTo this

		@arrowObject.set "x", 100
		@arrowObject.set "y", 100

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

		healthList = [80, 150, 40, 100, 20, 68, 0]
		runTimeWork
			delay: 300
			count: healthList.length
			do: (index) =>
				console.log "health = #{healthList[index]}"
				if index % 2 is 1
					# oText.text healthList[index]
					@arrowObject.arrowLeft()
				else
					# oCurText.text healthList[index]
					@arrowObject.arrowRight()
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