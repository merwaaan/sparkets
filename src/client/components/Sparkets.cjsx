Create = require './Create'
Index = require './Index'
Play = require './Play'
Message = require '../../message'

WebSocket = require 'ws'
PubSub = require 'pubsub-js'
React = require 'react'
Router = require 'react-router'

Sparkets = React.createClass

  render: ->
    <Router.RouteHandler/>

  componentWillMount: ->

    # Connect to server
    # FIXME: websocket port number is hardcoded
    @socket = new WebSocket('ws:' + window.location.hostname + ':12346')

    @socket.addEventListener 'open', () =>
      console.info "Connected to server."

    @socket.addEventListener 'close', () =>
      console.info 'Disconnected from server'

    # Received messages are published to any subscribed component
    @socket.addEventListener 'message', (raw) =>
       msg = Message.decode(raw.data)
       PubSub.publish msg.type, msg.content

    # Components can publish messages to be sent to the server
    PubSub.subscribe 'send', (message, data) =>
      Message.send @socket, data.type, data.content


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
