_ = require('lodash')

GameList = React.createClass

	getInitialState: ->
		games: []

	render: ->

		games = @state.games.map (game) =>
			<Game
				name={game.name}
				players={game.players}
				timer={game.timer} />

		<table>
			<thead>
				<th>Name</th>
				<th>Players</th>
				<th>Time left</th>
			</thead>
			<tbody id="games">
				{games}
			</tbody>
		</table>

	componentDidMount: ->

		# Connect to the server
		@socket = io.connect()

		# Grab the game list every minute
		setInterval( (() =>
			@socket.emit('get game list')), 60 * 1000)

		# Fetch the game list at first connection
		@socket.on 'connect', () =>
			@socket.emit 'get game list'

		# Update the list of active games
		@socket.on 'game list', (data) =>

			minutesLeft = (start, duration) ->
				new Date(duration - (Date.now() - start)).getMinutes()

			games = _.map data, (game, name) ->
				name: name
				players: game.players
				timer: minutesLeft data.duration

			@setState {games: games}


Game = React.createClass

	render: ->
		<tr>
			<td>{@props.name}</td>
			<td>{@props.players}</td>
			<td>{@props.timer}</td>
		</tr>

module.exports = GameList
