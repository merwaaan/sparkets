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

			timeLeft = (start, duration) ->
				new Date(duration - (Date.now() - start)).getSeconds()

			games = _.map data, (game, name) ->
				name: name
				players: game.players
				timer: timeLeft game.startTime, game.duration * 60 * 1000

			@setState {games: games}


Game = React.createClass

	getInitialState: ->
		seconds: @props.timer

	render: ->
		<tr>
			<td>{@props.name}</td>
			<td>{@props.players}</td>
			<td>{@state.seconds}</td>
		</tr>

	componentDidMount: ->
		setInterval (() =>
			if @state.seconds > 0 then @setState {seconds: @state.seconds - 1}), 1000

module.exports = GameList
