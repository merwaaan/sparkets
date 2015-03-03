GameSettings = require './GameSettings'
Header = require './Header'

Create = React.createClass

	render: ->
		<div>
			<Header />
			<GameSettings />
		</div>

module.exports = Create
