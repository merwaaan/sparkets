logger = require './logger'
utils = require '../utils'
ChangingObject = require('./changingObject').ChangingObject
Bullet = require './bullet'
Mine = require './mine'

class Ship extends ChangingObject
	constructor: (@id, @game, @playerId, name, color) ->
		super()

		@watchChanges 'type'
		@watchChanges 'name'
		@watchChanges 'color'
		@watchChanges 'stats'
		@watchChanges 'hitRadius'
		@watchChanges 'state'
		@watchChanges 'countdown'
		@watchChanges 'pos'
		@watchChanges 'vel'
		@watchChanges 'dir'
		@watchChanges 'thrust'
		@watchChanges 'firePower'
		@watchChanges 'cannonHeat'
		@watchChanges 'killingAccel'
		@watchChanges 'boost'

		@type = 'ship'
		@name = name or null
		@color = color or utils.randomColor()
		@hitRadius = @game.prefs.ship.hitRadius

		# Session stats.
		@stats =
			kills: 0
			deaths: 0

		@spawn()

	spawn: () ->
		@state = 'alive'

		@pos =
			x: Math.random() * @game.prefs.mapSize.w
			y: Math.random() * @game.prefs.mapSize.h
		@vel =
			x: 0
			y: 0
		@dir = Math.random() * 2*Math.PI

		@thrust = false
		@firePower = @game.prefs.ship.minFirepower
		@cannonHeat = 0
		@bonus = null
		@bonusTimeout = {}
		@boost = 1
		@boostDecay = 0
		@inverseTurn = no
		@killingAccel = {x: 0, y: 0}

		@spawn() if @game.collidesWithPlanet(@)

		@debug "spawned"

	turnLeft: () ->
		@dir -= if @inverseTurn then -@game.prefs.ship.dirInc else @game.prefs.ship.dirInc
		@ddebug "turn left"

	turnRight: () ->
		@dir += if @inverseTurn then -@game.prefs.ship.dirInc else @game.prefs.ship.dirInc
		@ddebug "turn right"

	ahead: () ->
		@vel.x += Math.cos(@dir) * @game.prefs.ship.speed * @boost
		@vel.y += Math.sin(@dir) * @game.prefs.ship.speed * @boost
		@thrust = true
		@ddebug "thrust"

	chargeFire: () ->
		return if @cannonHeat > 0

		@firePower = Math.min(@firePower + @game.prefs.ship.firepowerInc, @game.prefs.ship.maxFirepower)
		@ddebug "charge fire"

	useBonus: () ->
		return if @state is 'exploding' or @state is 'dead' or not @bonus?

		@ddebug "use #{@bonus.type} bonus"
		@bonus.use()

	move: () ->
		return if @state is 'exploding' or @state is 'dead'

		{x, y} = @pos

		# With gravity enabled.
		if @game.prefs.ship.enableGravity
			{x: ax, y: ay} = @vel

			for id, p of @game.planets
				d = (p.pos.x-x)*(p.pos.x-x) + (p.pos.y-y)*(p.pos.y-y)
				d2 = 20 * p.force / (d * Math.sqrt(d))
				ax -= (x-p.pos.x) * d2
				ay -= (y-p.pos.y) * d2

			@pos.x = x + ax
			@pos.y = y + ay
			@vel.x = ax
			@vel.y = ay

		# Without gravity.
		else
			@pos.x += @vel.x
			@pos.y += @vel.y

		# Warp the ship around the map
		{w, h} = @game.prefs.mapSize
		@pos.x = if @pos.x < 0 then w else @pos.x
		@pos.x = if @pos.x > w then 0 else @pos.x
		@pos.y = if @pos.y < 0 then h else @pos.y
		@pos.y = if @pos.y > h then 0 else @pos.y

		@vel.x *= @game.prefs.ship.frictionDecay
		@vel.y *= @game.prefs.ship.frictionDecay

		# Only update if the change in position is noticeable.
		if Math.abs(@pos.x-x) > .05 or
				Math.abs(@pos.y-y) > .05
			@changed 'pos'
			@changed 'vel'

	tangible: () ->
		@state is 'alive'

	collidesWith: ({pos: {x,y}, hitRadius}, offset = {x:0, y:0}) ->
		x += offset.x
		y += offset.y
		utils.distance(@pos.x, @pos.y, x, y) < @hitRadius + hitRadius

	nextState: () ->
		@state = @game.prefs.ship.states[@state].next
		@countdown = @game.prefs.ship.states[@state].countdown

	update: () ->
		if @countdown?
			@countdown -= @game.prefs.timestep
			@nextState() if @countdown <= 0

		switch @state
			when 'alive'
				--@cannonHeat if @cannonHeat > 0

				@boost -= @boostDecay if @boost > 1
				@boost = 1 if @boost < 1

	fire : () ->
		return if @state is 'exploding' or @state is 'dead' or @cannonHeat > 0

		@game.newGameObject (id) =>
			@ddebug "fire bullet ##{id}"
			return @game.bullets[id] = new Bullet.Bullet(@, id, @game)

		@firePower = @game.prefs.ship.minFirepower
		@cannonHeat = @game.prefs.ship.cannonCooldown

	explode : () ->
		@nextState()
		@addStat('deaths', 1)
		@debug "explode"

	addStat: (field, increment) ->
		@stats[field] += increment
		@changed 'stats'

	# Prefix message with ship id.
	log: (type, msg) ->
		logger.log(type, "(ship ##{@.id}) " + msg)

	error: (msg) -> @log('error', msg)
	warn: (msg) -> @log('warn', msg)
	info: (msg) -> @log('info', msg)
	debug: (msg) -> @log('debug', msg)
	ddebug: (msg) -> @log('ship', msg)

exports.Ship = Ship
