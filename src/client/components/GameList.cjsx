_ = require('lodash')

GameList = React.createClass

	getInitialState: ->
		games: []

	render: ->

		games = _.map @state.games, (game, name) =>
			<Game
				name={name}
				players={game.players}
				started={game.startTime}
				duration={game.duration * 60 * 1000} />

		# Ifthere is no available games, say so
		if games.length is 0
			games = <tr>
				<td colSpan=3>No games available</td>
			</tr>

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
			@setState {games: data}


Game = React.createClass

	getInitialState: ->
		minutes: 0
		seconds: 0

	render: ->
		<tr>
			<td>
				<a href={'/play/#' + @props.name}>{@props.name}</a>
			</td>
			<td>{@props.players}</td>
			<td>{@state.minutes}:{@state.seconds}</td>
		</tr>

	componentDidMount: ->
		@timerInterval = setInterval @computeTimeLeft, 1000

	componentWillUnmount: ->
		clearInterval @timerInterval

	computeTimeLeft: (start, duration) ->

		remaining = new Date(this.props.duration - (Date.now() - this.props.started))

		pad = (time) ->
			if time.toString().length is 1 then '0' + time else time

		@setState
			minutes: pad remaining.getMinutes()
			seconds: pad remaining.getSeconds()




module.exports = GameList
