ArrowObject = collie.Class
	$init: (options) ->
		options ?= {}
		options.width = 100
		options.height = 100
		@set options

		@arrow = new collie.DisplayObject
			backgroundImage: options.arrowImage
		.addTo this

		@timerMoveRight = collie.Timer.transition @arrow, 300,
			from: 0
			to : 100
			set : "x"
			useAutoStart : false,
			onStart : => @arrow.set "scaleX", 1

		@timerMoveLeft = collie.Timer.transition @arrow, 300,
			from: 100
			to : 0
			set : "x"
			useAutoStart : false,
			onStart : => @arrow.set "scaleX", -1

	arrowLeft: ->
		@timerMoveLeft.start()
		@timerMoveRight.stop()

	arrowRight: ->
		@timerMoveRight.start()
		@timerMoveLeft.stop()

, collie.DisplayObject

@ArrowObject = ArrowObject