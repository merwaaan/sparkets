Chat = require './Chat'
Menu = require './Menu'
Client = require '../client'

React = require 'react/addons'
Router = require 'react-router'

Play = React.createClass

	mixins: [Router.State]

	render: ->
		<div>
			<canvas ref='canvas' id='canvas'></canvas>
			<Menu client={@client} />
			<Chat ref='chat' client={@client} />
		</div>

	componentWillMount: ->
		@client = new Client @getParams().gameId

	componentDidMount: ->
		@client.bindCanvas @refs.canvas.getDOMNode()

	componentWillUnmount: ->
		#


module.exports = Play
