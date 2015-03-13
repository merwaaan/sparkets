Create = require './Create'
Index = require './Index'
Play = require './Play'

ws = require 'ws'
React = require 'react'
Router = require 'react-router'

Sparkets = React.createClass

  render: ->
    <Router.RouteHandler socket={@socket}/>

  componentWillMount: ->

    # Connect to server and set callbacks.
    # FIXME: websocket port number is hardcoded
    @socket = new WebSocket('ws:' + window.location.hostname + ':12346')

    @socket.addEventListener 'open', () =>
      console.info "Connected to server."

    @socket.addEventListener 'close', () =>
      console.log 'Disconnected from server'


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
