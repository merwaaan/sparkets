server = require './server'
prefs = require './prefs'
Mine = require('./mine').Mine

class BonusMine
	type: 'mine'

	constructor: () ->
		@mines = prefs.bonus.mine.mineCount

	use: () ->
		return if @mines == 0

		server.game.newGameObject (id) =>
			server.game.mines[id] = new Mine(@ship, id)

		--@mines
		@ship.bonus = null if @mines == 0

exports.BonusMine = BonusMine
exports.constructor = BonusMine
exports.type = 'bonusMine'
