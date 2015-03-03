Chat = require './Chat'
Menu = require './Menu'
Client = require '../client'

Play = React.createClass

	render: ->
		<div>
			<canvas id="canvas"></canvas>
			<Menu />
			<Chat />
		</div>

	componentDidMount: ->
		@client = new Client()

	componentWillUnmount: ->
		#

module.exports = Play
