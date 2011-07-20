Tracker = require('./tracker').Tracker

class BonusTracker
	type: 'tracker'

	constructor: (@game, @bonus) ->

	use: () ->
		@game.newGameObject (id) =>
			dropPos = {x: @bonus.pos.x,	y: @bonus.pos.y}
			@game.trackers[id] = new Tracker(@bonus.holder, @bonus.holder.target(), dropPos, id, @game)

		# Clean up.
		@bonus.holder.releaseBonus()
		@bonus.setState 'dead'

exports.BonusTracker = BonusTracker
exports.constructor = BonusTracker
exports.type = 'bonusTracker'
