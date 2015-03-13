Create = require './Create'
Index = require './Index'
Play = require './Play'

React = require 'react'
Router = require 'react-router'

Sparkets = React.createClass

	render: ->
		<Router.RouteHandler socket={@socket}/>

	componentWillMount: ->

		@socket = io.connect()

		@socket.on 'connect', () =>
			console.log 'Connected to global server'

		@socket.on 'disconnect', () =>
			console.log 'Disconnected from global server'


module.exports = Sparkets


# Entry point

Route = Router.Route
DefaultRoute = Router.DefaultRoute

routes = (<Route path='/' handler={Sparkets}>
	<DefaultRoute handler={Index} />
	<Route name='create' handler={Create} />
	<Route name='play' path='play/:gameId' handler={Play} />
</Route>)

window.addEventListener 'load', () ->
	Router.run routes, (Handler) ->
		React.render <Handler />, document.body
