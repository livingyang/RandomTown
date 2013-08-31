collie.ImageManager.add
	arrow: "arrow.png"

FightLayer = collie.Class
	$init: (options) ->
		options ?= {}
		options.width = 100
		options.height = 100
		@set options
		
		new collie.DisplayObject
			x: 0
			y: 0
			width: options.width
			height: options.height
			backgroundColor : "gray"
		.addTo this

		@arrowObject = new ArrowObject
			arrowImage: "arrow"
		.addTo this

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
			complete: => collie.Renderer.removeLayer this


, collie.Layer

@FightLayer = FightLayer