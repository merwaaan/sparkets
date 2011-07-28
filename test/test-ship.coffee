vows = require('vows')
assert = require('assert')

# Setup
require('./support/common')
Ship = require('../build/server/ship').Ship

# Mock-up game class.
class MockGame
	constructor: () ->
		@bullets = {}

		@events =
			push: () ->

		@prefs =
			mapSize: 2000

			ship:
				states:
					'spawned':
						next: 'alive'
						countdown: 1500
					'alive':
						next: 'exploding'
						countdown: null
					'exploding':
						next: 'dead'
						countdown: 1000
					'dead':
						next: 'alive'
						countdown: null

				boundingRadius: 9
				dirInc: 0.12
				speed: 0.3
				frictionDecay: 0.97
				minFirepower: 1.3
				firepowerInc: 0.1
				maxFirepower: 3
				cannonCooldown: 20
				maxExploFrame: 50
				enableGravity: false

			bullet:
				boundingRadius: 2

			shield:
				shipPush: -200

			debug:
				sendHitBoxes: no

	newGameObject: (fun) ->
		fun(0)

	collidesWithPlanet: (ship) ->
		no

exports.suite = vows.describe('Server ship')

events = require('events')

exports.suite.addBatch
	'ship spawning':
		topic: () ->
			game = new MockGame()
			ship = new Ship(0, game, 0)

			ship.spawn()
			return ship

		'should move to `spawned` state': (err, ship) ->
			assert.isNull(err)
			assert.isObject(ship)
			assert.strictEqual(ship.state, 'spawned')

	'ship exploding':
		topic: () ->
			game = new MockGame()
			ship = new Ship(0, game, 0)

			ship.spawn()
			ship.explode()
			return ship

		'should move to `exploding` state': (err, ship) ->
			assert.isNull(err)
			assert.isObject(ship)
			assert.strictEqual(ship.state, 'exploding')
