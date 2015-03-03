Footer = require './Footer'
GameList = require './GameList'
Header = require './Header'

Index = React.createClass

	render: ->

		<div>

			<Header animated=true />

			<GameList {...@props} />

			<button className="create-game"
				onClick={@createGame}>
				Create a new Game
			</button>

			<Footer />

		</div>

	createGame: ->
		@props.onSwitch 'create'

module.exports = Index
